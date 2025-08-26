import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// شاشة البداية التي تظهر عند فتح التطبيق وتتحقق من حالة تسجيل الدخول.
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // الانتظار ثانيتين ثم بدء عملية التحقق
    Timer(const Duration(seconds: 2), _redirect);
  }

  /// يتحقق من حالة المصادقة، وإذا كان المستخدم مسجلاً،
  /// فإنه يتحقق من وجود ملف شخصي له قبل إعادة التوجيه.
  Future<void> _redirect() async {
    if (!mounted) return;
    
    final supabase = getIt<SupabaseClient>();
    final session = supabase.auth.currentSession;

    if (session != null) {
      // المستخدم مسجل دخوله، الآن تحقق من وجود ملف شخصي
      bool profileExists = await _checkForProfile(supabase, session.user.id);
      
      // إذا لم يكن الملف الشخصي موجودًا، انتظر قليلاً وحاول مرة أخرى
      // هذا يعطي الزناد (Trigger) وقتاً للعمل في حالة المستخدم الجديد تمامًا
      if (!profileExists) {
        await Future.delayed(const Duration(seconds: 2));
        profileExists = await _checkForProfile(supabase, session.user.id);
      }

      if (mounted) {
        if (profileExists) {
          context.go('/main');
        } else {
          // إذا لم يتم إنشاء الملف الشخصي بعد فترة، أعد المستخدم لتسجيل الدخول
          // هذا يمنع الدخول إلى التطبيق بحالة خاطئة
          await supabase.auth.signOut();
          context.go('/login');
        }
      }
    } else {
      // المستخدم غير مسجل، اذهب إلى شاشة الدخول
      context.go('/login');
    }
  }

  /// دالة مساعدة للتحقق من وجود صف للمستخدم في جدول profiles
  Future<bool> _checkForProfile(SupabaseClient client, String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00E1C7),
              Color(0xFF007BFF),
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
            // ... loading dots UI if you have it
          ],
        ),
      ),
    );
  }
}