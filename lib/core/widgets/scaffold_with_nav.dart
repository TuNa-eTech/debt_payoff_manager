import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/app_test_keys.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Main scaffold with MD3 NavigationBar — 80px, Forest Green indicator.
///
/// Used as the shell for [StatefulShellRoute.indexedStack] in GoRouter.
/// Matches the 5-tab layout defined in the design prototype:
/// Tháng này · Khoản nợ · Kế hoạch · Tiến độ · Cài đặt
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.mdOutlineVariant, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: child.currentIndex,
          onDestinationSelected: (index) => child.goBranch(
            index,
            initialLocation: index == child.currentIndex,
          ),
          backgroundColor: AppColors.mdSurface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.mdPrimaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                LucideIcons.calendarCheck,
                key: AppTestKeys.navHomeTab,
                size: AppDimensions.iconMd,
              ),
              selectedIcon: Icon(
                LucideIcons.calendarCheck,
                size: AppDimensions.iconMd,
                color: AppColors.mdOnPrimaryContainer,
              ),
              label: l10n.navThisMonth,
            ),
            NavigationDestination(
              icon: Icon(
                LucideIcons.creditCard,
                key: AppTestKeys.navDebtsTab,
                size: AppDimensions.iconMd,
              ),
              selectedIcon: Icon(
                LucideIcons.creditCard,
                size: AppDimensions.iconMd,
                color: AppColors.mdOnPrimaryContainer,
              ),
              label: l10n.navDebts,
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.trendingDown, size: AppDimensions.iconMd),
              selectedIcon: Icon(
                LucideIcons.trendingDown,
                size: AppDimensions.iconMd,
                color: AppColors.mdOnPrimaryContainer,
              ),
              label: l10n.navPlan,
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.barChart2, size: AppDimensions.iconMd),
              selectedIcon: Icon(
                LucideIcons.barChart2,
                size: AppDimensions.iconMd,
                color: AppColors.mdOnPrimaryContainer,
              ),
              label: l10n.navProgress,
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings, size: AppDimensions.iconMd),
              selectedIcon: Icon(
                LucideIcons.settings,
                size: AppDimensions.iconMd,
                color: AppColors.mdOnPrimaryContainer,
              ),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
