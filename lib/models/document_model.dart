import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class DocumentModel extends Equatable {
  final String? documentId;
  final String? documentType;
  final String? holderName;
  final String? issuedDate;
  final String? expiryDate;
  final String? signature;
  final String? timestamp;
  final Map<String, dynamic>? additionalFields;
  final String rawEncryptedData;
  final DateTime scannedAt;

  const DocumentModel({
    this.documentId,
    this.documentType,
    this.holderName,
    this.issuedDate,
    this.expiryDate,
    this.signature,
    this.timestamp,
    this.additionalFields,
    required this.rawEncryptedData,
    required this.scannedAt,
  });

  /// Create DocumentModel from decrypted JSON data
  factory DocumentModel.fromDecryptedData(
    Map<String, dynamic> data,
    String rawEncryptedData,
  ) {
    // Extract common fields
    final documentId = data['documentId']?.toString() ?? 
                      data['id']?.toString() ?? 
                      data['document_id']?.toString();
    
    final documentType = data['documentType']?.toString() ?? 
                        data['type']?.toString() ?? 
                        data['document_type']?.toString() ??
                        'Unknown Document';
    
    final holderName = data['holderName']?.toString() ?? 
                      data['name']?.toString() ?? 
                      data['holder_name']?.toString();
    
    final issuedDate = data['issuedDate']?.toString() ?? 
                      data['issued_date']?.toString() ?? 
                      data['issue_date']?.toString();
    
    final expiryDate = data['expiryDate']?.toString() ?? 
                      data['expiry_date']?.toString() ?? 
                      data['expiration_date']?.toString();
    
    final signature = data['signature']?.toString() ?? 
                     data['digital_signature']?.toString();
    
    final timestamp = data['timestamp']?.toString() ?? 
                     data['created_at']?.toString();

    // Collect all other fields
    final knownFields = {
      'documentId', 'id', 'document_id',
      'documentType', 'type', 'document_type',
      'holderName', 'name', 'holder_name',
      'issuedDate', 'issued_date', 'issue_date',
      'expiryDate', 'expiry_date', 'expiration_date',
      'signature', 'digital_signature',
      'timestamp', 'created_at',
    };

    final additionalFields = Map<String, dynamic>.from(data)
      ..removeWhere((key, value) => knownFields.contains(key));

    return DocumentModel(
      documentId: documentId,
      documentType: documentType,
      holderName: holderName,
      issuedDate: issuedDate,
      expiryDate: expiryDate,
      signature: signature,
      timestamp: timestamp,
      additionalFields: additionalFields.isNotEmpty ? additionalFields : null,
      rawEncryptedData: rawEncryptedData,
      scannedAt: DateTime.now(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'documentType': documentType,
      'holderName': holderName,
      'issuedDate': issuedDate,
      'expiryDate': expiryDate,
      'signature': signature,
      'timestamp': timestamp,
      'additionalFields': additionalFields,
      'rawEncryptedData': rawEncryptedData,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  /// Create from JSON (for loading from storage)
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      documentId: json['documentId'] as String?,
      documentType: json['documentType'] as String?,
      holderName: json['holderName'] as String?,
      issuedDate: json['issuedDate'] as String?,
      expiryDate: json['expiryDate'] as String?,
      signature: json['signature'] as String?,
      timestamp: json['timestamp'] as String?,
      additionalFields: json['additionalFields'] as Map<String, dynamic>?,
      rawEncryptedData: json['rawEncryptedData'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        documentId,
        documentType,
        holderName,
        issuedDate,
        expiryDate,
        signature,
        timestamp,
        additionalFields,
        rawEncryptedData,
        scannedAt,
      ];
}
