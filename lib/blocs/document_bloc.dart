import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/document_model.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  static const String _storageKey = 'scanned_documents';
  List<DocumentModel> _documents = [];

  DocumentBloc() : super(const DocumentsInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<AddDocument>(_onAddDocument);
    on<DeleteDocument>(_onDeleteDocument);
    on<ClearAllDocuments>(_onClearAllDocuments);
    
    // Auto-load documents on initialization
    add(const LoadDocuments());
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      emit(const DocumentsLoading());
      
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getString(_storageKey);
      
      if (documentsJson != null) {
        final List<dynamic> decoded = jsonDecode(documentsJson);
        _documents = decoded
            .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by scanned date, most recent first
        _documents.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      }
      
      emit(DocumentsLoaded(_documents));
    } catch (e) {
      emit(DocumentsError('Failed to load documents: ${e.toString()}'));
    }
  }

  Future<void> _onAddDocument(
    AddDocument event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      _documents.insert(0, event.document); // Add to top
      
      // Keep only last 50 documents
      if (_documents.length > 50) {
        _documents = _documents.sublist(0, 50);
      }
      
      await _saveDocuments();
      emit(DocumentsLoaded(_documents));
    } catch (e) {
      emit(DocumentsError('Failed to save document: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      _documents.removeWhere((doc) => 
        doc.documentId == event.documentId ||
        doc.rawEncryptedData == event.documentId
      );
      
      await _saveDocuments();
      emit(DocumentsLoaded(_documents));
    } catch (e) {
      emit(DocumentsError('Failed to delete document: ${e.toString()}'));
    }
  }

  Future<void> _onClearAllDocuments(
    ClearAllDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      _documents.clear();
      await _saveDocuments();
      emit(const DocumentsLoaded([]));
    } catch (e) {
      emit(DocumentsError('Failed to clear documents: ${e.toString()}'));
    }
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = jsonEncode(
      _documents.map((doc) => doc.toJson()).toList(),
    );
    await prefs.setString(_storageKey, documentsJson);
  }
}
