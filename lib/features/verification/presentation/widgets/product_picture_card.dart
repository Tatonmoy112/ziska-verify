import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ziska_verify/core/services/picture/picture_images.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// The product picture on a genuine result (final.md §13.1,
/// decision 47): loading, the picture whole, a failure with Try again, or a
/// placeholder when there is none. A tap opens it full screen.
class ProductPictureCard extends StatefulWidget {
  const ProductPictureCard({
    required this.pictureUrl,
    required this.productName,
    required this.pictures,
    super.key,
  });

  /// `item.product.picture_url`; `null`, or not `https://`, is no picture.
  final String? pictureUrl;
  final String productName;
  final PictureImages pictures;

  @override
  State<ProductPictureCard> createState() => _ProductPictureCardState();
}

class _ProductPictureCardState extends State<ProductPictureCard> {
  /// The picture as the service gives it (full size, for the full-screen
  /// view) and at the size shown in the card. Asked of the service again on
  /// Try again.
  ImageProvider? _source;
  ImageProvider? _image;

  ImageProvider _imageFor(Uri address, int width) =>
      _image ??= ResizeImage.resizeIfNeeded(
        width,
        null,
        _source ??= widget.pictures.of(address),
      );

  Future<void> _retry() async {
    await _image?.evict();
    await _source?.evict();
    setState(() => _image = _source = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final address = pictureAddress(widget.pictureUrl);
    final label = l10n.pictureOf(widget.productName);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.pictureTitle.toUpperCase(),
                    style: AppTypography.sectionTitle,
                  ),
                ),
                const Icon(
                  LucideIcons.camera,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: AppRadius.card,
                child: ColoredBox(
                  color: AppColors.surfaceMuted,
                  child: address == null
                      ? _Placeholder(text: l10n.pictureNone)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // Decoded at the size shown, not at its full
                            // size (up to 1600 px, 5 MB).
                            final width =
                                (constraints.maxWidth *
                                        MediaQuery.devicePixelRatioOf(context))
                                    .round();
                            final image = _imageFor(address, width);
                            return Semantics(
                              button: true,
                              onTapHint: l10n.pictureOpenHint,
                              child: InkWell(
                                // Full size, so zooming stays sharp.
                                onTap: () => _open(context, _source!, label),
                                child: Image(
                                  image: image,
                                  fit: BoxFit.contain,
                                  semanticLabel: label,
                                  frameBuilder: (context, child, frame, sync) =>
                                      frame == null && !sync
                                      ? const _Loading()
                                      : child,
                                  errorBuilder: (context, _, _) => _Placeholder(
                                    text: l10n.pictureFailed,
                                    onRetry: _retry,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, ImageProvider image, String label) =>
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => PictureViewer(image: image, label: label),
        ),
      );
}

/// The picture full screen, with pinch zoom (final.md §13.1).
class PictureViewer extends StatelessWidget {
  const PictureViewer({required this.image, required this.label, super.key});

  final ImageProvider image;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scrim,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.scrim,
        foregroundColor: AppColors.onPrimary,
        titleTextStyle: Theme.of(
          context,
        ).appBarTheme.titleTextStyle?.copyWith(color: AppColors.onPrimary),
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          maxScale: 5,
          child: Center(
            child: Image(
              image: image,
              fit: BoxFit.contain,
              semanticLabel: label,
              errorBuilder: (context, _, _) =>
                  _Placeholder(text: l10n.pictureFailed),
            ),
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Skeletonizer(
    child: Skeleton.leaf(
      child: SizedBox.expand(child: ColoredBox(color: AppColors.border)),
    ),
  );
}

/// The Figma's empty-picture box: diagonal stripes, a picture icon, and
/// [text]; with [onRetry], a Try again button.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomPaint(
      painter: const _Stripes(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.image,
                size: 32,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                text,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.retry,
                  icon: LucideIcons.refreshCw,
                  variant: AppButtonVariant.outlined,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stripes extends CustomPainter {
  const _Stripes();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = AppSpacing.xxs;
    // Lines going up to the right, one gap apart.
    for (var x = -size.height; x < size.width; x += AppSpacing.md) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_Stripes oldDelegate) => false;
}
