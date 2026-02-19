import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class StartScanning extends ScannerEvent {
  const StartScanning();
}

class QRCodeDetected extends ScannerEvent {
  final String rawData;

  const QRCodeDetected(this.rawData);

  @override
  List<Object?> get props => [rawData];
}

class StopScanning extends ScannerEvent {
  const StopScanning();
}

class ResetScanner extends ScannerEvent {
  const ResetScanner();
}
