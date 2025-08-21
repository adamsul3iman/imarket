// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/presentation/screens/ad_details_screen.dart';
import 'package:imarket/presentation/screens/main_screen.dart';
import 'package:imarket/presentation/screens/login_screen.dart';
import 'package:imarket/presentation/screens/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
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
        path: '/main',
        builder: (BuildContext context, GoRouterState state) {
          // MainScreen contains the BottomNavBar and hosts other screens
          return const MainScreen();
        },
      ),
      GoRoute(
        path: '/ad-details',
        builder: (BuildContext context, GoRouterState state) {
          // Retrieve the Ad object passed as an extra parameter
          final ad = state.extra as Ad;
          return AdDetailsScreen(
            ad: ad,
            heroTagPrefix: 'home', // We can enhance this later
          );
        },
      ),
    ],
  );
}