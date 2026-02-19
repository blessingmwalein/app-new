import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'terms_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.forward();
    
    // Navigate to terms screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TermsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A), // Deep blue
              const Color(0xFF3B82F6), // Blue
              const Color(0xFF60A5FA), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 70,
                  color: const Color(0xFF1E3A8A),
                ),
              ).animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
              
              const SizedBox(height: 30),
              
              // App Title
              Text(
                'Zimbabwe',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ).animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
              
              Text(
                'Document Authenticator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.0,
                ),
              ).animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
              
              const SizedBox(height: 60),
              
              // Loading indicator
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: 700.ms, duration: 400.ms),
              
              const SizedBox(height: 20),
              
              Text(
                'Powered by AI Technology',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ).animate()
                .fadeIn(delay: 900.ms, duration: 600.ms),
              
              const Spacer(),
              
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  'Verify • Authenticate • Secure',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ).animate()
                  .fadeIn(delay: 1100.ms, duration: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
