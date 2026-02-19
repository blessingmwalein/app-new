import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agreedToTerms = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E3A8A),
              const Color(0xFF3B82F6).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 60,
                      color: Colors.white,
                    ).animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Please read and accept our terms to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ).animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms),
                  ],
                ),
              ),
              
              // Terms Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildTermsSection(
                          icon: Icons.privacy_tip_rounded,
                          title: '1. Privacy & Data Usage',
                          content: 'Your scanned documents are processed locally on your device. We use AES encryption to ensure your data remains secure. No personal information is stored on external servers without your explicit consent.',
                        ),
                        
                        _buildTermsSection(
                          icon: Icons.security_rounded,
                          title: '2. Document Verification',
                          content: 'This application uses advanced AI and cryptographic algorithms to verify QR codes on official Zimbabwe documents. The verification process checks digital signatures and encrypted data embedded in the QR code.',
                        ),
                        
                        _buildTermsSection(
                          icon: Icons.camera_alt_rounded,
                          title: '3. Camera Permissions',
                          content: 'Camera access is required to scan QR codes on documents. We only use the camera for scanning purposes and do not record or store any images.',
                        ),
                        
                        _buildTermsSection(
                          icon: Icons.gavel_rounded,
                          title: '4. Legal Compliance',
                          content: 'By using this application, you agree to comply with all applicable laws and regulations of Zimbabwe. This app is for verification purposes only and should not be used for fraudulent activities.',
                        ),
                        
                        _buildTermsSection(
                          icon: Icons.update_rounded,
                          title: '5. Updates & Changes',
                          content: 'We may update these terms from time to time. Continued use of the application constitutes acceptance of any changes. You will be notified of significant updates.',
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.1, end: 0, duration: 600.ms),
              ),
              
              // Accept Checkbox and Continue Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      title: Text(
                        'I have read and agree to the Terms & Conditions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      activeColor: const Color(0xFF1E3A8A),
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _agreedToTerms ? _acceptTerms : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: _agreedToTerms ? 8 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1E3A8A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
