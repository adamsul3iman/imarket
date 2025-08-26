import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// The import for 'main.dart' is no longer needed

@module
abstract class RegisterModule {
  @lazySingleton
  // FIX: Changed 'supabase' to the correct 'Supabase.instance.client'
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();
}