import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/document_model.dart';
import '../blocs/document/document_bloc.dart';

class DocumentDetailScreen extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailScreen({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    // Add to history
    context.read<DocumentBloc>().add(AddDocument(document));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A),
              const Color(0xFF3B82F6),
              const Color(0xFF60A5FA).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildDocumentCard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Result',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Verified Document',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.2, end: 0, duration: 400.ms);
  }

  Widget _buildDocumentCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Document Icon
          Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_rounded,
                size: 50,
                color: const Color(0xFF1E3A8A),
              ),
            ).animate()
              .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
          ),

          // Document Details
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildField(
                  icon: Icons.article_rounded,
                  label: 'Document Type',
                  value: document.documentType ?? 'Not specified',
                ),
                
                if (document.documentId != null)
                  _buildField(
                    icon: Icons.numbers_rounded,
                    label: 'Document ID',
                    value: document.documentId!,
                  ),
                
                if (document.holderName != null)
                  _buildField(
                    icon: Icons.person_rounded,
                    label: 'Holder Name',
                    value: document.holderName!,
                  ),
                
                if (document.issuedDate != null)
                  _buildField(
                    icon: Icons.calendar_today_rounded,
                    label: 'Issued Date',
                    value: document.issuedDate!,
                  ),
                
                if (document.expiryDate != null)
                  _buildField(
                    icon: Icons.event_busy_rounded,
                    label: 'Expiry Date',
                    value: document.expiryDate!,
                  ),
                
                if (document.timestamp != null)
                  _buildField(
                    icon: Icons.access_time_rounded,
                    label: 'Timestamp',
                    value: document.timestamp!,
                  ),

                // Additional fields
                if (document.additionalFields != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...document.additionalFields!.entries.map(
                    (entry) => _buildField(
                      icon: Icons.info_outline_rounded,
                      label: _formatLabel(entry.key),
                      value: entry.value.toString(),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Scan info
                _buildInfoBox(
                  'Scanned on ${DateFormat('MMMM dd, yyyy').format(document.scannedAt)}',
                  'at ${DateFormat('hh:mm a').format(document.scannedAt)}',
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: _generateShareText(),
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Document details copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(Icons.copy_rounded),
                    label: Text('Copy Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: const Color(0xFF1E3A8A)),
                      foregroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: Icon(Icons.qr_code_scanner_rounded),
                    label: Text('Scan New'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 600.ms)
      .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms);
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E3A8A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFF1E3A8A),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String label) {
    // Convert camelCase or snake_case to Title Case
    return label
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    buffer.writeln('Zimbabwe Document Details');
    buffer.writeln('=========================');
    
    if (document.documentType != null) {
      buffer.writeln('Type: ${document.documentType}');
    }
    if (document.documentId != null) {
      buffer.writeln('ID: ${document.documentId}');
    }
    if (document.holderName != null) {
      buffer.writeln('Holder: ${document.holderName}');
    }
    if (document.issuedDate != null) {
      buffer.writeln('Issued: ${document.issuedDate}');
    }
    if (document.expiryDate != null) {
      buffer.writeln('Expires: ${document.expiryDate}');
    }
    
    buffer.writeln('\nScanned: ${DateFormat('MMM dd, yyyy • hh:mm a').format(document.scannedAt)}');
    
    return buffer.toString();
  }
}
