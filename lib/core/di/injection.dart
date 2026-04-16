import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initialize dependency injection.
///
/// Call this in `main()` before `runApp()`.
@InjectableInit()
void configureDependencies() => getIt.init();
