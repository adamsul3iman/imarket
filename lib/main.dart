import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/core/router/app_router.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/presentation/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart'; // ✅ FIX 1: Add this import
import 'package:webview_flutter/webview_flutter.dart'; // ✅ FIX 2: Also add this import for WebViewPlatform

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FIX 3: This line activates the web implementation for the WebView.
  WebViewPlatform.instance = WebWebViewPlatform();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(AdAdapter());

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  configureDependencies();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'iMarket JO',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      locale: const Locale('ar', ''),
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        fontFamily: 'Tajawal',
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        fontFamily: 'Tajawal',
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}
