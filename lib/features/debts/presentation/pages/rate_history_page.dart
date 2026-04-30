import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/entities/interest_rate_history.dart';
import '../../../../domain/repositories/interest_rate_history_repository.dart';

class RateHistoryPage extends StatefulWidget {
  const RateHistoryPage({super.key, required this.debtId});

  final String debtId;

  @override
  State<RateHistoryPage> createState() => _RateHistoryPageState();
}

class _RateHistoryPageState extends State<RateHistoryPage> {
  late final InterestRateHistoryRepository _repository;
  late final Stream<List<InterestRateHistory>> _stream;

  @override
  void initState() {
    super.initState();
    _repository = getIt<InterestRateHistoryRepository>();
    _stream = _repository.watchByDebtId(widget.debtId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.rateHistoryTitle),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle),
            onPressed: () => _showAddRateDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<InterestRateHistory>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rates = snapshot.data ?? [];

          if (rates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.trendingUp,
                      size: 64,
                      color: AppColors.mdOutline,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      context.l10n.rateHistoryEmpty,
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      context.l10n.rateHistoryEmptySubtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Sort: most recent first (by effectiveFrom desc)
          final sortedRates = List<InterestRateHistory>.of(rates)
            ..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical: AppDimensions.pagePaddingV,
            ),
            itemCount: sortedRates.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final rate = sortedRates[index];
              final today = DateTime.now();
              final isCurrent = rate.isActiveAt(today);
              final isUpcoming = rate.effectiveFrom.isAfter(today);

              return _RateHistoryCard(
                rate: rate,
                isCurrent: isCurrent,
                isUpcoming: isUpcoming,
                onEdit: () => _showEditRateDialog(context, rate),
                onDelete: () => _deleteRate(context, rate),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddRateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) =>
          _RateHistoryDialog(debtId: widget.debtId, repository: _repository),
    );
  }

  Future<void> _showEditRateDialog(
    BuildContext context,
    InterestRateHistory rate,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _RateHistoryDialog(
        debtId: widget.debtId,
        repository: _repository,
        initialRate: rate,
      ),
    );
  }

  Future<void> _deleteRate(
    BuildContext context,
    InterestRateHistory rate,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.rateHistoryDeleteTitle),
        content: Text(context.l10n.rateHistoryDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.mdError),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _repository.deleteRateHistory(rate.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.rateHistoryDeletedMsg)),
        );
      }
    }
  }
}

class _RateHistoryCard extends StatelessWidget {
  const _RateHistoryCard({
    required this.rate,
    required this.isCurrent,
    required this.isUpcoming,
    required this.onEdit,
    required this.onDelete,
  });

  final InterestRateHistory rate;
  final bool isCurrent;
  final bool isUpcoming;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: isCurrent
          ? AppColors.mdPrimaryContainer.withValues(alpha: 0.15)
          : AppColors.mdSurface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${(rate.apr * Decimal.fromInt(100)).toStringAsFixed(2)}%',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    if (isCurrent || isUpcoming) ...[
                      const SizedBox(width: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.mdPrimary
                              : AppColors.mdSurfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Text(
                          isCurrent
                              ? context.l10n.rateHistoryCurrent
                              : context.l10n.rateHistoryUpcoming,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isCurrent
                                ? AppColors.mdOnPrimary
                                : AppColors.mdOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  rate.effectiveTo != null
                      ? context.l10n.rateHistoryEffectiveToPeriod(
                          AppFormatters.formatDate(rate.effectiveFrom),
                          AppFormatters.formatDate(rate.effectiveTo!),
                        )
                      : context.l10n.rateHistoryEffectiveFromOnly(
                          AppFormatters.formatDate(rate.effectiveFrom),
                        ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
                if (rate.reason != null && rate.reason!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    rate.reason!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(context.l10n.commonEdit),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(context.l10n.commonDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateHistoryDialog extends StatefulWidget {
  const _RateHistoryDialog({
    required this.debtId,
    required this.repository,
    this.initialRate,
  });

  final String debtId;
  final InterestRateHistoryRepository repository;
  final InterestRateHistory? initialRate;

  @override
  State<_RateHistoryDialog> createState() => _RateHistoryDialogState();
}

class _RateHistoryDialogState extends State<_RateHistoryDialog> {
  late final TextEditingController _aprController;
  late final TextEditingController _reasonController;
  late DateTime _effectiveFrom;
  DateTime? _effectiveTo;
  bool _openEnded = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _aprController = TextEditingController(
      text: widget.initialRate != null
          ? (widget.initialRate!.apr * Decimal.fromInt(100)).toStringAsFixed(2)
          : '',
    );
    _reasonController = TextEditingController(
      text: widget.initialRate?.reason ?? '',
    );
    _effectiveFrom = widget.initialRate?.effectiveFrom ?? DateTime.now();
    _effectiveTo = widget.initialRate?.effectiveTo;
    _openEnded = _effectiveTo == null;
  }

  @override
  void dispose() {
    _aprController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialRate == null
            ? context.l10n.rateHistoryAddTitle
            : context.l10n.rateHistoryEditTitle,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _aprController,
                decoration: InputDecoration(
                  labelText: context.l10n.rateHistoryAprLabel,
                  hintText: 'e.g., 18.99',
                  suffixText: '%',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.commonRequired;
                  }
                  final apr = double.tryParse(value);
                  if (apr == null || apr < 0 || apr > 100) {
                    return context.l10n.rateHistoryAprInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InputDatePickerFormField(
                initialDate: _effectiveFrom,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateSaved: (date) {
                  setState(() => _effectiveFrom = date);
                },
                fieldLabelText: context.l10n.rateHistoryEffectiveFrom,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: Text(context.l10n.rateHistoryOpenEnded),
                value: _openEnded,
                onChanged: (v) => setState(() => _openEnded = v ?? false),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              if (!_openEnded) ...[
                const SizedBox(height: 8),
                InputDatePickerFormField(
                  initialDate:
                      _effectiveTo ??
                      _effectiveFrom.add(const Duration(days: 30)),
                  firstDate: _effectiveFrom.add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                  onDateSaved: (date) => _effectiveTo = date,
                  fieldLabelText: context.l10n.rateHistoryEffectiveTo,
                  selectableDayPredicate: (date) =>
                      date.isAfter(_effectiveFrom),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: context.l10n.rateHistoryReason,
                  hintText: context.l10n.rateHistoryReasonHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            widget.initialRate == null
                ? context.l10n.commonAdd
                : context.l10n.commonSave,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final apr = double.parse(_aprController.text) / 100;
    final rate = InterestRateHistory(
      id: widget.initialRate?.id ?? const Uuid().v4(),
      debtId: widget.debtId,
      apr: Decimal.parse(apr.toString()),
      effectiveFrom: _effectiveFrom,
      effectiveTo: _openEnded ? null : _effectiveTo,
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    );

    final nav = Navigator.of(context);
    final l10n = context.l10n;
    try {
      if (widget.initialRate == null) {
        await widget.repository.addRateHistory(rate);
      } else {
        await widget.repository.updateRateHistory(rate);
      }
      if (mounted) nav.pop();
    } catch (e) {
      if (!mounted) return;
      showDialog<void>(
        context: nav.context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.commonError),
          content: Text(e.toString()),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.commonOk),
            ),
          ],
        ),
      );
    }
  }
}
