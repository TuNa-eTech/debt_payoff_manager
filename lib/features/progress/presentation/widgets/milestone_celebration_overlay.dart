import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/milestone.dart';
import '../../../../domain/enums/milestone_type.dart';
import '../../../../l10n/app_localizations.dart';

/// Full-screen overlay that celebrates a newly earned milestone.
/// Auto-dismisses after 3 seconds or on tap.
class MilestoneCelebrationOverlay extends StatefulWidget {
  const MilestoneCelebrationOverlay({
    super.key,
    required this.milestone,
    required this.onDismiss,
  });

  final Milestone milestone;
  final VoidCallback onDismiss;

  @override
  State<MilestoneCelebrationOverlay> createState() =>
      _MilestoneCelebrationOverlayState();
}

class _MilestoneCelebrationOverlayState
    extends State<MilestoneCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _autoDismiss = Timer(const Duration(seconds: 3), widget.onDismiss);
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = _celebrationText(widget.milestone.type, l10n);
    final icon = _iconForType(widget.milestone.type);

    return GestureDetector(
      onTap: widget.onDismiss,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.mdSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: AppColors.mdPrimary),
                  const SizedBox(height: 20),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.milestone.type.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _celebrationText(MilestoneType type, AppLocalizations l10n) {
    return switch (type) {
      MilestoneType.firstPayment => l10n.milestoneCelebrationFirstPayment,
      MilestoneType.debtPaidOff => l10n.milestoneCelebrationDebtPaidOff,
      MilestoneType.allDebtFree => l10n.milestoneCelebrationAllDebtFree,
      MilestoneType.percentComplete25 => l10n.milestoneCelebrationProgress25,
      MilestoneType.percentComplete50 => l10n.milestoneCelebrationProgress50,
      MilestoneType.percentComplete75 => l10n.milestoneCelebrationProgress75,
      MilestoneType.streakMonths3 => l10n.milestoneCelebrationStreak3,
      MilestoneType.streakMonths6 => l10n.milestoneCelebrationStreak6,
      MilestoneType.streakMonths12 => l10n.milestoneCelebrationStreak12,
      _ => type.label,
    };
  }

  IconData _iconForType(MilestoneType type) {
    return switch (type) {
      MilestoneType.allDebtFree => Icons.celebration,
      MilestoneType.debtPaidOff => Icons.check_circle_outline,
      MilestoneType.firstPayment => Icons.star_outline,
      MilestoneType.streakMonths3 ||
      MilestoneType.streakMonths6 ||
      MilestoneType.streakMonths12 =>
        Icons.local_fire_department_outlined,
      MilestoneType.percentComplete25 ||
      MilestoneType.percentComplete50 ||
      MilestoneType.percentComplete75 =>
        Icons.flag_outlined,
      _ => Icons.emoji_events_outlined,
    };
  }
}
