import 'package:flutter_test/flutter_test.dart';
import 'package:zimauthenticator/services/qr_decoder_service.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  group('QRDecoderService', () {
    test('processQRText should throw exception for invalid JSON', () {
      expect(
        () => QRDecoderService.processQRText('invalid'),
        throwsA(isA<QRDecodeException>()),
      );
    });

    test('processQRText should throw exception for empty array', () {
      expect(
        () => QRDecoderService.processQRText('[]'),
        throwsA(isA<QRDecodeException>()),
      );
    });

    // Note: To test the full pipeline, we would need a valid encrypted payload
    // consistent with the public key in the service.
    // If the user provided a sample QR text, we could add it here.
  });
}
