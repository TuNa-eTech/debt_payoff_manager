import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';

/// Main scaffold with bottom navigation bar.
///
/// Used as the shell for [StatefulShellRoute.indexedStack] in GoRouter.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: child.currentIndex,
        onDestinationSelected: (index) => child.goBranch(
          index,
          initialLocation: index == child.currentIndex,
        ),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.calendarCheck),
            selectedIcon: Icon(LucideIcons.calendarCheck, color: AppColors.primary),
            label: 'This Month',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.wallet),
            selectedIcon: Icon(LucideIcons.wallet, color: AppColors.primary),
            label: 'Debts',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.trendingDown),
            selectedIcon: Icon(LucideIcons.trendingDown, color: AppColors.primary),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
