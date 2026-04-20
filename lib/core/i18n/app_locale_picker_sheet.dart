import 'package:flutter/material.dart';

import '../constants/app_test_keys.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'app_locale.dart';

typedef AppLocaleSelectionCallback = Future<void> Function(String localeCode);

Future<void> showAppLocalePickerSheet(
  BuildContext context, {
  required String selectedLocaleCode,
  required AppLocaleSelectionCallback onSelected,
}) async {
  final l10n = context.l10n;
  final normalizedCode = AppLocale.resolveSupportedLocaleCode(
    selectedLocaleCode,
  );

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      Future<void> selectLocale(String localeCode) async {
        if (localeCode == normalizedCode) {
          Navigator.pop(sheetContext);
          return;
        }

        await onSelected(localeCode);
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.lg,
                AppDimensions.pagePaddingH,
                AppDimensions.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.settingsLocaleSheetTitle,
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ),
            ListTile(
              key: AppTestKeys.settingsLocaleOptionEnglish,
              leading: Icon(
                normalizedCode == AppLocale.englishLocaleCode
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: AppColors.mdPrimary,
              ),
              title: Text(
                AppLocale.displayNameForLocaleCode(AppLocale.englishLocaleCode),
              ),
              onTap: () => selectLocale(AppLocale.englishLocaleCode),
            ),
            ListTile(
              key: AppTestKeys.settingsLocaleOptionVietnamese,
              leading: Icon(
                normalizedCode == AppLocale.vietnameseLocaleCode
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: AppColors.mdPrimary,
              ),
              title: Text(
                AppLocale.displayNameForLocaleCode(
                  AppLocale.vietnameseLocaleCode,
                ),
              ),
              onTap: () => selectLocale(AppLocale.vietnameseLocaleCode),
            ),
            const SizedBox(height: AppDimensions.md),
          ],
        ),
      );
    },
  );
}
