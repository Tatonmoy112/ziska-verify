import 'dart:async';
import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verifying_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/live_qr_camera.dart';
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
import 'package:ziska_verify/shared/widgets/navy_status_bar.dart';
import 'package:ziska_verify/shared/widgets/pattern_background.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// The Check tab (final.md Sections 13.1.2, 13.7). With `item:lookup` it
/// opens on the camera: a read QR is the trigger, sent at once as
/// `POST lookups` with no button. A serial is typed under the camera.
///
/// The camera runs only while it can be seen: the tab shown and not
/// covered (the shell and the navigator turn the tab's tickers off), the
/// app in the foreground, and no scan result or failure holding it.
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({
    required this.onOpenProfile,
    required this.scanner,
    required this.onOpenSettings,
    super.key,
  });

  /// Switches to the Profile tab; wired by the router.
  final VoidCallback onOpenProfile;
  final ScannerService scanner;

  /// Opens the phone's settings, when the camera was refused.
  final Future<bool> Function() onOpenSettings;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen>
    with WidgetsBindingObserver {
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _loader = VerifyingLoader();
  final LookupWay _way = LookupWay.serial;

  /// Made when the role may check one item; the camera starts with it.
  ScannerSession? _session;
  bool _running = true;
  bool _visible = true;
  bool _resumed = true;

  /// A scan's result is open, a scan failed (Scan again starts it), or a
  /// tool opened from here is on top.
  bool _held = false;

  /// How the last lookup was asked: a scan's messages show on the camera,
  /// a typed serial's under its field.
  LookupWay _lastWay = LookupWay.serial;

  /// The same code held in front of the camera is read once.
  String? _lastRaw;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Back from a scanned code's result: its window ([_afterResult]) starts
  /// then, so a pack still in front of the camera is not checked again by
  /// itself (guide §4.3: "Do not send the same QR twice in a row while it
  /// stays in front of the camera").
  bool _backFromResult = false;

  /// How long the same code is not read again while scanning.
  static const _repeat = Duration(seconds: 3);

  /// How long the same code is not read again after its result closes; it
  /// also covers a slow camera start.
  static const _afterResult = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TickerMode.valuesOf(context).enabled;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loader.stop();
    unawaited(_session?.dispose());
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// Starts or stops the camera so it runs exactly while it can be seen.
  void _sync() {
    final session = _session;
    if (session == null) return;
    final run = _visible && _resumed && !_held;
    if (run == _running) return;
    _running = run;
    unawaited(run ? session.start() : session.stop());
  }

  void _hold(bool held) {
    _held = held;
    _sync();
  }

  /// The check loader follows the lookup (Section 13.1.2).
  void _onStatus(LookupState state) {
    switch (state.status) {
      case LookupStatus.inProgress:
        _loader.start(context);
      case LookupStatus.completed:
        unawaited(_onCompleted(state));
      case LookupStatus.failed:
        _loader.stop();
        // The camera reads a code once until it restarts: it waits, and
        // Scan again starts it, so the same QR can be sent again. Never by
        // itself, so nothing is sent again and again while offline.
        if (_lastWay == LookupWay.qr) _hold(true);
      case _:
        _loader.stop();
    }
  }

  /// A QR read by the camera: sent at once (guide section 4.2).
  void _onCode(String raw) {
    final bloc = context.read<LookupBloc>();
    if (_held || bloc.state.isBusy || bloc.state.formats == null) return;
    final now = clock.now();
    final window = _backFromResult ? _afterResult : _repeat;
    if (raw == _lastRaw && now.difference(_lastAt) < window) return;
    _backFromResult = false;
    _lastRaw = raw;
    _lastAt = now;
    _lastWay = LookupWay.qr;
    FocusScope.of(context).unfocus();
    bloc.add(LookupRequested(LookupWay.qr, raw));
  }

  /// After a failed scan: the camera starts again for the same QR.
  void _scanAgain() {
    _lastRaw = null;
    _backFromResult = false;
    context.read<LookupBloc>().add(const LookupCleared());
    _hold(false);
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    _lastWay = LookupWay.serial;
    context.read<LookupBloc>().add(LookupRequested(_way, _input.text));
  }

  /// The serial field changed. A refused serial's message is about the text
  /// that was there, so it goes with it (finding F-1). A failure after
  /// sending ("may already be recorded") is about the check: it stays.
  void _onTyped(BuildContext context) {
    final bloc = context.read<LookupBloc>();
    if (_lastWay == LookupWay.serial &&
        bloc.state.status == LookupStatus.refused) {
      bloc.add(const LookupCleared());
    }
    setState(() {});
  }

  void _clear() {
    _input.clear();
    context.read<LookupBloc>().add(const LookupCleared());
    setState(() {});
  }

  /// A tool opened from here: the camera waits until it is closed.
  Future<void> _open(String route) async {
    _hold(true);
    await context.pushNamed(route);
    if (!mounted) return;
    _hold(false);
  }

  Future<void> _onCompleted(LookupState state) async {
    final view = ResultView(
      result: state.result!,
      input: state.checked!,
      origin: _lastWay == LookupWay.qr
          ? ResultOrigin.scanner
          : ResultOrigin.verify,
      formats: state.formats,
    );

    _hold(true);
    context.read<LookupBloc>().add(const LookupCleared());
    final opening = context.pushNamed(RouteNames.lookupResult, extra: view);
    // The result takes the loader's place.
    _loader.stop();
    await opening;
    if (!mounted) return;
    // A scanned code just checked is kept: its window starts now, as the
    // camera starts again and may still see it. After a typed serial,
    // nothing is held back.
    if (view.origin == ResultOrigin.scanner) {
      _lastAt = clock.now();
      _backFromResult = true;
    } else {
      _lastRaw = null;
    }
    _hold(false);
  }

  /// The camera's view of the lookup: only a scan's messages show on it.
  LiveQrCamera _camera(
    BuildContext context,
    LookupState state,
    ScannerSession session,
  ) {
    final l10n = AppLocalizations.of(context);
    final formats = state.formats;
    final scan = _lastWay == LookupWay.qr;
    final failed = scan && state.status == LookupStatus.failed;
    final message = switch (state.status) {
      // The card under the camera has the error and Try again.
      _ when formats == null && state.formatsFailure != null =>
        l10n.scanNotReady,
      LookupStatus.refused when scan && formats != null => refusedMessage(
        l10n,
        state.refused!,
        formats,
      ),
      LookupStatus.failed when scan => lookupFailureMessage(
        l10n,
        state.failure!,
      ),
      _ => null,
    };
    return LiveQrCamera(
      session: session,
      height: math.max(300, MediaQuery.sizeOf(context).height * 0.42),
      onCode: _onCode,
      onOpenSettings: widget.onOpenSettings,
      busy: scan && state.isBusy,
      message: message,
      requestId: failed ? state.failure?.requestId : null,
      retryAt: failed ? state.retryAt : null,
      failed: failed,
      onScanAgain: _scanAgain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<ProfileCubit>().state.profile;
    final canLookup = profile?.canLookup ?? false;
    // Entry points to the other features the role allows (Section 13.7).
    final tools = <Widget>[
      if (profile?.canBulkLookup ?? false)
        _ToolTile(
          key: const Key('verify.tool.bulk'),
          icon: LucideIcons.layers,
          title: l10n.scannerModeTitle,
          onTap: () => unawaited(_open(RouteNames.scannerMode)),
        ),
      if (profile?.canBulkLookup ?? false)
        _ToolTile(
          key: const Key('verify.tool.serials'),
          icon: LucideIcons.listOrdered,
          title: l10n.serialStackTitle,
          onTap: () => unawaited(_open(RouteNames.serialStack)),
        ),
      if (profile?.canReport ?? false) ...[
        _ToolTile(
          key: const Key('verify.tool.report'),
          icon: LucideIcons.flag,
          title: l10n.toolReport,
          onTap: () => unawaited(_open(RouteNames.reportIncident)),
        ),
        _ToolTile(
          key: const Key('verify.tool.myReports'),
          icon: LucideIcons.fileText,
          title: l10n.toolMyReports,
          onTap: () => unawaited(_open(RouteNames.myReports)),
        ),
      ],
    ];

    // At a large font, or with the phone on its side, the header scrolls
    // with the page: fixed above it, it could take most of the screen
    // (TC-ERR-045; finding F-8, half the height in landscape).
    final scrollingHeader =
        isLargeText(context) ||
        MediaQuery.orientationOf(context) == Orientation.landscape;
    if (!canLookup && scrollingHeader) {
      return NavyStatusBar(
        child: Scaffold(
          backgroundColor: AppColors.surfaceMuted,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(
                organisation: profile?.organisation ?? l10n.appTitle,
                name: profile?.name ?? '',
                onOpenProfile: widget.onOpenProfile,
              ),
              if (tools.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: _ToolsSection(tools: tools),
                )
              else
                AppEmptyState(
                  icon: LucideIcons.lockKeyhole,
                  title: l10n.noFeaturesTitle,
                  body: l10n.noFeaturesBody,
                ),
            ],
          ),
        ),
      );
    }
    final session = canLookup
        ? _session ??= widget.scanner.createSession()
        : null;
    final header = _Header(
      organisation: profile?.organisation ?? l10n.appTitle,
      name: profile?.name ?? '',
      onOpenProfile: widget.onOpenProfile,
    );
    return NavyStatusBar(
      scrim: scrollingHeader,
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!scrollingHeader) header,
            Expanded(
              child: session != null
                  ? BlocConsumer<LookupBloc, LookupState>(
                      listenWhen: (a, b) => a.status != b.status,
                      listener: (context, state) => _onStatus(state),
                      // Back waits while the one lookup runs.
                      builder: (context, state) => PopScope(
                        canPop: !state.isBusy,
                        child: _LookupForm(
                          state: state,
                          way: _way,
                          typed: _lastWay == LookupWay.serial,
                          camera: _camera(context, state, session),
                          input: _input,
                          inputFocus: _inputFocus,
                          onChanged: () => _onTyped(context),
                          onVerify: _verify,
                          onClear: _clear,
                          tools: tools,
                          header: scrollingHeader ? header : null,
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
      ),
    );
  }
}

class _LookupForm extends StatelessWidget {
  const _LookupForm({
    required this.state,
    required this.way,
    required this.typed,
    required this.camera,
    required this.input,
    required this.inputFocus,
    required this.onChanged,
    required this.onVerify,
    required this.onClear,
    required this.tools,
    this.header,
  });

  /// Scrolls with the page at a large font.
  final Widget? header;
  final LookupState state;
  final LookupWay way;

  /// The last lookup was a typed serial: its messages show here.
  final bool typed;
  final Widget camera;
  final TextEditingController input;
  final FocusNode inputFocus;
  final VoidCallback onChanged;
  final VoidCallback onVerify;
  final VoidCallback onClear;
  final List<Widget> tools;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formats = state.formats;

    // Without the formats only the serial form waits: the tools need no
    // formats, so they stay (final.md Section 13.7).
    Widget formsUnavailable() {
      final formatsFailure = state.formatsFailure;
      if (formatsFailure == null) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: CircularProgressIndicator(key: Key('verify.formatsLoading')),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ErrorBanner(
            message:
                '${l10n.formatsFailed} '
                '${formatsFailure.message(l10n)}',
            requestId: formatsFailure.requestId,
          ),
          const SizedBox(height: AppSpacing.md),
          RetryCountdown(
            until: state.formatsRetryAt,
            builder: (context, wait) => AppButton(
              key: const Key('verify.formatsRetry'),
              label: wait > 0 ? l10n.errorRateLimited(wait) : l10n.retry,
              onPressed: wait > 0
                  ? null
                  : () => context.read<LookupBloc>().add(
                      const FormatsRequested(),
                    ),
            ),
          ),
        ],
      );
    }

    final failure = state.failure;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ?header,
        camera,
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (formats == null)
                formsUnavailable()
              else
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
                        AppTextField(
                          fieldKey: const Key('verify.input'),
                          label: l10n.typeSerialLabel,
                          hint: l10n.serialHint(formats.serialMaxDigits),
                          controller: input,
                          focusNode: inputFocus,
                          prefixIcon: LucideIcons.hash,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(64),
                            const SerialInputFormatter(),
                          ],
                          textInputAction: TextInputAction.search,
                          errorText:
                              typed && state.status == LookupStatus.refused
                              ? refusedMessage(l10n, state.refused!, formats)
                              : null,
                          onChanged: (_) => onChanged(),
                          onSubmitted: (_) => onVerify(),
                        ),
                        if (typed &&
                            state.status == LookupStatus.failed &&
                            failure != null) ...[
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
                          // Held while a 429 counts down (guide section 1).
                          first: RetryCountdown(
                            until: state.retryAt,
                            builder: (context, seconds) => AppButton(
                              key: const Key('verify.submit'),
                              label: l10n.verifyButtonLookup,
                              loading: typed && state.isBusy,
                              onPressed:
                                  input.text.isEmpty ||
                                      seconds > 0 ||
                                      state.isBusy
                                  ? null
                                  : onVerify,
                            ),
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
              if (tools.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _ToolsSection(tools: tools),
              ],
            ],
          ),
        ),
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
