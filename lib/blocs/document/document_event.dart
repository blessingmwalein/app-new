import 'package:equatable/equatable.dart';
import '../../models/document_model.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocuments extends DocumentEvent {
  const LoadDocuments();
}

class AddDocument extends DocumentEvent {
  final DocumentModel document;

  const AddDocument(this.document);

  @override
  List<Object?> get props => [document];
}

class DeleteDocument extends DocumentEvent {
  final String documentId;

  const DeleteDocument(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class ClearAllDocuments extends DocumentEvent {
  const ClearAllDocuments();
}
