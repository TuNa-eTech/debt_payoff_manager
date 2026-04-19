import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// App theme configuration — Material Structure · Notion Soul.
///
/// Uses MD3 components with Notion-inspired colour painting:
/// warm neutrals, whisper borders, near-black text on warm white backgrounds.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.mdPrimary,
      onPrimary: AppColors.mdOnPrimary,
      primaryContainer: AppColors.mdPrimaryContainer,
      onPrimaryContainer: AppColors.mdOnPrimaryContainer,
      secondary: AppColors.mdSecondary,
      onSecondary: AppColors.mdOnSecondary,
      secondaryContainer: AppColors.mdSecondaryContainer,
      onSecondaryContainer: AppColors.mdOnSecondaryContainer,
      tertiary: AppColors.mdTertiary,
      onTertiary: AppColors.mdOnTertiary,
      tertiaryContainer: AppColors.mdTertiaryContainer,
      onTertiaryContainer: AppColors.mdOnTertiaryContainer,
      error: AppColors.mdError,
      onError: AppColors.mdOnError,
      errorContainer: AppColors.mdErrorContainer,
      onErrorContainer: AppColors.mdOnErrorContainer,
      surface: AppColors.mdSurface,
      onSurface: AppColors.mdOnSurface,
      onSurfaceVariant: AppColors.mdOnSurfaceVariant,
      outline: AppColors.mdOutline,
      outlineVariant: AppColors.mdOutlineVariant,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: AppColors.mdInverseSurface,
      onInverseSurface: AppColors.mdInverseOnSurface,
      inversePrimary: AppColors.mdInversePrimary,
      surfaceContainerHighest: AppColors.mdSurfaceContainerHighest,
      surfaceContainerHigh: AppColors.mdSurfaceContainerHigh,
      surfaceContainer: AppColors.mdSurfaceContainer,
      surfaceContainerLow: AppColors.mdSurfaceContainerLow,
      surfaceContainerLowest: AppColors.mdSurfaceContainerLowest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.mdSurfaceContainerLow,

      // ── Typography ──
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ── AppBar — MD3 Top App Bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.mdSurface,
        foregroundColor: AppColors.mdOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
        ),
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.mdOnSurface,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.mdOnSurface,
          size: AppDimensions.iconLg,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.mdOnSurface,
          size: AppDimensions.iconLg,
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.mdOutlineVariant, width: 1),
        ),
      ),

      // ── Card — whisper border, no shadow ──
      cardTheme: CardThemeData(
        color: AppColors.mdSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.whisperBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mdSurfaceContainerLowest,
        floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.mdPrimary,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.mdOnSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.mdOnSurfaceVariant,
        ),
        errorStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.mdError),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.mdOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.mdOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.mdPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.mdError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.mdError, width: 2),
        ),
      ),

      // ── FilledButton (primary CTA — pill) ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mdPrimary,
          foregroundColor: AppColors.mdOnPrimary,
          disabledBackgroundColor: AppColors.mdOutlineVariant,
          disabledForegroundColor: AppColors.mdOnSurfaceVariant,
          elevation: 0,
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: 0,
          ),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ── ElevatedButton (maps to tonal in MD3) ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mdPrimaryContainer,
          foregroundColor: AppColors.mdOnPrimaryContainer,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ── OutlinedButton ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mdOnSurface,
          side: const BorderSide(color: AppColors.mdOutline, width: 1),
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ── TextButton ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mdPrimary,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
        ),
      ),

      // ── NavigationBar — MD3 with 80px height ──
      navigationBarTheme: NavigationBarThemeData(
        height: AppDimensions.navBarHeight,
        backgroundColor: AppColors.mdSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.mdPrimaryContainer,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navLabel.copyWith(color: AppColors.mdPrimary);
          }
          return AppTextStyles.navLabel.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.mdOnPrimaryContainer,
              size: AppDimensions.iconMd,
            );
          }
          return const IconThemeData(
            color: AppColors.mdOnSurfaceVariant,
            size: AppDimensions.iconMd,
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── BottomSheet — 24px top radii ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.mdSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBackgroundColor: AppColors.mdSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.bottomSheetTopRadius),
          ),
        ),
        dragHandleColor: AppColors.mdOutlineVariant,
        dragHandleSize: const Size(32, 4),
      ),

      // ── Dialog — Level 3 shadow, 16px radius ──
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.mdSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mdSurfaceContainerLow,
        selectedColor: AppColors.mdPrimaryContainer,
        labelStyle: AppTextStyles.labelMedium,
        side: const BorderSide(color: AppColors.mdOutlineVariant),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: AppColors.mdOutlineVariant,
        thickness: 1,
        space: 0,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.mdInverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.mdInverseOnSurface,
        ),
        actionTextColor: AppColors.mdInversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        elevation: 0,
      ),

      // ── ListTile ──
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        tileColor: Colors.transparent,
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodyMedium,
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mdOnPrimary;
          }
          return AppColors.mdOutline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mdPrimary;
          }
          return AppColors.mdSurfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return AppColors.mdOutline;
        }),
      ),

      // ── FloatingActionButton (Extended FAB) ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.mdPrimaryContainer,
        foregroundColor: AppColors.mdOnPrimaryContainer,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const StadiumBorder(),
        extendedTextStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColors.mdOnPrimaryContainer,
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedIconLabelSpacing: 8,
      ),

      // ── ProgressIndicator ──
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mdPrimary,
        linearTrackColor: AppColors.mdSurfaceContainerHighest,
        circularTrackColor: AppColors.mdSurfaceContainerHighest,
        linearMinHeight: 6,
      ),

      // ── Icon ──
      iconTheme: const IconThemeData(
        color: AppColors.mdOnSurface,
        size: AppDimensions.iconLg,
      ),
    );
  }
}
