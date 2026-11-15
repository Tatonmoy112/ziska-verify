import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verifying_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/lookup_messages.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/serial_input_formatter.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/app_empty_state.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';

/// The Verify tab (final.md Section 13.7).
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({required this.onOpenProfile, super.key});

  /// Switches to the Profile tab; wired by the router.
  final VoidCallback onOpenProfile;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _loader = VerifyingLoader();
  LookupWay _way = LookupWay.serial;

  @override
  void dispose() {
    _loader.stop();
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// The verification loader follows the lookup (Section 13.1.2).
  void _onStatus(LookupState state) {
    switch (state.status) {
      case LookupStatus.inProgress:
        _loader.start(context);
      case LookupStatus.completed:
        unawaited(_onCompleted(state));
      case _:
        _loader.stop();
    }
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    context.read<LookupBloc>().add(LookupRequested(_way, _input.text));
  }

  /// Opens the scanner. Its "Enter manually" comes back with `true`: the
  /// field then gets the focus, so the official can type straight away.
  Future<void> _scan() async {
    final manual = await context.pushNamed<bool>(RouteNames.scan);
    if (manual ?? false) {
      if (mounted) _inputFocus.requestFocus();
    }
  }

  void _clear() {
    _input.clear();
    context.read<LookupBloc>().add(const LookupCleared());
    setState(() {});
  }

  Future<void> _onCompleted(LookupState state) async {
    final view = ResultView(
      result: state.result!,
      input: state.checked!,
      origin: ResultOrigin.verify,
      formats: state.formats,
    );
    // A typed hidden code is never kept beyond this screen (Section 12.1).
    if (_way == LookupWay.hiddenCode) _input.clear();
    context.read<LookupBloc>().add(const LookupCleared());
    final opening = context.pushNamed(RouteNames.lookupResult, extra: view);
    // The result takes the loader's place.
    _loader.stop();
    await opening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<ProfileCubit>().state.profile;
    final canLookup = profile?.can('item:lookup') ?? false;
    // Entry points to the other features the role allows (Section 13.7).
    final tools = <Widget>[
      if (profile?.can('item:bulk_lookup') ?? false)
        _ToolTile(
          key: const Key('verify.tool.bulk'),
          icon: LucideIcons.layers,
          title: l10n.toolBulk,
          onTap: () => context.pushNamed(RouteNames.bulkLookup),
        ),
      if (profile?.can('incident:report') ?? false) ...[
        _ToolTile(
          key: const Key('verify.tool.report'),
          icon: LucideIcons.flag,
          title: l10n.toolReport,
          onTap: () => context.pushNamed(RouteNames.reportIncident),
        ),
        _ToolTile(
          key: const Key('verify.tool.myReports'),
          icon: LucideIcons.fileText,
          title: l10n.toolMyReports,
          onTap: () => context.pushNamed(RouteNames.myReports),
        ),
      ],
      if (profile?.can('retail_user:add') ?? false)
        _ToolTile(
          key: const Key('verify.tool.retailUsers'),
          icon: LucideIcons.store,
          title: l10n.toolRetailUsers,
          onTap: () => context.pushNamed(RouteNames.retailUsers),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            organisation: profile?.organisation ?? l10n.appTitle,
            name: profile?.name ?? '',
            onOpenProfile: widget.onOpenProfile,
          ),
          Expanded(
            child: canLookup
                ? BlocConsumer<LookupBloc, LookupState>(
                    listenWhen: (a, b) => a.status != b.status,
                    listener: (context, state) => _onStatus(state),
                    // Back waits while the one lookup runs.
                    builder: (context, state) => PopScope(
                      canPop: !state.isBusy,
                      child: _LookupForm(
                        state: state,
                        way: _way,
                        input: _input,
                        inputFocus: _inputFocus,
                        onScan: () => unawaited(_scan()),
                        onWayChanged: (way) => setState(() {
                          _way = way;
                          _input.clear();
                          context.read<LookupBloc>().add(const LookupCleared());
                        }),
                        onChanged: () => setState(() {}),
                        onVerify: _verify,
                        onClear: _clear,
                        tools: tools,
                      ),
                    ),
                  )
                : tools.isNotEmpty
                ? ListView(
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    children: [_ToolsSection(tools: tools)],
                  )
                : AppEmptyState(
                    icon: LucideIcons.lockKeyhole,
                    title: l10n.noFeaturesTitle,
                    body: l10n.noFeaturesBody,
                  ),
          ),
        ],
      ),
    );
  }
}

class _LookupForm extends StatelessWidget {
  const _LookupForm({
    required this.state,
    required this.way,
    required this.input,
    required this.inputFocus,
    required this.onScan,
    required this.onWayChanged,
    required this.onChanged,
    required this.onVerify,
    required this.onClear,
    required this.tools,
  });

  final LookupState state;
  final LookupWay way;
  final TextEditingController input;
  final FocusNode inputFocus;
  final VoidCallback onScan;
  final ValueChanged<LookupWay> onWayChanged;
  final VoidCallback onChanged;
  final VoidCallback onVerify;
  final VoidCallback onClear;
  final List<Widget> tools;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formats = state.formats;

    if (formats == null) {
      if (state.formatsFailure != null) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            children: [
              ErrorBanner(
                message:
                    '${l10n.formatsFailed} '
                    '${state.formatsFailure!.message(l10n)}',
                requestId: state.formatsFailure!.requestId,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.retry,
                onPressed: () =>
                    context.read<LookupBloc>().add(const FormatsRequested()),
              ),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final failure = state.failure;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.verifyItemTitle, style: AppTypography.headline),
                const SizedBox(height: AppSpacing.xxs),
                Text(l10n.verifyItemSubtitle, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<LookupWay>(
                  segments: [
                    ButtonSegment(
                      value: LookupWay.serial,
                      label: Text(l10n.waySerial),
                    ),
                    ButtonSegment(
                      value: LookupWay.hiddenCode,
                      label: Text(l10n.wayHiddenCode),
                    ),
                  ],
                  selected: {way},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => onWayChanged(s.single),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  fieldKey: const Key('verify.input'),
                  secret: way == LookupWay.hiddenCode,
                  label: way == LookupWay.serial
                      ? l10n.waySerial
                      : l10n.wayHiddenCode,
                  hint: way == LookupWay.serial
                      ? l10n.serialHint(formats.serialMaxDigits)
                      : l10n.hiddenCodeHint,
                  controller: input,
                  focusNode: inputFocus,
                  prefixIcon: way == LookupWay.serial
                      ? LucideIcons.hash
                      : LucideIcons.tag,
                  keyboardType: way == LookupWay.serial
                      ? TextInputType.number
                      : TextInputType.visiblePassword,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(64),
                    if (way == LookupWay.serial) const SerialInputFormatter(),
                  ],
                  textInputAction: TextInputAction.search,
                  errorText: state.status == LookupStatus.refused
                      ? refusedMessage(l10n, state.refused!, formats)
                      : null,
                  onChanged: (_) => onChanged(),
                  onSubmitted: (_) => onVerify(),
                ),
                if (state.status == LookupStatus.failed && failure != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  // A `429` counts down and goes away at 0.
                  FailureBanner(
                    failure: failure,
                    retryAt: state.retryAt,
                    message: lookupFailureMessage(l10n, failure),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _ButtonPair(
                  first: AppButton(
                    key: const Key('verify.submit'),
                    label: l10n.verifyButtonLookup,
                    loading: state.isBusy,
                    onPressed: input.text.isEmpty ? null : onVerify,
                  ),
                  second: AppButton(
                    label: l10n.clear,
                    variant: AppButtonVariant.outlined,
                    onPressed: state.isBusy ? null : onClear,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ScanCard(
          onTap: state.isBusy ? null : onScan,
        ),
        if (tools.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          _ToolsSection(tools: tools),
        ],
      ],
    );
  }
}

class _ToolsSection extends StatelessWidget {
  const _ToolsSection({required this.tools});

  final List<Widget> tools;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.toolsTitle, style: AppTypography.fieldLabel),
        const SizedBox(height: AppSpacing.xs),
        ...tools,
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.background,
        borderRadius: AppRadius.card,
        child: ListTile(
          onTap: onTap,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          title: Text(title, style: AppTypography.bodyStrong),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('verify.scan'),
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Stack(
          children: [
            // The Figma's large faint QR corner at the right edge.
            const PositionedDirectional(
              end: -AppSpacing.xl,
              bottom: -AppSpacing.xxl,
              child: ExcludeSemantics(
                child: Icon(
                  LucideIcons.qrCode,
                  key: Key('verify.scan.motif'),
                  size: 128,
                  color: AppColors.onPrimaryFaint,
                ),
              ),
            ),
            _scanCardContent(l10n),
          ],
        ),
      ),
    );
  }

  Widget _scanCardContent(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.15),
              borderRadius: AppRadius.input,
            ),
            child: const Icon(
              LucideIcons.qrCode,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.scanQrTitle,
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                Text(
                  l10n.scanQrSubtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.organisation,
    required this.name,
    required this.onOpenProfile,
  });

  final String organisation;
  final String name;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Stack(
        children: [
          // The Figma's faint honeycomb, strongest at the end.
          const Positioned.fill(
            child: PatternBackground(
              key: Key('verify.header.pattern'),
              color: AppColors.onPrimaryFaint,
              kind: PatternKind.hexagons,
              spacing: AppSpacing.xxxl,
              fade: PatternFade.towardStart,
            ),
          ),
          _headerContent(l10n),
        ],
      ),
    );
  }

  Widget _headerContent(AppLocalizations l10n) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.md,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.shieldCheck,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    organisation,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Material(
                  color: AppColors.onPrimary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.button,
                  child: IconButton(
                    onPressed: onOpenProfile,
                    icon: const Icon(LucideIcons.user),
                    color: AppColors.onPrimary,
                    tooltip: l10n.tabProfile,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.welcomeBack,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            Text(
              name,
              style: AppTypography.title.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two buttons side by side (3 : 2); one above the other at a large font,
/// so neither label is cut.
class _ButtonPair extends StatelessWidget {
  const _ButtonPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    if (isLargeText(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          const SizedBox(height: AppSpacing.sm),
          second,
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: 3, child: first),
        const SizedBox(width: AppSpacing.sm),
        Expanded(flex: 2, child: second),
      ],
    );
  }
}
