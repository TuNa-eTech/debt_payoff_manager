import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Supported locale metadata for the Phase 6 shell/settings i18n slice.
abstract final class AppLocale {
  static const String englishLocaleCode = 'en-US';
  static const String vietnameseLocaleCode = 'vi-VN';
  static const String fallbackLocaleCode = englishLocaleCode;

  static const Locale english = Locale('en');
  static const Locale vietnamese = Locale('vi');

  static const List<String> supportedLocaleCodes = <String>[
    englishLocaleCode,
    vietnameseLocaleCode,
  ];

  static String resolveSupportedLocaleCode(String? localeCode) {
    final normalized = localeCode?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return fallbackLocaleCode;
    }
    if (normalized.startsWith('vi')) {
      return vietnameseLocaleCode;
    }
    if (normalized.startsWith('en')) {
      return englishLocaleCode;
    }
    return fallbackLocaleCode;
  }

  static Locale flutterLocaleForCode(String? localeCode) {
    switch (resolveSupportedLocaleCode(localeCode)) {
      case vietnameseLocaleCode:
        return vietnamese;
      case englishLocaleCode:
      default:
        return english;
    }
  }

  static String localeCodeForDeviceLocale(Locale deviceLocale) {
    return deviceLocale.languageCode.toLowerCase() == 'vi'
        ? vietnameseLocaleCode
        : englishLocaleCode;
  }

  static String localeCodeForSystemLocale(Locale deviceLocale) {
    return localeCodeForDeviceLocale(deviceLocale);
  }

  static String intlFormatTag(String? localeCode) {
    switch (resolveSupportedLocaleCode(localeCode)) {
      case vietnameseLocaleCode:
        return 'vi_VN';
      case englishLocaleCode:
      default:
        return 'en_US';
    }
  }

  static String displayNameForLocaleCode(String? localeCode) {
    switch (resolveSupportedLocaleCode(localeCode)) {
      case vietnameseLocaleCode:
        return 'Vietnamese';
      case englishLocaleCode:
      default:
        return 'English';
    }
  }
}
