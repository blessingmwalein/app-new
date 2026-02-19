import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

void main() async {
  String encrypted =
      "lATFGqgA9uZUOLNn5YOEpDHRSqlNYqFzpXZ3nYQZ0xmTRiFAR1jpYu6HrHUEBUBQEfLrINIqhShx/K8JXvHExpW4PK21IVfEcGkPJv0nuU/VYgoK/nIRrz1t1PvcQkliOrbk68Secv/RYePKURYAVdEtNwZ4YVY53bIHEO7Bf1nWlPm7V2ETJ0vVKG3yA31X+5cx2yT/TtALfmkCQaF8PRYC4QLiIuaRmbMEw2+fc06bb9X21Y+lRINU39TZitQMmcEuoIOlHM2yXwaiWucZpWlj8p7+bp9u1QX9W0vWxgSPbJmF5JCW20LBzY69K7oHrjM5ltvWILcSJw++Jo+A3A==";
  String keyString = "3649daf5-42cd-4f54-a418-a0736129356e";

  print('=== ADVANCED DECRYPTION TEST ===\n');

  final encryptedBytes = base64.decode(encrypted);
  print('Encrypted bytes: ${encryptedBytes.length} bytes\n');

  // Try 1: Direct UUID as UTF-8 bytes (padded to 32 bytes)
  print('--- Method 1: Direct UUID as bytes ---');
  try {
    final keyBytes = utf8.encode(keyString);
    print('Key length: ${keyBytes.length} bytes');

    // Pad or truncate to 32 bytes
    List<int> paddedKey;
    if (keyBytes.length < 32) {
      paddedKey = List<int>.from(keyBytes)
        ..addAll(List.filled(32 - keyBytes.length, 0));
    } else {
      paddedKey = keyBytes.sublist(0, 32);
    }

    await testAllModes(
      encryptedBytes,
      paddedKey,
      'Direct UUID (padded with zeros)',
    );
  } catch (e) {
    print('Error: $e\n');
  }

  // Try 2: UUID without dashes as UTF-8
  print('--- Method 2: UUID without dashes ---');
  try {
    final cleaned = keyString.replaceAll(
      '-',
      '',
    ); // "3649daf542cd4f54a418a0736129356e"
    print('Cleaned UUID: $cleaned');
    final keyBytes = utf8.encode(cleaned);
    print('Key length: ${keyBytes.length} bytes');

    List<int> paddedKey;
    if (keyBytes.length < 32) {
      paddedKey = List<int>.from(keyBytes)
        ..addAll(List.filled(32 - keyBytes.length, 0));
    } else {
      paddedKey = keyBytes.sublist(0, 32);
    }

    await testAllModes(encryptedBytes, paddedKey, 'UUID without dashes');
  } catch (e) {
    print('Error: $e\n');
  }

  // Try 3: UUID without dashes as hex bytes
  print('--- Method 3: UUID as hex bytes ---');
  try {
    final cleaned = keyString.replaceAll('-', '');
    print('Cleaned UUID: $cleaned');

    // Convert hex string to bytes
    List<int> hexBytes = [];
    for (int i = 0; i < cleaned.length; i += 2) {
      String hex = cleaned.substring(i, i + 2);
      hexBytes.add(int.parse(hex, radix: 16));
    }

    print('Hex bytes length: ${hexBytes.length}');

    // Pad to 32 bytes if needed
    List<int> paddedKey;
    if (hexBytes.length < 32) {
      paddedKey = List<int>.from(hexBytes)
        ..addAll(List.filled(32 - hexBytes.length, 0));
    } else {
      paddedKey = hexBytes.sublist(0, 32);
    }

    await testAllModes(encryptedBytes, paddedKey, 'UUID as hex bytes');
  } catch (e) {
    print('Error: $e\n');
  }

  // Try 4: First 16 bytes of UUID (AES-128)
  print('--- Method 4: First 16 bytes (AES-128) ---');
  try {
    final cleaned = keyString.replaceAll('-', '');
    List<int> hexBytes = [];
    for (int i = 0; i < 32 && i < cleaned.length; i += 2) {
      String hex = cleaned.substring(i, i + 2);
      hexBytes.add(int.parse(hex, radix: 16));
    }

    final key16 = hexBytes.sublist(0, 16);
    print('Key length: ${key16.length} bytes (AES-128)');

    await testAllModes(encryptedBytes, key16, 'AES-128 with first 16 bytes');
  } catch (e) {
    print('Error: $e\n');
  }

  // Try 5: SHA-256 of the UUID string
  print('--- Method 5: SHA-256 of UUID ---');
  try {
    final bytes = utf8.encode(keyString);
    final hash = sha256.convert(bytes).bytes;
    print('SHA-256 key length: ${hash.length}');

    await testAllModes(encryptedBytes, hash, 'SHA-256 hash');
  } catch (e) {
    print('Error: $e\n');
  }
}

Future<void> testAllModes(
  List<int> encryptedBytes,
  List<int> keyBytes,
  String methodName,
) async {
  print('Testing: $methodName');

  final key = encrypt.Key(Uint8List.fromList(keyBytes));

  // Test CBC with prepended IV
  try {
    if (encryptedBytes.length > 16) {
      final iv = encrypt.IV(Uint8List.fromList(encryptedBytes.sublist(0, 16)));
      final ciphertext = encryptedBytes.sublist(16);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(ciphertext)),
        iv: iv,
      );

      print('✓ CBC with IV: SUCCESS!');
      print(
        'Decrypted: ${decrypted.substring(0, decrypted.length > 200 ? 200 : decrypted.length)}...',
      );

      if (_isValidJSON(decrypted)) {
        print('✓✓ VALID JSON!');
        final json = jsonDecode(decrypted);
        print('JSON: $json');
      }
      print('');
      return;
    }
  } catch (e) {
    // Silent continue
  }

  // Test CBC with zero IV
  try {
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final decrypted = encrypter.decrypt(
      encrypt.Encrypted(Uint8List.fromList(encryptedBytes)),
      iv: iv,
    );

    print('✓ CBC with zero IV: SUCCESS!');
    print(
      'Decrypted: ${decrypted.substring(0, decrypted.length > 200 ? 200 : decrypted.length)}...',
    );

    if (_isValidJSON(decrypted)) {
      print('✓✓ VALID JSON!');
      final json = jsonDecode(decrypted);
      print('JSON: $json');
    }
    print('');
    return;
  } catch (e) {
    // Silent continue
  }

  // Test ECB
  try {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.ecb),
    );
    final decrypted = encrypter.decrypt(
      encrypt.Encrypted(Uint8List.fromList(encryptedBytes)),
    );

    print('✓ ECB: SUCCESS!');
    print(
      'Decrypted: ${decrypted.substring(0, decrypted.length > 200 ? 200 : decrypted.length)}...',
    );

    if (_isValidJSON(decrypted)) {
      print('✓✓ VALID JSON!');
      final json = jsonDecode(decrypted);
      print('JSON: $json');
    }
    print('');
    return;
  } catch (e) {
    // Silent continue
  }

  print('✗ All modes failed for this method\n');
}

bool _isValidJSON(String str) {
  try {
    jsonDecode(str);
    return true;
  } catch (e) {
    return false;
  }
}
