// Renders the app icon and launch images from the app's own logo
// (lib/shared/widgets/app_logo.dart), with the real fonts the UI tests use.
//
// Run from the project root, then regenerate the platform files:
//   flutter test tool/app_icon/render_app_icon_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// It writes assets/icon/*.png; it is a tool, not part of the test suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/shared/design_system/theme/app_theme.dart';
import 'package:ziska_verify/shared/widgets/app_logo.dart';

import '../../test/ui/ui_helpers.dart';

void main() {
  setUpAll(loadUiFonts);

  /// Draws [AppLogo] [logoWidth] wide in the middle of a [side] square on
  /// [background] (null: transparent), and saves it as [path].
  Future<void> render(
    WidgetTester tester, {
    required String path,
    required double side,
    required double logoWidth,
    Color? background,
  }) async {
    tester.view
      ..physicalSize = Size(side, side)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      // The app's theme gives the logo the font it has in the app.
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: RepaintBoundary(
          key: boundary,
          // A material surface gives the text its themed style, as a
          // screen does in the app.
          child: Material(
            color: background ?? const Color(0x00000000),
            child: Center(child: AppLogo(width: logoWidth)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('app icon (legacy and iOS): the logo on white', (tester) async {
    await render(
      tester,
      path: 'assets/icon/app_icon.png',
      side: 1024,
      logoWidth: 820,
      background: const Color(0xFFFFFFFF),
    );
  });

  testWidgets('adaptive icon foreground: inside the 66 % safe zone', (
    tester,
  ) async {
    // The logo's corners stay inside the circle Android may cut to.
    await render(
      tester,
      path: 'assets/icon/app_icon_foreground.png',
      side: 1024,
      // 560 of 1024 (59 of 108 dp): the corners stay inside the 66 dp
      // circle of the mask.
      logoWidth: 560,
    );
  });

  testWidgets('launch screen logo (Android 12 rules: within the circle)', (
    tester,
  ) async {
    await render(
      tester,
      path: 'assets/icon/splash_logo.png',
      side: 1152,
      logoWidth: 640,
    );
  });
}
