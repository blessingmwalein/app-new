import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/qr_scanner_service.dart';
import '../../services/qr_decoder_service.dart';
import '../../models/document_model.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final QRScannerService scannerService;
  final QRDecoderService decoderService;

  ScannerBloc({required this.scannerService, required this.decoderService})
    : super(const ScannerInitial()) {
    on<StartScanning>(_onStartScanning);
    on<QRCodeDetected>(_onQRCodeDetected);
    on<StopScanning>(_onStopScanning);
    on<ResetScanner>(_onResetScanner);
  }

  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<ScannerState> emit,
  ) async {
    emit(const ScannerScanning());
  }

  Future<void> _onQRCodeDetected(
    QRCodeDetected event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      print('=== QR CODE DETECTED ===');
      print('Raw Data Length: ${event.rawData.length}');
      print(
        'First 200 chars: ${event.rawData.substring(0, event.rawData.length > 200 ? 200 : event.rawData.length)}',
      );
      print(
        'Starts with: ${event.rawData.substring(0, event.rawData.length > 10 ? 10 : event.rawData.length)}',
      );
      print(
        'Data type check: isArray=${event.rawData.startsWith('[')}, isObject=${event.rawData.startsWith('{')}',
      );

      emit(ScannerProcessing(event.rawData));

      // Attempt to decode the QR code data
      print('Starting decoding...');
      final String decodedDataJson;
      try {
        decodedDataJson = decoderService.decodeQRText(event.rawData);
      } catch (e) {
        print('Decoding failed: $e');
        emit(ScannerError('Failed to decode QR code: $e'));
        return;
      }

      print('Decoding successful!');
      final Map<String, dynamic> decodedData = jsonDecode(decodedDataJson);
      print('Decoded data keys: ${decodedData.keys.toList()}');

      // Parse the decoded JSON data
      final document = DocumentModel.fromDecryptedData(
        decodedData,
        event.rawData,
      );

      print('Document created successfully');
      emit(ScannerSuccess(document));
    } catch (e, stackTrace) {
      print('=== ERROR PROCESSING QR CODE ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      emit(ScannerError('Error processing QR code: ${e.toString()}'));
    }
  }

  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<ScannerState> emit,
  ) async {
    emit(const ScannerInitial());
  }

  Future<void> _onResetScanner(
    ResetScanner event,
    Emitter<ScannerState> emit,
  ) async {
    emit(const ScannerInitial());
  }
}
