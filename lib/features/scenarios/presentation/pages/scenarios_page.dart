import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/entities/scenario.dart';
import '../../cubit/scenarios_cubit.dart';
import '../../cubit/scenarios_state.dart';

class ScenariosPage extends StatelessWidget {
  const ScenariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scenariosTitle),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.gitCompare),
            tooltip: l10n.scenariosCompareAction,
            onPressed: () => context.push(AppRoutes.compareScenarios),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plusCircle),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ScenariosCubit, ScenariosState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.scenarios.isEmpty) {
            return EmptyState(
              title: l10n.scenariosEmptyTitle,
              subtitle: l10n.scenariosEmptySubtitle,
              icon: LucideIcons.gitBranch,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical: AppDimensions.pagePaddingV,
            ),
            itemCount: state.scenarios.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final scenario = state.scenarios[index];
              return _ScenarioCard(
                scenario: scenario,
                isActive: scenario.id == state.activeScenarioId,
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ScenarioNameDialog(
        title: context.l10n.scenariosAddTitle,
        confirmLabel: context.l10n.commonAdd,
        onConfirm: (name) => context.read<ScenariosCubit>().addScenario(name),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario, required this.isActive});

  final Scenario scenario;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      color: isActive
          ? AppColors.mdPrimaryContainer.withValues(alpha: 0.2)
          : AppColors.mdSurface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scenario.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppDimensions.xs),
                Row(
                  children: [
                    if (scenario.isMain)
                      Padding(
                        padding: const EdgeInsets.only(right: AppDimensions.xs),
                        child: AppChip.status(label: l10n.scenariosMainBadge),
                      ),
                    if (isActive)
                      AppChip.status(
                        label: l10n.scenariosActiveBadge,
                        icon: LucideIcons.check,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<_ScenarioAction>(
            icon: const Icon(LucideIcons.moreVertical),
            onSelected: (action) => _onAction(context, action),
            itemBuilder: (context) => [
              if (!isActive)
                PopupMenuItem(
                  value: _ScenarioAction.setActive,
                  child: Text(l10n.scenariosActiveBadge),
                ),
              PopupMenuItem(
                value: _ScenarioAction.duplicate,
                child: Text(l10n.scenariosDuplicateTitle),
              ),
              PopupMenuItem(
                value: _ScenarioAction.copyDebts,
                child: Text(l10n.scenariosCopyDebtsTitle),
              ),
              if (!scenario.isMain)
                PopupMenuItem(
                  value: _ScenarioAction.delete,
                  child: Text(
                    l10n.scenariosDeleteConfirm,
                    style: TextStyle(color: AppColors.mdError),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onAction(BuildContext context, _ScenarioAction action) async {
    final cubit = context.read<ScenariosCubit>();
    final l10n = context.l10n;

    switch (action) {
      case _ScenarioAction.setActive:
        await cubit.setActive(scenario.id);
      case _ScenarioAction.duplicate:
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => _ScenarioNameDialog(
            title: l10n.scenariosDuplicateTitle,
            initialValue: '${scenario.name} (copy)',
            confirmLabel: l10n.commonSave,
            onConfirm: (name) => cubit.duplicateScenario(scenario.id, name),
          ),
        );
      case _ScenarioAction.delete:
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.scenariosDeleteConfirm),
            content: Text(l10n.scenariosDeleteMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mdError,
                ),
                child: Text(l10n.scenariosDeleteConfirm),
              ),
            ],
          ),
        );
        if (confirmed == true) await cubit.deleteScenario(scenario.id);
      case _ScenarioAction.copyDebts:
        if (!context.mounted) return;
        await _showCopyDebtsDialog(context, cubit);
    }
  }

  Future<void> _showCopyDebtsDialog(
    BuildContext context,
    ScenariosCubit cubit,
  ) async {
    final l10n = context.l10n;
    final allScenarios = cubit.state.scenarios
        .where((s) => s.id != scenario.id)
        .toList();
    if (allScenarios.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.scenariosNoOtherScenarios)));
      return;
    }
    Scenario? target = allScenarios.first;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(l10n.scenariosCopyDebtsTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: target!.id,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: allScenarios
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      setDialogState(() {
                        target = allScenarios.firstWhere((s) => s.id == id);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.scenariosCopyDebtsMessage(scenario.name, target!.name),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.scenariosCopyDebtsConfirm),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await cubit.copyDebtsToScenario(scenario.id, target!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.scenariosCopyDebtsSuccess)));
      }
    }
  }
}

enum _ScenarioAction { setActive, duplicate, copyDebts, delete }

class _ScenarioNameDialog extends StatefulWidget {
  const _ScenarioNameDialog({
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    this.initialValue,
  });

  final String title;
  final String confirmLabel;
  final String? initialValue;
  final void Function(String name) onConfirm;

  @override
  State<_ScenarioNameDialog> createState() => _ScenarioNameDialogState();
}

class _ScenarioNameDialogState extends State<_ScenarioNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: context.l10n.scenariosNameHint),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _confirm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(widget.confirmLabel)),
      ],
    );
  }

  void _confirm() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onConfirm(name);
    Navigator.pop(context);
  }
}
