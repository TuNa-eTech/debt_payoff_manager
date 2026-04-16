import 'package:flutter/material.dart';

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

  /// Screen width.
  double get screenWidth => mediaQuery.size.width;

  /// Screen height.
  double get screenHeight => mediaQuery.size.height;

  /// Bottom padding (safe area).
  double get bottomPadding => mediaQuery.padding.bottom;

  /// Top padding (status bar).
  double get topPadding => mediaQuery.padding.top;

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
