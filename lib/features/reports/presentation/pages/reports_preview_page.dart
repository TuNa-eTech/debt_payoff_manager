import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/data_management_service.dart';
import '../../../../core/services/report_generator_service.dart';
import '../../../../core/services/share_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../domain/entities/timeline_projection.dart';
import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../../../plan/cubit/plan_timeline_cubit.dart';
import '../../../plan/cubit/plan_timeline_state.dart';

class ReportsPreviewPage extends StatefulWidget {
  const ReportsPreviewPage({super.key});

  @override
  State<ReportsPreviewPage> createState() => _ReportsPreviewPageState();
}

class _ReportsPreviewPageState extends State<ReportsPreviewPage> {
  final _reportGenerator = getIt<ReportGeneratorService>();
  final _dataManagement = getIt<DataManagementService>();
  final _shareLauncher = getIt<ShareLauncher>();
  bool _isGenerating = false;
  ReportTimeRange _selectedRange = ReportTimeRange.fullHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.mdSurfaceContainerLow,
      appBar: AppBar(title: Text(l10n.reportsPreviewPageTitle)),
      body: SafeArea(
        child: BlocBuilder<DebtsCubit, DebtsState>(
          builder: (context, debtsState) {
            if (debtsState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocBuilder<PlanTimelineCubit, PlanTimelineState>(
              builder: (context, planState) {
                if (planState.isLoading ||
                    planState.plan == null ||
                    planState.projection == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final settings = context.userSettings;
                if (settings == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildContent(
                  context,
                  debtsState: debtsState,
                  planState: planState,
                  settings: settings,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required DebtsState debtsState,
    required PlanTimelineState planState,
    required UserSettings settings,
  }) {
    final l10n = context.l10n;
    final projection = planState.projection!;
    final filteredMonths = _filterMonths(projection.months);
    final totalPayment = filteredMonths.fold<int>(
      0,
      (sum, month) => sum + month.totalPaymentThisMonth,
    );
    final totalInterest = filteredMonths.fold<int>(
      0,
      (sum, month) => sum + month.totalInterestThisMonth,
    );

    final debtFreeDate = projection.months.isNotEmpty
        ? AppFormatters.formatMonthYear(
            DateTime.parse('${projection.months.last.yearMonth}-01'),
            localeCode: settings.localeCode,
          )
        : l10n.reportsPreviewNotAvailable;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        AppDimensions.pagePaddingV,
        AppDimensions.pagePaddingH,
        AppDimensions.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(
            context,
            totalPayment: totalPayment,
            totalInterest: totalInterest,
            debtFreeDate: debtFreeDate,
            settings: settings,
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          Text(
            l10n.reportsPreviewRangeTitle,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: ReportTimeRange.values
                .map((range) {
                  return AppChip.filter(
                    key: AppTestKeys.reportsPreviewRange(range.fileStem),
                    label: _rangeLabel(context, range),
                    selected: _selectedRange == range,
                    onTap: () => setState(() => _selectedRange = range),
                    icon: LucideIcons.calendarDays,
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          Text(l10n.reportsPreviewTableTitle, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.md),
          if (filteredMonths.isEmpty)
            AppCard(
              color: AppColors.mdSurface,
              child: Text(
                l10n.reportsPreviewNotAvailable,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mdOnSurfaceVariant,
                ),
              ),
            )
          else
            ...filteredMonths.map(
              (month) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: _buildMonthPreviewRow(
                  context,
                  settings: settings,
                  month: month,
                ),
              ),
            ),
          const SizedBox(height: AppDimensions.xl),
          SizedBox(
            key: AppTestKeys.reportsPreviewExport,
            child: AppButton.filledLg(
              label: _isGenerating
                  ? l10n.reportsPreviewGenerating
                  : l10n.reportsPreviewExportToPdf,
              icon: LucideIcons.fileText,
              loading: _isGenerating,
              fullWidth: true,
              onPressed: _isGenerating
                  ? null
                  : () => _generateAndShareReport(
                      debtsState: debtsState,
                      planState: planState,
                      settings: settings,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required int totalPayment,
    required int totalInterest,
    required String debtFreeDate,
    required UserSettings settings,
  }) {
    return AppCard(
      color: AppColors.mdPrimaryContainer.withValues(alpha: 0.52),
      borderRadius: AppDimensions.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.reportsPreviewReportSummary,
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      context.l10n.reportsPreviewPageTitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppChip.status(
                label: _rangeLabel(context, _selectedRange),
                icon: LucideIcons.calendarDays,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Wrap(
            spacing: AppDimensions.xl,
            runSpacing: AppDimensions.md,
            children: [
              _buildSummaryMetric(
                context.l10n.reportsPreviewTotalPaid,
                AppFormatters.formatCents(
                  totalPayment,
                  currencyCode: settings.currencyCode,
                  localeCode: settings.localeCode,
                ),
              ),
              _buildSummaryMetric(
                context.l10n.reportsPreviewTotalInterest,
                AppFormatters.formatCents(
                  totalInterest,
                  currencyCode: settings.currencyCode,
                  localeCode: settings.localeCode,
                ),
              ),
              _buildSummaryMetric(
                context.l10n.reportsPreviewDebtFreeDate,
                debtFreeDate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.mdOnSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStat({required String label, required String value}) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mdOnSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPreviewRow(
    BuildContext context, {
    required UserSettings settings,
    required MonthProjection month,
  }) {
    final l10n = context.l10n;
    return AppCard(
      color: AppColors.mdSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppFormatters.formatMonthYear(
              DateTime.parse('${month.yearMonth}-01'),
              localeCode: settings.localeCode,
            ),
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.mdOnSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.xl,
            runSpacing: AppDimensions.sm,
            children: [
              _buildMonthStat(
                label: l10n.reportsPdfColPayment,
                value: AppFormatters.formatCents(
                  month.totalPaymentThisMonth,
                  currencyCode: settings.currencyCode,
                  localeCode: settings.localeCode,
                ),
              ),
              _buildMonthStat(
                label: l10n.reportsPdfColInterest,
                value: AppFormatters.formatCents(
                  month.totalInterestThisMonth,
                  currencyCode: settings.currencyCode,
                  localeCode: settings.localeCode,
                ),
              ),
              _buildMonthStat(
                label: l10n.reportsPdfColBalance,
                value: AppFormatters.formatCents(
                  month.totalBalanceEndOfMonth,
                  currencyCode: settings.currencyCode,
                  localeCode: settings.localeCode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndShareReport({
    required DebtsState debtsState,
    required PlanTimelineState planState,
    required UserSettings settings,
  }) async {
    setState(() => _isGenerating = true);
    try {
      final pdfBytes = await _reportGenerator.generateAmortizationReport(
        debts: debtsState.debts,
        plan: planState.plan!,
        projection: planState.projection!,
        settings: settings,
        l10n: context.l10n,
        range: _selectedRange,
      );

      final artifact = await _dataManagement.generatePdfExportArtifact(
        pdfBytes,
        filePrefix: 'debt_payoff_report_${_selectedRange.fileStem}',
      );
      await _shareLauncher.shareArtifact(artifact);
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          context.l10n.reportsPreviewGenerateFailed(_errorMessageFor(e)),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  List<MonthProjection> _filterMonths(List<MonthProjection> months) {
    return switch (_selectedRange) {
      ReportTimeRange.monthly => months.take(1).toList(growable: false),
      ReportTimeRange.yearly => months.take(12).toList(growable: false),
      ReportTimeRange.fullHistory => months,
    };
  }

  String _rangeLabel(BuildContext context, ReportTimeRange range) {
    final l10n = context.l10n;
    return switch (range) {
      ReportTimeRange.monthly => l10n.reportsPreviewRangeMonthly,
      ReportTimeRange.yearly => l10n.reportsPreviewRangeYearly,
      ReportTimeRange.fullHistory => l10n.reportsPreviewRangeFullHistory,
    };
  }

  String _errorMessageFor(Object error) {
    const prefixes = ['Exception: ', 'Bad state: ', 'Invalid argument(s): '];
    var message = error.toString();
    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length);
      }
    }
    return message;
  }
}
