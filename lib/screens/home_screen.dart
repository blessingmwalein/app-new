import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../blocs/document/document_bloc.dart';
import '../blocs/scanner/scanner_bloc.dart';
import '../models/document_model.dart';
import 'scanner_screen.dart';
import 'document_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Header
              _buildHeader(context),
              
              const SizedBox(height: 20),
              
              // Main Scan Button
              _buildScanButton(context),
              
              const SizedBox(height: 40),
              
              // Recent Scans Section
              Expanded(
                child: _buildRecentScans(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Authenticator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Scan & Verify Official Documents',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showInfoDialog(context);
            },
            icon: Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildScanButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ScannerScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 40,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan AI Code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to scan QR code on document',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8))
        .shimmer(delay: 800.ms, duration: 2000.ms),
    );
  }

  Widget _buildRecentScans(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: const Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Scans',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DocumentBloc, DocumentState>(
              builder: (context, state) {
                if (state is DocumentsLoaded && state.documents.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.documents.length,
                    itemBuilder: (context, index) {
                      final doc = state.documents[index];
                      return _buildDocumentCard(context, doc);
                    },
                  );
                }
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No scanned documents yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Scan AI Code" to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 400.ms, duration: 600.ms)
      .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 600.ms);
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DocumentDetailScreen(document: document),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.documentType ?? 'Unknown Document',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(document.scannedAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: const Color(0xFF1E3A8A)),
            const SizedBox(width: 12),
            Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zimbabwe Document Authenticator',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Version 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'This application uses AI-powered technology to scan and verify QR codes on official Zimbabwe documents.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
