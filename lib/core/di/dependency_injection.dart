// lib/core/di/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import the generated file
import 'dependency_injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => getIt.init();