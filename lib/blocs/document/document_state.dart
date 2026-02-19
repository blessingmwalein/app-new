import 'package:equatable/equatable.dart';
import '../../models/document_model.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentState {
  const DocumentsInitial();
}

class DocumentsLoading extends DocumentState {
  const DocumentsLoading();
}

class DocumentsLoaded extends DocumentState {
  final List<DocumentModel> documents;

  const DocumentsLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class DocumentsError extends DocumentState {
  final String message;

  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
