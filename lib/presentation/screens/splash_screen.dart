import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imarket/main.dart';
import 'main_screen.dart';
import 'login_screen.dart';
import 'package:go_router/go_router.dart'; // Added for navigation

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد حركة النبض
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // تأخير 3 ثواني ثم التوجيه
    Timer(const Duration(seconds: 3), _redirect);
  }

  /// التوجيه حسب حالة Supabase
  Future<void> _redirect() async {
    if (!mounted) return;
    final session = supabase.auth.currentSession;

    // Use context.go() to replace the navigation stack
    if (session != null) {
      context.go('/main');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double value = (_controller.value + index * 0.3) % 1.0;
            double opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color.fromARGB(
                  (opacity * 255).round(), // alpha
                  255, // red
                  255, // green
                  255, // blue
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00E1C7), // Turquoise
              Color(0xFF007BFF), // Blue
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Image.asset('assets/images/splash_logo.png', width: 160),
            ),
            const SizedBox(height: 30),
            _buildLoadingDots(),
          ],
        ),
      ),
    );
  }
}
