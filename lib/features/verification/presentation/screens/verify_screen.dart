import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/services/qr_read_filter.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/screens/verifying_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/check_header.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/live_qr_camera.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/lookup_messages.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/serial_lookup_form.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/tools_section.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/widgets/app_empty_state.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';
import 'package:ziska_verify/shared/widgets/navy_status_bar.dart';
import 'package:ziska_verify/shared/widgets/tab_visibility.dart';

/// The Check tab (final.md §13.1, §13.7). With `item:lookup` it
/// opens on the camera: a read QR is the trigger, sent at once as
/// `POST lookups` with no button. A serial is typed under the camera.
///
/// The camera runs only while it can be seen: the tab shown and not
/// covered (the shell and the navigator turn the tab's tickers off), the
/// app in the foreground, and no scan result or failure holding it.
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({
    required this.onOpenProfile,
    required this.onNewReport,
    required this.onMyReports,
    required this.scanner,
    required this.onOpenSettings,
    super.key,
  });

  /// Switches to the Profile tab; wired by the router.
  final VoidCallback onOpenProfile;

  /// Open New report and My reports, pages of the reports feature, and
  /// finish when they close (the camera waits meanwhile); wired by the
  /// router (final.md §9: a screen opens only its own feature's routes).
  final Future<void> Function() onNewReport;
  final Future<void> Function() onMyReports;
  final ScannerService scanner;

  /// Opens the phone's settings, when the camera was refused.
  final Future<bool> Function() onOpenSettings;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen>
    with WidgetsBindingObserver, TabVisibility {
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
  /// The same code is not read again for 3 seconds while scanning, and
  /// for 5 after its result closes, which also covers a slow camera start:
  /// a pack still in front of the camera is not checked again by itself
  /// (guide §4.3).
  final _reads = QrReadFilter(
    window: const Duration(seconds: 3),
    afterResult: const Duration(seconds: 5),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// The camera runs only while the tab can be seen.
  @override
  void onTabShown({required bool firstTime}) {
    _visible = true;
    _sync();
  }

  @override
  void onTabHidden() {
    _visible = false;
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

  /// The check loader follows the lookup (§13.1).
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
    if (!_reads.accept(raw)) return;
    _lastWay = LookupWay.qr;
    FocusScope.of(context).unfocus();
    bloc.add(LookupRequested(LookupWay.qr, raw));
  }

  /// After a failed scan: the camera starts again for the same QR.
  void _scanAgain() {
    _reads.forget();
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
  Future<void> _open(Future<void> Function() open) async {
    _hold(true);
    await open();
    if (!mounted) return;
    _hold(false);
  }

  Future<void> _push(String route) => context.pushNamed<void>(route);

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
      _reads.resultClosed();
    } else {
      _reads.forget();
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
    // Entry points to the other features the role allows (§13.7).
    final tools = <Widget>[
      if (profile?.canBulkLookup ?? false)
        ToolTile(
          key: const Key('verify.tool.bulk'),
          icon: LucideIcons.layers,
          title: l10n.scannerModeTitle,
          onTap: () => unawaited(_open(() => _push(RouteNames.scannerMode))),
        ),
      if (profile?.canBulkLookup ?? false)
        ToolTile(
          key: const Key('verify.tool.serials'),
          icon: LucideIcons.listOrdered,
          title: l10n.serialStackTitle,
          onTap: () => unawaited(_open(() => _push(RouteNames.serialStack))),
        ),
      if (profile?.canReport ?? false) ...[
        ToolTile(
          key: const Key('verify.tool.report'),
          icon: LucideIcons.flag,
          title: l10n.toolReport,
          onTap: () => unawaited(_open(widget.onNewReport)),
        ),
        ToolTile(
          key: const Key('verify.tool.myReports'),
          icon: LucideIcons.fileText,
          title: l10n.toolMyReports,
          onTap: () => unawaited(_open(widget.onMyReports)),
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
              CheckHeader(
                organisation: profile?.organisation ?? l10n.appTitle,
                name: profile?.name ?? '',
                onOpenProfile: widget.onOpenProfile,
              ),
              if (tools.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: ToolsSection(tools: tools),
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
    final header = CheckHeader(
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
                        child: SerialLookupForm(
                          state: state,
                          way: _way,
                          typed: _lastWay == LookupWay.serial,
                          camera: _camera(context, state, session),
                          input: _input,
                          inputFocus: _inputFocus,
                          onChanged: () => _onTyped(context),
                          onVerify: _verify,
                          onClear: _clear,
                          onRetryFormats: () => context.read<LookupBloc>().add(
                            const FormatsRequested(),
                          ),
                          tools: tools,
                          header: scrollingHeader ? header : null,
                        ),
                      ),
                    )
                  : tools.isNotEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(AppSpacing.screen),
                      children: [ToolsSection(tools: tools)],
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
