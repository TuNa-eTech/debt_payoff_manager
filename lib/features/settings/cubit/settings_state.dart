import 'package:equatable/equatable.dart';

import '../../../../domain/entities/user_settings.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.settings,
    this.isLoading = true,
  });

  final UserSettings? settings;
  final bool isLoading;

  SettingsState copyWith({
    UserSettings? settings,
    bool? isLoading,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading];
}
