import '../../domain/enums/strategy.dart';
import '../../l10n/app_localizations.dart';

extension StrategyL10n on Strategy {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      Strategy.snowball => l10n.settingsStrategySnowball,
      Strategy.avalanche => l10n.settingsStrategyAvalanche,
      Strategy.custom => l10n.settingsStrategyCustom,
    };
  }
}
