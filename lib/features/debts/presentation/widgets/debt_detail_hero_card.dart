import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/debt.dart';
import '../debt_ui_utils.dart';

class DebtDetailHeroCard extends StatelessWidget {
  const DebtDetailHeroCard({super.key, required this.debt});

  final Debt debt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = debtProgress(debt);
    final iconColor = debtTypeColor(debt.type);
    final isOverdueDebt = isDebtOverdue(debt);
    final statusBackgroundColor = isOverdueDebt
        ? AppColors.mdErrorContainer
        : Colors.white.withValues(alpha: 0.16);
    final statusForegroundColor = isOverdueDebt
        ? AppColors.mdOnErrorContainer
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.mdPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(debtTypeIcon(debt.type), color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    debt.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  debtStatusLabel(debt.status, l10n, debt: debt),
                  style: TextStyle(color: statusForegroundColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.debtDetailCurrentBalance,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
            ),
          ),
          Text(
            AppFormatters.formatCents(debt.currentBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              fontFamily: 'Geist',
              letterSpacing: -1,
            ),
          ),
          Text(
            l10n.debtDetailOriginalPrincipalValue(
              AppFormatters.formatCents(debt.originalPrincipal),
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.debtDetailProgressComplete((progress * 100).round()),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                ),
              ),
              Text(
                debtTypeDisplayName(debt.type, l10n),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            color: AppColors.mdPrimaryContainer,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.debtDetailApr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.formatApr(
                          double.parse(debt.apr.toString()),
                        ),
                        style: TextStyle(
                          color: iconColor == AppColors.mdError
                              ? Colors.white
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.debtDetailMinimumPayment,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.formatCents(debt.minimumPayment),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
