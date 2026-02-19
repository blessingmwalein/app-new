import 'package:equatable/equatable.dart';
import '../../models/document_model.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

class ScannerScanning extends ScannerState {
  const ScannerScanning();
}

class ScannerProcessing extends ScannerState {
  final String rawData;

  const ScannerProcessing(this.rawData);

  @override
  List<Object?> get props => [rawData];
}

class ScannerSuccess extends ScannerState {
  final DocumentModel document;

  const ScannerSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
