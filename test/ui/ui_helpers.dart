import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/theme/app_theme.dart';

/// The phone frame of every UI test and golden (docs/test-cases/15-ui.md).
const phone = Size(390, 844);

bool _fontsLoaded = false;

/// Loads real fonts, so goldens show letters and icons instead of the test
/// font's square boxes: Roboto (the Material default, copied from the
/// Flutter SDK into `test/fonts/`, Apache 2.0), Noto Sans Bengali (from the
/// Noto project into `test/fonts/`, OFL 1.1), and every font of the asset
/// manifest (Lucide and Material icons). Called in `setUpAll` of golden
/// files only: each test file runs on its own, so other tests keep the
/// test font their layout checks were written for.
Future<void> loadUiFonts() async {
  if (_fontsLoaded) return;
  final roboto = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('test/fonts/Roboto-$weight.ttf').readAsBytesSync();
    roboto.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await roboto.load();

  // Bangla letters (the theme's fallback font; Noto Sans Bengali, OFL 1.1).
  final bangla = FontLoader('Noto Sans Bengali');
  for (final weight in ['Regular', 'Bold']) {
    final bytes = File(
      'test/fonts/NotoSansBengali-$weight.ttf',
    ).readAsBytesSync();
    bangla.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await bangla.load();

  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  _fontsLoaded = true;
}

/// Shows [child] as the app would: the app theme, the localizations, on a
/// [size] phone with [textScale]. [child] is placed in a [Scaffold] body
/// unless [scaffold] is false (for a widget that is a whole screen).
Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  Size size = phone,
  double textScale = 1,
  bool scaffold = true,
  Locale locale = const Locale('en'),
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: scaffold ? Scaffold(body: child) : child,
    ),
  );
  // A spinner or a skeleton never settles: one frame is drawn instead.
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// The golden file of [name], in `test/ui/goldens/`.
String golden(String name) => 'goldens/$name.png';

/// A golden of what is on screen now.
Future<void> expectGolden(WidgetTester tester, String name) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile(golden(name)));

/// Takes the golden [name] of what is on screen now, in the golden run only.
typedef Shot = Future<void> Function(String name);

/// One UI case, registered twice: its assertions alone (run everywhere, CI
/// too), and the same assertions with its goldens (tag `golden`, run on the
/// development PC; docs/test-cases/15-ui.md). The file calls
/// `setUpAll(loadUiFonts)`, so sizes are measured with the real fonts in
/// both.
void uiTest(
  String description,
  Future<void> Function(WidgetTester tester, Shot shot) body,
) {
  testWidgets(
    description,
    (tester) => atFixedTime(() => body(tester, (_) async {})),
  );
  testWidgets(
    '$description (golden)',
    tags: ['golden'],
    (tester) =>
        atFixedTime(() => body(tester, (name) => expectGolden(tester, name))),
  );
}

/// The time every UI test starts at: 15 Nov 2026, 12:23 in Bangladesh.
final uiTestStart = DateTime.utc(2026, 11, 15, 6, 23);

/// Runs [body] on a clock that starts at [uiTestStart] and moves with the
/// test clock, so a shown time (a check time, "today") is the same on
/// every run and a golden never depends on the day it is made.
Future<T> atFixedTime<T>(Future<T> Function() body) {
  final testClock = clock;
  final start = testClock.now();
  return withClock(
    Clock(() => uiTestStart.add(testClock.now().difference(start))),
    body,
  );
}

/// For a file whose goldens show screens started with the flow harness:
/// hides the flavour ribbon (mock, staging), which would cover the top
/// corner. Called in `main` before the tests.
void hideFlavourRibbon() {
  setUpAll(() => WidgetsApp.debugAllowBannerOverride = false);
  tearDownAll(() => WidgetsApp.debugAllowBannerOverride = true);
}

/// The flow harness draws at 3 × (1170 × 2532); goldens are 390 × 844 at 1 ×,
/// like the other UI goldens. The layout stays 390 × 844.
Future<void> atOneX(WidgetTester tester) async {
  tester.view.physicalSize = phone;
  tester.view.devicePixelRatio = 1;
  await tester.pumpAndSettle();
}

/// The style a [Text] is drawn with, after the inherited styles are merged.
TextStyle drawnStyle(WidgetTester tester, Finder text) {
  final paragraph = find.descendant(
    of: text,
    matching: find.byType(RichText),
    matchRoot: true,
  );
  final span = tester.widget<RichText>(paragraph.first).text as TextSpan;
  return span.style!;
}
