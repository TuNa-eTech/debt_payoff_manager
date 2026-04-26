import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_settings.dart';
import '../../features/settings/cubit/settings_cubit.dart';
import '../../l10n/app_localizations.dart';

/// Extensions on [BuildContext] for convenient access to theme and media.
extension ContextExtensions on BuildContext {
  /// Access current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Access current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Access current localized strings.
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    assert(
      localizations != null,
      'AppLocalizations not found in BuildContext. '
      'Did you forget to configure MaterialApp.localizationsDelegates?',
    );
    return localizations!;
  }

  /// Screen width.
  double get screenWidth => mediaQuery.size.width;

  /// Screen height.
  double get screenHeight => mediaQuery.size.height;

  /// Bottom padding (safe area).
  double get bottomPadding => mediaQuery.padding.bottom;

  /// Top padding (status bar).
  double get topPadding => mediaQuery.padding.top;

  /// Access current user settings.
  UserSettings? get userSettings => watch<SettingsCubit>().state.settings;

  /// Access current user settings without listening (for event handlers).
  UserSettings? get readSettings => read<SettingsCubit>().state.settings;

  /// Show a snackbar with [message].
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
