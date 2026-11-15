import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/product_picture_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';

import '../fakes/fake_picture_images.dart';
import 'ui_helpers.dart';

/// The product picture card and the full-screen viewer (final.md Section
/// 13.1.4, decision 47): TC-UI-160 … -164, TC-LOOK-108 … -114, -117.
void main() {
  setUpAll(() async {
    await loadUiFonts();
    await FakePictureImages.prepare();
  });
  final l10n = lookupAppLocalizations(const Locale('en'));
  const url = 'https://pictures.example.com/53/9f2c.png';
  const name = 'Paracetamol 500';

  late FakePictureImages pictures;
  setUp(() {
    pictures = FakePictureImages();
    // Each test starts with no decoded picture: the memory image cache is
    // shared by every test of the file.
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  Future<void> card(WidgetTester tester, {String? pictureUrl = url}) => pumpUi(
    tester,
    ColoredBox(
      color: AppColors.surfaceMuted,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          ProductPictureCard(
            pictureUrl: pictureUrl,
            productName: name,
            pictures: pictures,
          ),
        ],
      ),
    ),
    size: const Size(390, 420),
    settle: false,
  );

  /// Lets the picture decode (real time, outside the test clock).
  Future<void> decode(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
  }

  final skeleton = find.byWidgetPredicate((w) => w is Skeletonizer);
  final picture = find.byWidgetPredicate(
    (w) => w is Image && w.semanticLabel == l10n.pictureOf(name),
  );

  uiTest('TC-UI-160 / TC-LOOK-109 picture card: loading', (tester, shot) async {
    pictures.delay = const Duration(seconds: 2);
    await card(tester);
    expect(find.text(l10n.pictureTitle.toUpperCase()), findsOneWidget);
    expect(find.byIcon(LucideIcons.camera), findsOneWidget);
    expect(skeleton, findsOneWidget);
    final box = tester.getSize(find.byType(AspectRatio));
    expect(box.width / box.height, closeTo(4 / 3, 0.01));
    await tester.pump(const Duration(milliseconds: 300));
    await shot('picture_loading');
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(skeleton, findsNothing);
    expect(picture, findsOneWidget);
  });

  uiTest('TC-UI-161 / TC-LOOK-108 picture card: loaded, whole', (
    tester,
    shot,
  ) async {
    await card(tester);
    await decode(tester);
    expect(pictures.asked, [Uri.parse(url)]);
    final image = tester.widget<Image>(picture);
    expect(image.fit, BoxFit.contain);
    final clip = tester.widget<ClipRRect>(
      find.ancestor(of: picture, matching: find.byType(ClipRRect)),
    );
    expect(clip.borderRadius, AppRadius.card);
    expect(skeleton, findsNothing);
    await shot('picture_loaded');
  });

  uiTest('TC-UI-162 / TC-LOOK-110 picture card: failed, then Try again', (
    tester,
    shot,
  ) async {
    pictures.failures = 1;
    await card(tester);
    await decode(tester);
    expect(find.text(l10n.pictureFailed), findsOneWidget);
    expect(find.text(l10n.retry), findsOneWidget);
    expect(tester.takeException(), isNull);
    await shot('picture_failed');

    await tester.tap(find.text(l10n.retry));
    await tester.pump();
    await decode(tester);
    expect(pictures.asked, hasLength(2));
    expect(find.text(l10n.pictureFailed), findsNothing);
    expect(picture, findsOneWidget);
  });

  uiTest('TC-UI-163 / TC-LOOK-111 picture card: no picture', (
    tester,
    shot,
  ) async {
    await card(tester, pictureUrl: null);
    await tester.pump();
    expect(find.text(l10n.pictureNone), findsOneWidget);
    expect(find.byIcon(LucideIcons.image), findsOneWidget);
    expect(pictures.asked, isEmpty);
    await shot('picture_none');
  });

  uiTest('TC-LOOK-112 an address that is not HTTPS is never asked', (
    tester,
    shot,
  ) async {
    await card(tester, pictureUrl: 'http://pictures.example.com/1.jpg');
    await tester.pump();
    expect(find.text(l10n.pictureNone), findsOneWidget);
    expect(pictures.asked, isEmpty);
  });

  uiTest('TC-UI-164 / TC-LOOK-113 the picture full screen', (
    tester,
    shot,
  ) async {
    await card(tester);
    await decode(tester);
    await tester.tap(picture);
    await tester.pumpAndSettle();
    await decode(tester);
    expect(find.byType(PictureViewer), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byTooltip(l10n.close), findsOneWidget);
    // Full size, not the card's smaller decode: zooming stays sharp.
    final full = tester
        .widget<Image>(
          find.descendant(
            of: find.byType(PictureViewer),
            matching: find.byType(Image),
          ),
        )
        .image;
    expect(full, isNot(isA<ResizeImage>()));
    await shot('picture_viewer');

    await tester.tap(find.byTooltip(l10n.close));
    await tester.pumpAndSettle();
    expect(find.byType(PictureViewer), findsNothing);
    expect(find.byType(ProductPictureCard), findsOneWidget);
  });

  uiTest('TC-LOOK-114 the picture read by TalkBack', (tester, shot) async {
    final semantics = tester.ensureSemantics();
    await card(tester);
    await decode(tester);
    expect(find.bySemanticsLabel(l10n.pictureOf(name)), findsWidgets);
    semantics.dispose();
  });

  uiTest('TC-LOOK-117 the picture decoded at the size shown', (
    tester,
    shot,
  ) async {
    await card(tester);
    final image = tester.widget<Image>(picture).image;
    expect(image, isA<ResizeImage>());
    final box = tester.getSize(find.byType(AspectRatio));
    expect((image as ResizeImage).width, box.width.round());
  });
}
