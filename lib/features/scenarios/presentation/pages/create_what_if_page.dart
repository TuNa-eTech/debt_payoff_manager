import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/i18n/strategy_l10n.dart';
import '../../../../core/models/scenario_lab_models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../domain/enums/strategy.dart';
import '../../../../l10n/app_localizations.dart';
import '../../cubit/scenario_lab_cubit.dart';
import '../../cubit/scenario_lab_state.dart';

class CreateWhatIfPage extends StatefulWidget {
  const CreateWhatIfPage({super.key});

  @override
  State<CreateWhatIfPage> createState() => _CreateWhatIfPageState();
}

class _CreateWhatIfPageState extends State<CreateWhatIfPage> {
  final TextEditingController _amountController = TextEditingController(
    text: '50',
  );
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ScenarioLabCubit, ScenarioLabState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.savedResult != current.savedResult,
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showSnackBar(state.errorMessage!, isError: true);
        }
        if (state.savedResult != null) {
          context.showSnackBar(l10n.scenarioLabSavedTitle);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.scenarioLabTitle)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.pagePaddingV,
                AppDimensions.pagePaddingH,
                AppDimensions.xxl,
              ),
              children: [
                Text(
                  l10n.scenarioLabSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                _TemplatePicker(state: state),
                const SizedBox(height: AppDimensions.lg),
                _AssumptionForm(
                  state: state,
                  amountController: _amountController,
                  nameController: _nameController,
                  onPreview: () => _preview(context, state),
                ),
                if (state.preview != null) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _PreviewCard(preview: state.preview!),
                ],
                if (state.savedResult != null) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _SavedActions(state: state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _preview(BuildContext context, ScenarioLabState state) async {
    final cubit = context.read<ScenarioLabCubit>();
    final name = _nameController.text.trim();
    switch (state.selectedTemplate) {
      case ScenarioLabTemplate.extraMonthly:
        final cents = _parseCurrencyCents(_amountController.text);
        await cubit.previewExtraMonthly(
          deltaExtraMonthlyCents: cents,
          name: name.isEmpty ? null : name,
        );
      case ScenarioLabTemplate.strategyChange:
        await cubit.previewStrategyChange(name: name.isEmpty ? null : name);
    }
  }

  int _parseCurrencyCents(String value) {
    final raw = CurrencyInputFormatter.strip(value);
    final parsed = double.tryParse(raw) ?? 0;
    return (parsed * 100).round();
  }
}

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({required this.state});

  final ScenarioLabState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ScenarioLabCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.scenarioLabTemplatesTitle, style: AppTextStyles.titleSmall),
        const SizedBox(height: AppDimensions.sm),
        _TemplateCard(
          title: l10n.scenarioLabTemplateExtraMonthly,
          subtitle: l10n.scenarioLabTemplateExtraMonthlySubtitle,
          icon: LucideIcons.walletCards,
          selected: state.selectedTemplate == ScenarioLabTemplate.extraMonthly,
          onTap: () => cubit.selectTemplate(ScenarioLabTemplate.extraMonthly),
        ),
        const SizedBox(height: AppDimensions.sm),
        _TemplateCard(
          title: l10n.scenarioLabTemplateStrategy,
          subtitle: l10n.scenarioLabTemplateStrategySubtitle,
          icon: LucideIcons.map,
          selected:
              state.selectedTemplate == ScenarioLabTemplate.strategyChange,
          onTap: () => cubit.selectTemplate(ScenarioLabTemplate.strategyChange),
        ),
        const SizedBox(height: AppDimensions.sm),
        _TemplateCard(
          title: l10n.scenarioLabTemplateBonus,
          subtitle: l10n.scenarioLabTemplateBonusSubtitle,
          icon: LucideIcons.badgeDollarSign,
          selected: false,
          enabled: false,
          trailing: AppChip.status(label: l10n.commonComingSoon),
          onTap: null,
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: AppCard(
        onTap: enabled ? onTap : null,
        color: selected
            ? AppColors.mdPrimaryContainer.withValues(alpha: 0.28)
            : AppColors.mdSurfaceContainerLow,
        borderColor: selected ? AppColors.mdPrimary : AppColors.whisperBorder,
        child: Row(
          children: [
            Icon(icon, color: AppColors.mdPrimary),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppDimensions.sm),
              trailing!,
            ] else if (selected)
              const Icon(LucideIcons.check, color: AppColors.mdPrimary),
          ],
        ),
      ),
    );
  }
}

class _AssumptionForm extends StatelessWidget {
  const _AssumptionForm({
    required this.state,
    required this.amountController,
    required this.nameController,
    required this.onPreview,
  });

  final ScenarioLabState state;
  final TextEditingController amountController;
  final TextEditingController nameController;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      color: AppColors.mdSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scenarioLabAssumptionTitle,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppDimensions.md),
          if (state.selectedTemplate == ScenarioLabTemplate.extraMonthly)
            AppTextField.currency(
              label: l10n.scenarioLabExtraAmountLabel,
              controller: amountController,
            )
          else
            _StrategyPicker(state: state),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            label: l10n.scenarioLabScenarioNameLabel,
            controller: nameController,
            hint: l10n.scenarioLabScenarioNameHint,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppDimensions.lg),
          AppButton.filled(
            label: l10n.scenarioLabPreviewAction,
            icon: LucideIcons.sparkles,
            loading: state.status == ScenarioLabStatus.loading,
            fullWidth: true,
            onPressed: state.isBusy ? null : onPreview,
          ),
        ],
      ),
    );
  }
}

class _StrategyPicker extends StatelessWidget {
  const _StrategyPicker({required this.state});

  final ScenarioLabState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ScenarioLabCubit>();
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        for (final strategy in [Strategy.snowball, Strategy.avalanche])
          AppChip.filter(
            label: strategy.localizedLabel(l10n),
            selected: state.selectedStrategy == strategy,
            onTap: () => cubit.selectStrategy(strategy),
          ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview});

  final ScenarioLabPreview preview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.userSettings;
    final currencyCode = settings?.currencyCode ?? 'USD';
    final localeCode = settings?.localeCode ?? 'en';
    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.trendingUp, color: AppColors.mdPrimary),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  l10n.scenarioLabPreviewTitle,
                  style: AppTextStyles.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            preview.summary,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          _ImpactGrid(
            items: [
              _ImpactItem(
                label: l10n.scenarioLabDebtFreeDate,
                value: preview.preview.projectedDebtFreeDate != null
                    ? AppFormatters.formatMonthYear(
                        preview.preview.projectedDebtFreeDate!,
                        localeCode: localeCode,
                      )
                    : l10n.scenariosCompareNotAvailable,
              ),
              _ImpactItem(
                label: l10n.scenarioLabProjectedInterest,
                value: AppFormatters.formatCents(
                  preview.preview.totalInterestProjected,
                  currencyCode: currencyCode,
                  localeCode: localeCode,
                ),
              ),
              _ImpactItem(
                label: l10n.scenarioLabMonthlyCommitment,
                value: AppFormatters.formatCents(
                  preview.previewMonthlyCommitment,
                  currencyCode: currencyCode,
                  localeCode: localeCode,
                ),
                delta: _moneyDelta(
                  preview.monthlyCommitmentDelta,
                  currencyCode,
                  localeCode,
                ),
              ),
              _ImpactItem(
                label: l10n.scenarioLabFirstTarget,
                value:
                    preview.firstTargetDebt?.name ??
                    l10n.scenarioLabNoTargetDebt,
              ),
              _ImpactItem(
                label: l10n.scenarioLabTimingImpact,
                value: _monthsImpactText(l10n, preview.monthsSaved),
              ),
              _ImpactItem(
                label: l10n.scenarioLabInterestImpact,
                value: _moneyImpactText(
                  l10n,
                  preview.interestSaved,
                  currencyCode,
                  localeCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<ScenarioLabCubit, ScenarioLabState>(
            builder: (context, state) {
              return AppButton.filled(
                label: l10n.scenarioLabSaveAction,
                icon: LucideIcons.save,
                loading: state.status == ScenarioLabStatus.saving,
                fullWidth: true,
                onPressed: state.isBusy
                    ? null
                    : () => context.read<ScenarioLabCubit>().savePreview(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _moneyDelta(int cents, String currencyCode, String localeCode) {
    if (cents == 0) return '';
    final amount = AppFormatters.formatCents(
      cents.abs(),
      currencyCode: currencyCode,
      localeCode: localeCode,
    );
    return cents > 0 ? '+$amount' : '-$amount';
  }

  String _monthsImpactText(AppLocalizations l10n, int? monthsSaved) {
    if (monthsSaved == null || monthsSaved == 0) {
      return l10n.scenarioLabNoTimingChange;
    }
    if (monthsSaved > 0) return l10n.scenarioLabMonthsEarlier(monthsSaved);
    return l10n.scenarioLabMonthsLater(monthsSaved.abs());
  }

  String _moneyImpactText(
    AppLocalizations l10n,
    int cents,
    String currencyCode,
    String localeCode,
  ) {
    if (cents == 0) return l10n.scenarioLabNoInterestChange;
    final amount = AppFormatters.formatCents(
      cents.abs(),
      currencyCode: currencyCode,
      localeCode: localeCode,
    );
    if (cents > 0) return l10n.scenarioLabInterestSaved(amount);
    return l10n.scenarioLabInterestAdded(amount);
  }
}

class _ImpactGrid extends StatelessWidget {
  const _ImpactGrid({required this.items});

  final List<_ImpactItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 520;
        final columnWidth = twoColumns
            ? (constraints.maxWidth - AppDimensions.sm) / 2
            : constraints.maxWidth;
        final itemHeight = twoColumns ? 112.0 : 96.0;
        return GridView.count(
          crossAxisCount: twoColumns ? 2 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimensions.sm,
          crossAxisSpacing: AppDimensions.sm,
          childAspectRatio: columnWidth / itemHeight,
          children: items,
        );
      },
    );
  }
}

class _ImpactItem extends StatelessWidget {
  const _ImpactItem({required this.label, required this.value, this.delta});

  final String label;
  final String value;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.mdSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.whisperBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (delta != null && delta!.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.xs),
                Text(
                  delta!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.mdPrimary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedActions extends StatelessWidget {
  const _SavedActions({required this.state});

  final ScenarioLabState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      color: AppColors.mdPrimaryContainer.withValues(alpha: 0.24),
      borderColor: AppColors.mdPrimary.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.scenarioLabSavedTitle, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.xs),
          Text(
            l10n.scenarioLabSavedBody(state.savedResult!.scenario.name),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [
              AppButton.filled(
                label: l10n.scenarioLabCompareAction,
                icon: LucideIcons.gitCompare,
                onPressed: () => context.push(AppRoutes.compareScenarios),
              ),
              AppButton.tonal(
                label: l10n.scenarioLabMakeActiveAction,
                icon: LucideIcons.checkCircle2,
                onPressed: () async {
                  await context
                      .read<ScenarioLabCubit>()
                      .activateSavedScenario();
                  if (context.mounted) context.pop(true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
