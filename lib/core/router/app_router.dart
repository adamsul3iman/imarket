// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/presentation/screens/account_settings_screen.dart';
import 'package:imarket/presentation/screens/add_ad_screen.dart';
import 'package:imarket/presentation/screens/ad_details_screen.dart';
import 'package:imarket/presentation/screens/blocked_users_screen.dart';
import 'package:imarket/presentation/screens/change_password_screen.dart';
import 'package:imarket/presentation/screens/coming_soon_screen.dart';
import 'package:imarket/presentation/screens/legal_content_screen.dart';
import 'package:imarket/presentation/screens/login_screen.dart';
import 'package:imarket/presentation/screens/main_screen.dart';
import 'package:imarket/presentation/screens/paywall_screen.dart'; // ✅ FIX: Add this import
import 'package:imarket/presentation/screens/saved_searches_screen.dart';
import 'package:imarket/presentation/screens/seller_profile_screen.dart';
import 'package:imarket/presentation/screens/settings_screen.dart';
import 'package:imarket/presentation/screens/signup_screen.dart';
import 'package:imarket/presentation/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:imarket/presentation/screens/payment_success_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // Auth-aware redirection logic
    redirect: (BuildContext context, GoRouterState state) {
      final supabase = getIt<SupabaseClient>();
      final loggedIn = supabase.auth.currentUser != null;
      final location = state.uri.toString();

      final isAuthScreen = location == '/login' || location == '/signup';

      if (!loggedIn && !isAuthScreen && location != '/splash') {
        return '/login';
      }
      if (loggedIn && isAuthScreen) {
        return '/main';
      }
      return null;
    },

    routes: <GoRoute>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: '/main',
        builder: (BuildContext context, GoRouterState state) {
          return const MainScreen();
        },
      ),
      GoRoute(
        path: '/ad-details',
        builder: (BuildContext context, GoRouterState state) {
          final ad = state.extra as Ad;
          return AdDetailsScreen(
            ad: ad,
            heroTagPrefix: 'home',
          );
        },
      ),
      GoRoute(
        path: '/add-ad',
        builder: (BuildContext context, GoRouterState state) {
          return const AddAdScreen();
        },
      ),
      GoRoute(
        path: '/seller-profile',
        builder: (BuildContext context, GoRouterState state) {
          final args = state.extra as Map<String, dynamic>;
          return SellerProfileScreen(
            sellerId: args['id'] as String,
            sellerName: args['name'] as String,
          );
        },
      ),
      GoRoute(
        path: '/saved-searches',
        builder: (BuildContext context, GoRouterState state) {
          return const SavedSearchesScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: '/account-settings',
        builder: (BuildContext context, GoRouterState state) {
          return const AccountSettingsScreen();
        },
      ),
      GoRoute(
        path: '/change-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ChangePasswordScreen();
        },
      ),
      GoRoute(
        path: '/blocked-users',
        builder: (BuildContext context, GoRouterState state) {
          return const BlockedUsersScreen();
        },
      ),
      // ✅ FIX: Add the new route for the PaywallScreen here
      GoRoute(
        path: '/paywall',
        builder: (BuildContext context, GoRouterState state) {
          return const PaywallScreen();
        },
      ),
      GoRoute(
        path: '/legal/:page',
        builder: (BuildContext context, GoRouterState state) {
          final page = state.pathParameters['page']!;
          if (page == 'terms') {
            return const LegalContentScreen(
                title: 'شروط الخدمة', content: '...');
          } else {
            return const LegalContentScreen(
                title: 'سياسة الخصوصية', content: '...');
          }
        },
      ),

      GoRoute(
        path: '/coming-soon',
        builder: (BuildContext context, GoRouterState state) {
          final featureName = state.extra as String? ?? 'هذه الميزة';
          return ComingSoonScreen(featureName: featureName);
        },
      ),

      GoRoute(
        path: '/payment-success',
        builder: (BuildContext context, GoRouterState state) {
          return const PaymentSuccessScreen(); // You'll need to create this new screen
        },
      ),
    ],
  );
}
