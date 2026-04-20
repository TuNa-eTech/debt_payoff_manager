import 'package:flutter_test/flutter_test.dart';

import 'helpers/i18n_test_harness.dart';

void expectCompleted(I18nCliResult result) {
  expect(result.timedOut, isFalse, reason: result.debugSummary);
}

void main() {
  final Object skipReason = I18nTestWorkspace.hasToolScript
      ? false
      : 'tool/i18n.dart is not present yet';

  test('init scaffolds i18n on a repo without localization files', () async {
    final workspace = await I18nTestWorkspace.fromFixture('minimal_project');
    addTearDown(workspace.dispose);

    final result = await workspace.run(<String>['init']);

    expectCompleted(result);
    expect(result.exitCode, 0, reason: result.debugSummary);
    expect(workspace.file('l10n.yaml').existsSync(), isTrue);
    expect(workspace.file('lib/l10n/app_en.arb').existsSync(), isTrue);
    expect(workspace.file('lib/l10n/app_vi.arb').existsSync(), isTrue);

    final pubspec = workspace.readFile('pubspec.yaml');
    expect(pubspec, contains('flutter_localizations'));
    expect(pubspec, contains('intl'));
    expect(pubspec, contains('generate: true'));

    final english = workspace.readJson('lib/l10n/app_en.arb');
    final vietnamese = workspace.readJson('lib/l10n/app_vi.arb');
    expect((english['@@locale'] as String), startsWith('en'));
    expect((vietnamese['@@locale'] as String), startsWith('vi'));
    expect(english['appName'], 'Debt Payoff X');
    expect(vietnamese['appName'], 'Debt Payoff X');
    expect(
      (english['@appName'] as Map<String, dynamic>)['description'],
      isNotEmpty,
    );

    final invocations = workspace.readFlutterLogLines().join('\n');
    expect(invocations, contains('pub get'));
    expect(invocations, contains('gen-l10n'));
  }, skip: skipReason);

  test('init is idempotent', () async {
    final workspace = await I18nTestWorkspace.fromFixture('minimal_project');
    addTearDown(workspace.dispose);

    final first = await workspace.run(<String>['init', '--no-gen']);
    expectCompleted(first);
    expect(first.exitCode, 0, reason: first.debugSummary);

    final beforeSecondRun = <String, String>{
      'pubspec': workspace.readFile('pubspec.yaml'),
      'l10n': workspace.readFile('l10n.yaml'),
      'en': workspace.readFile('lib/l10n/app_en.arb'),
      'vi': workspace.readFile('lib/l10n/app_vi.arb'),
    };

    final second = await workspace.run(<String>['init', '--no-gen']);
    expectCompleted(second);
    expect(second.exitCode, 0, reason: second.debugSummary);
    expect(second.stdout, contains('i18n scaffold already initialized.'));
    expect(
      second.stdout,
      contains('Skipped Flutter localization generation (--no-gen).'),
    );

    expect(workspace.readFile('pubspec.yaml'), beforeSecondRun['pubspec']);
    expect(workspace.readFile('l10n.yaml'), beforeSecondRun['l10n']);
    expect(workspace.readFile('lib/l10n/app_en.arb'), beforeSecondRun['en']);
    expect(workspace.readFile('lib/l10n/app_vi.arb'), beforeSecondRun['vi']);
  }, skip: skipReason);

  test('init --force overwrites divergent scaffold files', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    workspace.file('l10n.yaml').writeAsStringSync('arb-dir: custom/l10n\n');
    workspace.file('lib/l10n/app_en.arb').writeAsStringSync('{not-valid-json');

    final result = await workspace.run(<String>['init', '--force', '--no-gen']);

    expectCompleted(result);
    expect(result.exitCode, 0, reason: result.debugSummary);
    expect(result.stdout, contains('Initialized i18n scaffold.'));
    expect(
      result.stdout,
      contains('Skipped Flutter localization generation (--no-gen).'),
    );
    expect(
      workspace.readFile('l10n.yaml'),
      contains('template-arb-file: app_en.arb'),
    );
    final english = workspace.readJson('lib/l10n/app_en.arb');
    expect(english['appName'], 'Debt Payoff X');
  }, skip: skipReason);

  test('add writes a new key to both ARB files', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    final result = await workspace.run(<String>[
      'add',
      '--key',
      'settingsLanguageLabel',
      '--en',
      'Language',
      '--vi',
      'Ngon ngu',
      '--desc',
      'Settings label for the selected application language.',
      '--no-gen',
    ]);

    expectCompleted(result);
    expect(result.exitCode, 0, reason: result.debugSummary);

    final english = workspace.readJson('lib/l10n/app_en.arb');
    final vietnamese = workspace.readJson('lib/l10n/app_vi.arb');

    expect(english['settingsLanguageLabel'], 'Language');
    expect(vietnamese['settingsLanguageLabel'], 'Ngon ngu');
    expect(
      (english['@settingsLanguageLabel']
          as Map<String, dynamic>)['description'],
      'Settings label for the selected application language.',
    );
    expect(
      (vietnamese['@settingsLanguageLabel']
          as Map<String, dynamic>)['description'],
      'Settings label for the selected application language.',
    );
  }, skip: skipReason);

  test('duplicate key fails by default and succeeds with overwrite', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    final originalEn = workspace.readFile('lib/l10n/app_en.arb');
    final originalVi = workspace.readFile('lib/l10n/app_vi.arb');

    final duplicate = await workspace.run(<String>[
      'add',
      '--key',
      'appName',
      '--en',
      'Debt Payoff X Pro',
      '--vi',
      'Debt Payoff X Pro',
      '--desc',
      'Updated app name.',
      '--no-gen',
    ]);

    expectCompleted(duplicate);
    expect(duplicate.exitCode, isNonZero);
    expect(duplicate.stderr, contains('already exists'));
    expect(workspace.readFile('lib/l10n/app_en.arb'), originalEn);
    expect(workspace.readFile('lib/l10n/app_vi.arb'), originalVi);

    final overwrite = await workspace.run(<String>[
      'add',
      '--key',
      'appName',
      '--en',
      'Debt Payoff X Pro',
      '--vi',
      'Debt Payoff X Pro',
      '--desc',
      'Updated app name.',
      '--overwrite',
      '--no-gen',
    ]);

    expect(overwrite.timedOut, isFalse, reason: overwrite.debugSummary);
    expect(overwrite.exitCode, 0, reason: overwrite.debugSummary);
    expect(
      workspace.readJson('lib/l10n/app_en.arb')['appName'],
      'Debt Payoff X Pro',
    );
    expect(
      workspace.readJson('lib/l10n/app_vi.arb')['appName'],
      'Debt Payoff X Pro',
    );
  }, skip: skipReason);

  test('overwrite can be a no-op and surfaces the unchanged result', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    final result = await workspace.run(<String>[
      'add',
      '--key',
      'appName',
      '--en',
      'Debt Payoff X',
      '--vi',
      'Debt Payoff X',
      '--desc',
      'Application name shown in localized UI.',
      '--overwrite',
    ]);

    expectCompleted(result);
    expect(result.exitCode, 0, reason: result.debugSummary);
    expect(
      result.stdout,
      contains(
        'Localization key "appName" already matches the requested values.',
      ),
    );
    expect(
      result.stdout,
      contains(
        'Skipped Flutter localization generation because no files changed.',
      ),
    );
  }, skip: skipReason);

  test('invalid key format fails without mutating ARB files', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    final originalEn = workspace.readFile('lib/l10n/app_en.arb');
    final originalVi = workspace.readFile('lib/l10n/app_vi.arb');

    final result = await workspace.run(<String>[
      'add',
      '--key',
      'settings_language_label',
      '--en',
      'Language',
      '--vi',
      'Ngon ngu',
      '--desc',
      'Settings label for the selected application language.',
      '--no-gen',
    ]);

    expectCompleted(result);
    expect(result.exitCode, isNonZero);
    expect(result.stderr, contains('lowerCamelCase'));
    expect(workspace.readFile('lib/l10n/app_en.arb'), originalEn);
    expect(workspace.readFile('lib/l10n/app_vi.arb'), originalVi);
  }, skip: skipReason);

  test('ICU braces are rejected for static string mode', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    final originalEn = workspace.readFile('lib/l10n/app_en.arb');
    final originalVi = workspace.readFile('lib/l10n/app_vi.arb');

    final result = await workspace.run(<String>[
      'add',
      '--key',
      'welcomeUser',
      '--en',
      'Hello {name}',
      '--vi',
      'Xin chao {name}',
      '--desc',
      'Welcome message addressed to a specific user.',
      '--no-gen',
    ]);

    expectCompleted(result);
    expect(result.exitCode, isNonZero);
    expect(
      result.stderr,
      contains('must not include ICU placeholders or braces'),
    );
    expect(workspace.readFile('lib/l10n/app_en.arb'), originalEn);
    expect(workspace.readFile('lib/l10n/app_vi.arb'), originalVi);
  }, skip: skipReason);

  test('--no-gen skips flutter invocation entirely', () async {
    final workspace = await I18nTestWorkspace.fromFixture('minimal_project');
    addTearDown(workspace.dispose);

    final result = await workspace.run(<String>['init', '--no-gen']);

    expectCompleted(result);
    expect(result.exitCode, 0, reason: result.debugSummary);
    expect(workspace.readFlutterLogLines(), isEmpty);
  }, skip: skipReason);

  test('rolls back ARB changes when flutter gen-l10n fails', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    final originalEn = workspace.readFile('lib/l10n/app_en.arb');
    final originalVi = workspace.readFile('lib/l10n/app_vi.arb');

    final result = await workspace.run(<String>[
      'add',
      '--key',
      'timelineEmptyStateTitle',
      '--en',
      'No timeline yet',
      '--vi',
      'Chua co timeline',
      '--desc',
      'Empty state title shown before the first recast.',
    ], failOnSubstring: 'gen-l10n');

    expectCompleted(result);
    expect(result.exitCode, isNonZero);
    expect(workspace.readFile('lib/l10n/app_en.arb'), originalEn);
    expect(workspace.readFile('lib/l10n/app_vi.arb'), originalVi);
    expect(workspace.readFlutterLogLines().join('\n'), contains('gen-l10n'));
  }, skip: skipReason);

  test('prefers the .fvm flutter binary over PATH flutter', () async {
    final workspace = await I18nTestWorkspace.fromFixture(
      'initialized_project',
    );
    addTearDown(workspace.dispose);

    final result = await workspace.run(
      <String>[
        'add',
        '--key',
        'dashboardHeaderTitle',
        '--en',
        'Dashboard',
        '--vi',
        'Bang dieu khien',
        '--desc',
        'Title shown at the top of the dashboard.',
      ],
      installPathFlutter: true,
      installFvmFlutter: true,
    );

    expectCompleted(result);
    expect(result.exitCode, 0, reason: result.debugSummary);
    final invocations = workspace.readFlutterLogLines();
    expect(invocations, isNotEmpty);
    expect(invocations.every((line) => line.startsWith('FVM|')), isTrue);
    expect(invocations.join('\n'), contains('gen-l10n'));
  }, skip: skipReason);
}
