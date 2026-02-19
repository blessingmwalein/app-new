import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Dart port of the Java AuthentisRealDecoder class.
///
/// Processing pipeline (mirrors Java implementation):
///   1. QR text  →  split on ";key", take JSON part
///   2. JSON[0]  →  Base64-encoded RSA-encrypted payload
///   3. RSA public-key decrypt (PKCS#1 v1.5)  →  Base64 string
///   4. Base64 decode  →  zlib-compressed bytes
///   5. zlib decompress  →  final JSON string
class QRDecoderService {
  // Same public key as the Java reference implementation
  static const String _publicKeyPem = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuRf/w2FcqRhSCr79XoBh
+KF0mmuWwATid6b78FXxjyI3TRWwZ2wDjyuk3mwNwO+9/40V3t5lwEUzxMP2Z+xO
5731mJ10uxEwNUDXUOvSBnryz3pqTTUREl8cfMPJolYtURuxELjGtX6Sbq6yCnmM
05LUqXQK5SeYqjLtXwEkr44z1kccdrQbkYxQAf7h+zP5Lk25yyB9cOo+u82KDUdL
by368LrVgkrLeXorzqEtnH1Iokvas/t0eCdd4fx1zaADab/a/YGSINAjFr5Ohfpl
EhUTmoOa6HL7NGKu24o/Fz6PxCAmZTqEAtbRsddxNnus35E2sMAtsZ3AQwWP6Tzl
EwIDAQAB
-----END PUBLIC KEY-----''';

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Instance wrapper for processQRText to support dependency injection.
  String decodeQRText(String qrText) => processQRText(qrText);

  /// Process the raw text decoded from a QR code image.
  ///
  /// Returns the decompressed JSON string, or throws a [QRDecodeException]
  /// with a human-readable message when any step fails.
  static String processQRText(String qrText) {
    // Step 1 – extract the encrypted chunk from the JSON payload
    final String encryptedChunk = _extractEncryptedChunk(qrText);

    // Step 2 – load RSA public key
    final _RSAPublicKey publicKey = _loadPublicKey();

    // Step 3 – RSA public-key decrypt  (Java: Cipher.DECRYPT_MODE + public key)
    final Uint8List encryptedBytes = _base64Decode(
      encryptedChunk,
      'encrypted chunk',
    );
    final Uint8List decryptedBytes = _rsaDecryptPublic(
      encryptedBytes,
      publicKey,
    );

    // Step 4 – the decrypted bytes are a UTF-8 string that is itself Base64
    final String base64Compressed = utf8.decode(decryptedBytes);

    // Step 5 – decode that Base64 to get the compressed bytes
    final Uint8List compressed = _base64Decode(
      base64Compressed,
      'compressed data',
    );

    // Step 6 – zlib decompress  (Java: java.util.zip.Inflater, default nowrap=false)
    return _zlibDecompress(compressed);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  static String _extractEncryptedChunk(String qrText) {
    try {
      // Mirror: mapper.readTree(qrText.split(";key")[0]).path(0).asText()
      final String jsonPart = qrText.split(';key')[0];
      final dynamic parsed = jsonDecode(jsonPart);
      if (parsed is! List || parsed.isEmpty) {
        throw QRDecodeException('QR JSON payload is not a non-empty array');
      }
      return parsed[0] as String;
    } on QRDecodeException {
      rethrow;
    } catch (e) {
      throw QRDecodeException('Failed to parse QR text as JSON: $e');
    }
  }

  static Uint8List _base64Decode(String data, String label) {
    try {
      return base64Decode(data.trim());
    } catch (e) {
      throw QRDecodeException('Base64 decode failed for $label: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // RSA public key parsing  (X.509 SubjectPublicKeyInfo DER)
  // ---------------------------------------------------------------------------

  static _RSAPublicKey _loadPublicKey() {
    final String b64 = _publicKeyPem
        .replaceAll(RegExp(r'-----\w[\w ]+-----'), '')
        .replaceAll(RegExp(r'\s'), '');
    final Uint8List der = base64Decode(b64);
    return _parseDerPublicKey(der);
  }

  /// Minimal DER parser for SubjectPublicKeyInfo containing an RSA key.
  ///
  /// Structure:
  ///   SEQUENCE {
  ///     SEQUENCE { OID rsaEncryption, NULL }   ← AlgorithmIdentifier
  ///     BIT STRING {
  ///       SEQUENCE { INTEGER n, INTEGER e }    ← RSAPublicKey
  ///     }
  ///   }
  static _RSAPublicKey _parseDerPublicKey(Uint8List der) {
    int pos = 0;

    // Read a DER length field; advance pos past the length bytes.
    int readLength() {
      final int first = der[pos++];
      if (first & 0x80 == 0) return first;
      final int numBytes = first & 0x7F;
      int len = 0;
      for (int i = 0; i < numBytes; i++) {
        len = (len << 8) | der[pos++];
      }
      return len;
    }

    void expectTag(int tag) {
      if (der[pos++] != tag) {
        throw QRDecodeException(
          'DER parse error: unexpected tag 0x${der[pos - 1].toRadixString(16)} (expected 0x${tag.toRadixString(16)})',
        );
      }
    }

    // Outer SEQUENCE
    expectTag(0x30);
    readLength();

    // AlgorithmIdentifier SEQUENCE – skip entirely
    expectTag(0x30);
    final int algLen = readLength();
    pos += algLen;

    // BIT STRING containing the RSA key
    expectTag(0x03);
    readLength();
    pos++; // unused-bits octet (always 0x00 for aligned data)

    // Inner RSAPublicKey SEQUENCE
    expectTag(0x30);
    readLength();

    // INTEGER n (modulus)
    expectTag(0x02);
    final int nLen = readLength();
    // Skip any leading 0x00 padding byte (sign indicator for positive BigInt)
    final int nStart = (nLen > 0 && der[pos] == 0x00) ? pos + 1 : pos;
    final BigInt n = _bytesToBigInt(der.sublist(nStart, pos + nLen));
    pos += nLen;

    // INTEGER e (public exponent)
    expectTag(0x02);
    final int eLen = readLength();
    final int eStart = (eLen > 0 && der[pos] == 0x00) ? pos + 1 : pos;
    final BigInt e = _bytesToBigInt(der.sublist(eStart, pos + eLen));

    return _RSAPublicKey(n: n, e: e);
  }

  // ---------------------------------------------------------------------------
  // RSA PKCS#1 v1.5  "decrypt with public key"
  //
  // Java uses Cipher.getInstance("RSA/ECB/PKCS1Padding") + DECRYPT_MODE + PublicKey.
  // That performs the RSA public-key operation (M = C^e mod n) and removes
  // PKCS#1 v1.5 padding, which is what we replicate here.
  // ---------------------------------------------------------------------------

  static Uint8List _rsaDecryptPublic(Uint8List cipherBytes, _RSAPublicKey key) {
    // RSA public-key operation: M = C^e mod n
    final BigInt c = _bytesToBigInt(cipherBytes);
    final BigInt m = c.modPow(key.e, key.n);
    final int keyLen = (key.n.bitLength + 7) ~/ 8;
    final Uint8List block = _bigIntToBytes(m, keyLen);

    // Strip PKCS#1 v1.5 padding
    // Type 1 (sign):   0x00 | 0x01 | 0xFF… | 0x00 | data
    // Type 2 (encrypt):0x00 | 0x02 | rand…  | 0x00 | data
    int i = 0;
    if (i < block.length && block[i] == 0x00) i++;
    if (i < block.length) i++; // skip type byte (0x01 or 0x02)
    while (i < block.length && block[i] != 0x00) {
      i++;
    }
    if (i >= block.length) {
      throw QRDecodeException(
        'Invalid PKCS#1 padding: no 0x00 separator found',
      );
    }
    i++; // skip 0x00 separator
    return block.sublist(i);
  }

  // ---------------------------------------------------------------------------
  // zlib decompression  (Java: java.util.zip.Inflater with nowrap=false)
  // ---------------------------------------------------------------------------

  static String _zlibDecompress(Uint8List data) {
    try {
      final ZLibDecoder decoder = ZLibDecoder();
      final List<int> decompressed = decoder.decodeBytes(data);
      return utf8.decode(decompressed);
    } catch (e) {
      throw QRDecodeException('zlib decompression failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // BigInt ↔ byte array utilities
  // ---------------------------------------------------------------------------

  static BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final int byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt number, int size) {
    final Uint8List result = Uint8List(size);
    for (int i = size - 1; i >= 0; i--) {
      result[i] = (number & BigInt.from(0xFF)).toInt();
      number >>= 8;
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

class _RSAPublicKey {
  final BigInt n;
  final BigInt e;
  const _RSAPublicKey({required this.n, required this.e});
}

class QRDecodeException implements Exception {
  final String message;
  const QRDecodeException(this.message);

  @override
  String toString() => 'QRDecodeException: $message';
}
