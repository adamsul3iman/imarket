// lib/core/di/register_module.dart
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:imarket/main.dart'; // To get the global supabase client

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => supabase;
}