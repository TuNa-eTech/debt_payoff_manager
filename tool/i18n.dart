import 'dart:io';

import 'src/i18n_command_runner.dart';
import 'src/i18n_project_service.dart';

Future<void> main(List<String> args) async {
  final exitCodeValue = await runI18nCommand(
    args,
    actions: I18nProjectActions(
      initProject: initProject,
      addStaticKey: addStaticKey,
    ),
  );

  exitCode = exitCodeValue;
}
