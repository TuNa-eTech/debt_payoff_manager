import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/entities/milestone.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import 'notification_service.dart';

class MilestoneNotificationService {
  MilestoneNotificationService({
    required NotificationService notificationService,
    required MilestoneRepository milestoneRepository,
    required SettingsRepository settingsRepository,
  }) : _notificationService = notificationService,
       _milestoneRepository = milestoneRepository,
       _settingsRepository = settingsRepository;

  final NotificationService _notificationService;
  final MilestoneRepository _milestoneRepository;
  final SettingsRepository _settingsRepository;

  StreamSubscription<UserSettings>? _settingsSubscription;
  StreamSubscription<List<Milestone>>? _milestoneSubscription;
  UserSettings? _settings;
  final Set<String> _handledMilestoneIds = <String>{};
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _settingsSubscription = _settingsRepository.watchSettings().listen((value) {
      _settings = value;
    });
    _milestoneSubscription = _milestoneRepository
        .watchUnseenMilestones()
        .listen((milestones) => unawaited(_notifyForMilestones(milestones)));

    unawaited(_primeSettings());
  }

  Future<void> dispose() async {
    await _settingsSubscription?.cancel();
    await _milestoneSubscription?.cancel();
    _settingsSubscription = null;
    _milestoneSubscription = null;
    _initialized = false;
  }

  Future<void> _primeSettings() async {
    _settings ??= await _settingsRepository.getSettings();
  }

  Future<void> _notifyForMilestones(List<Milestone> milestones) async {
    final settings = _settings ?? await _settingsRepository.getSettings();
    if (!settings.notifMilestone) return;

    final hasPermissions = await _notificationService.hasPermissions();
    if (!hasPermissions) return;

    final localeParts = settings.localeCode.split('-');
    final locale = localeParts.length > 1
        ? Locale(localeParts[0], localeParts[1])
        : Locale(localeParts[0]);
    final l10n = lookupAppLocalizations(locale);

    for (final milestone in milestones) {
      if (_handledMilestoneIds.contains(milestone.id)) {
        continue;
      }
      _handledMilestoneIds.add(milestone.id);

      await _notificationService.showNotification(
        id: milestone.id.hashCode,
        title: l10n.notificationMilestoneTitle,
        body: l10n.notificationMilestoneBody,
        payload: 'milestone_id=${milestone.id}',
      );
      await _milestoneRepository.markSeen(milestone.id);
    }
  }
}
