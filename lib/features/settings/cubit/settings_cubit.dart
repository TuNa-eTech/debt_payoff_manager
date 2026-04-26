import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(const SettingsState()) {
    _init();
  }

  final SettingsRepository _settingsRepository;
  StreamSubscription<UserSettings>? _settingsSub;

  void _init() {
    _settingsSub = _settingsRepository.watchSettings().listen((settings) {
      emit(state.copyWith(settings: settings, isLoading: false));
    });
  }

  @override
  Future<void> close() {
    _settingsSub?.cancel();
    return super.close();
  }
}
