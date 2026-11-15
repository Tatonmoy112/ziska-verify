import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/app_logo.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';
import 'package:ziska_verify/shared/widgets/reference_text.dart';

/// Shown while the session is restored and the profile loads
/// (final.md Section 9.4). The router leaves it by itself.
///
/// The look follows the Figma Landing Page: a dot pattern at the top, the
/// logo on a white card with the app's name, and a navy glow at the bottom
/// holding the tagline and the status (progress, or the error with Retry).
/// The brand sits in the middle of the free space. The content always
/// spans the full width, so it is centred whatever it contains, and it
/// scrolls instead of overflowing on small screens, in landscape, or with
/// a large font size.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Widest the content gets, so tablets and landscape phones show a
  /// readable column instead of a stretched button.
  static const maxContentWidth = 480.0;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dark status bar icons on white; light navigation bar icons on the
      // navy glow.
      value: SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: AppColors.primaryDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = math.max(
              AppSpacing.screen,
              (constraints.maxWidth - maxContentWidth) / 2,
            );
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: constraints.maxHeight * 0.45,
                  child: PatternBackground(
                    key: const Key('splash.pattern'),
                    color: AppColors.textMuted.withValues(alpha: 0.22),
                    fade: PatternFade.down,
                  ),
                ),
                // The Scaffold body is loosely constrained: without
                // expanding, the scroll view (and so the content) would
                // shrink to the widest child and sit on the left.
                SizedBox.expand(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      // At least the screen height, so the free space can
                      // be shared out; taller when the content needs it
                      // (it then scrolls).
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) => _SplashContent(
                          state: state,
                          horizontal: horizontal,
                          insets: insets,
                          width: constraints.maxWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.state,
    required this.horizontal,
    required this.insets,
    required this.width,
  });

  final ProfileState state;
  final double horizontal;
  final EdgeInsets insets;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.status == ProfileStatus.failure
        ? state.failure
        : null;
    // spaceBetween with a spacer first puts equal gaps above and below the
    // brand: the brand is centred in the free space and the glow sits at
    // the bottom.
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: insets.top + AppSpacing.screen),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LogoCard(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.appSubtitle,
                key: const Key('splash.subtitle'),
                textAlign: TextAlign.center,
                style: AppTypography.subtitle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
        _Glow(
          key: const Key('splash.glow'),
          width: width,
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.xxxl + AppSpacing.xl,
            horizontal,
            AppSpacing.xxl + insets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.splashTagline,
                key: const Key('splash.tagline'),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (failure != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    failure.message(l10n),
                    key: const Key('splash.error'),
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                ReferenceText(
                  failure.requestId,
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                ),
                const SizedBox(height: AppSpacing.md),
                // White on the navy glow: the navy primary button would
                // disappear into it.
                AppButton(
                  key: const Key('splash.retry'),
                  label: l10n.retry,
                  variant: AppButtonVariant.tonal,
                  onPressed: () => context.read<ProfileCubit>().load(),
                ),
              ] else
                SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(
                    key: const Key('splash.progress'),
                    color: AppColors.onPrimary,
                    strokeWidth: 3,
                    semanticsLabel: l10n.loadingProfile,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The logo on a white card with a soft shadow (Figma Landing Page).
class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxs,
          AppSpacing.xxxl,
          AppSpacing.xxs,
          AppSpacing.xxs,
        ),
        child: AppLogo(key: Key('splash.logo'), width: 140),
      ),
    );
  }
}

/// The navy dome at the bottom of the Splash: a wide elliptical top with
/// a soft halo above it. It grows with its content, so the tagline, the
/// error and Retry are always on navy.
class _Glow extends StatelessWidget {
  const _Glow({
    required this.width,
    required this.padding,
    required this.child,
    super.key,
  });

  final double width;
  final EdgeInsets padding;
  final Widget child;

  static const _domeHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.elliptical(width / 2, _domeHeight),
            ),
          ),
          gradient: const RadialGradient(
            center: Alignment(0, 0.6),
            radius: 1.2,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          shadows: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 56,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
