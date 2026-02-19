import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerService {
  /// Validate if the scanned code looks like encrypted data
  bool isValidEncryptedQR(String code) {
    // Check if it's a valid Base64 string
    if (code.isEmpty) return false;
    
    // Base64 validation - should only contain valid Base64 characters
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(code);
  }

  /// Extract raw value from barcode
  String? extractRawValue(Barcode barcode) {
    return barcode.rawValue;
  }

  /// Check if barcode is a QR code
  bool isQRCode(Barcode barcode) {
    return barcode.format == BarcodeFormat.qrCode;
  }
}
