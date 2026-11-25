import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/scan_camera_area.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_bottom_bar.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_live_panel.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_rows_sliver.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_summary_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/navy_app_bar.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

class ScanSessionScreen extends StatefulWidget {
  const ScanSessionScreen({
    required this.scanner,
    required this.onOpenSettings,
    super.key,
  });
  final ScannerService scanner;
  final Future<bool> Function() onOpenSettings;
  @override
  State<ScanSessionScreen> createState() => _ScanSessionScreenState();
}

class _ScanSessionScreenState extends State<ScanSessionScreen>
    with WidgetsBindingObserver {
  late final ScannerSession _camera = widget.scanner.createSession();
  late ScanSessionCubit _cubit;
  bool _detail = false;

  /// Set once the camera is let go on the way out (see [_leave]).
  bool _leaving = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<ScanSessionCubit>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cubit.state.done || _leaving) return;
    if (state == AppLifecycleState.resumed && !_detail) {
      // The line goes on; the camera only while scanning, not during
      // Finish (it stopped for good when Finish was tapped).
      _cubit.resume();
      if (!_cubit.state.finishing) unawaited(_camera.start());
    } else {
      _cubit.pause();
      unawaited(_camera.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_cubit.finish());
    unawaited(_camera.dispose());
    super.dispose();
  }

  Future<void> _feel(ScanSessionState state) async {
    final outcome = state.latest?.outcome;
    if (outcome == null) return;
    if (state.repeat) {
      await HapticFeedback.selectionClick();
    } else if (outcome == LookupOutcome.valid) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.vibrate();
    }
  }

  Future<void> _open(ScanSessionState state) async {
    final result = state.latest;
    final checked = state.checked;
    if (result == null || checked == null) return;
    await _openAnswer(ScanAnswer(result, checked), state);
  }

  /// Opens one scan's full result; the camera waits meanwhile, and stays
  /// off on the summary.
  Future<void> _openAnswer(ScanAnswer answer, ScanSessionState state) async {
    if (_detail) return;
    _detail = true;
    final scanning = !state.done;
    if (scanning) {
      _cubit.pause();
      await _camera.stop();
    }
    if (mounted) {
      await openResult(
        context,
        ResultView(
          result: answer.result,
          input: answer.checked,
          origin: ResultOrigin.manyItems,
          formats: state.formats,
        ),
      );
    }
    if (!mounted) return;
    _detail = false;
    if (scanning && !_cubit.state.done) {
      // The line goes on in any case: during Finish the reads already taken
      // are still sent and answered (final.md §13.2), or Finish never ends
      // (UI audit 2026-11-22, 5.1). The camera starts again only while
      // scanning.
      _cubit.resume();
      if (!_cubit.state.finishing) await _camera.start();
    }
  }

  /// Finish: the camera stops, the reads already taken are answered, then
  /// the summary shows.
  Future<void> _finish() async {
    await _camera.stop();
    await _cubit.complete();
  }

  /// Leaves Scanner mode, its camera stopped first. The phone has one camera,
  /// shared with the Check tab, which starts it as soon as this screen goes;
  /// held by this screen until its dispose, that start would be refused and
  /// the Check tab would show "The camera could not start." (finding F-2).
  Future<void> _leave() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    try {
      await _camera.stop().timeout(const Duration(seconds: 2));
    } on Object {
      // Leaving is never blocked: at worst the Check tab's camera starts
      // again the next time the tab shows.
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Scan again after a failure: the camera starts over.
  Future<void> _scanAgain() async {
    await _camera.stop();
    _cubit.resume();
    await _camera.start();
  }

  /// Scan more: a new session on the camera.
  Future<void> _scanMore() async {
    await _cubit.restart();
    if (mounted) await _camera.start();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      // Every way out (Android Back, the back arrow, Done) lets the camera
      // go first, then leaves (finding F-2).
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          unawaited(_cubit.finish());
        } else {
          unawaited(_leave());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        appBar: NavyAppBar(
          title: l.scannerModeTitle,
          actions: [
            IconButton(
              tooltip: l.torch,
              icon: const Icon(LucideIcons.zap),
              onPressed: () => unawaited(_camera.toggleTorch()),
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<ScanSessionCubit, ScanSessionState>(
          builder: (_, state) => SessionBottomBar(
            state: state,
            onFinish: () => unawaited(_finish()),
            onScanMore: () => unawaited(_scanMore()),
            onDone: () => unawaited(Navigator.of(context).maybePop()),
          ),
        ),
        body: BlocConsumer<ScanSessionCubit, ScanSessionState>(
          // Every answer is felt: one short buzz for Genuine, a longer one
          // for anything else, a tick for "already scanned".
          listenWhen: (a, b) => a.answered != b.answered,
          listener: (_, state) => unawaited(_feel(state)),
          builder: (_, state) {
            switch (state.phase) {
              case SessionPhase.starting:
                return const Center(child: CircularProgressIndicator());
              case SessionPhase.done:
                return SessionSummaryView(
                  state: state,
                  onOpen: (answer) => unawaited(_openAnswer(answer, state)),
                  onMore: () => unawaited(_cubit.more()),
                );
              // Left: the screen is going, nothing more to show.
              case SessionPhase.closed:
                return const SizedBox.shrink();
              case SessionPhase.scanning || SessionPhase.finishing:
                break;
              case SessionPhase.startFailed:
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  children: [
                    if (state.failure != null)
                      FailureBanner(
                        failure: state.failure!,
                        message: state.failure!.message(l),
                        retryAt: state.retryAt,
                      ),
                    RetryCountdown(
                      until: state.retryAt,
                      builder: (_, wait) => AppButton(
                        key: const Key('session.startRetry'),
                        label: l.retry,
                        onPressed: wait > 0
                            ? null
                            : () => unawaited(_cubit.start()),
                      ),
                    ),
                  ],
                );
            }
            return CustomScrollView(
              key: const Key('session.rows'),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ScanCameraArea(
                        height: MediaQuery.sizeOf(context).height * 0.42,
                        preview: (onError) => _camera.preview(
                          onCode: (raw) => unawaited(_cubit.scan(raw)),
                          errorBuilder: onError,
                        ),
                        onOpenSettings: widget.onOpenSettings,
                        frameColor: state.latest == null
                            ? null
                            : outcomeStyle(state.latest!.outcome, l).color,
                        checking: state.busy || state.pending > 0
                            ? (state.pending > 0
                                  ? l.sessionCheckingMore(state.pending)
                                  : l.sessionChecking)
                            : null,
                        live: state.latest == null
                            ? null
                            : ScanLiveResult(
                                key: ValueKey(state.answered),
                                result: state.latest!,
                                repeat: state.repeat,
                                onTap: () => unawaited(_open(state)),
                              ),
                      ),
                      SessionLivePanel(
                        state: state,
                        canReadHistory: _cubit.canReadHistory,
                        onOpenLatest: () => unawaited(_open(state)),
                        onScanAgain: () => unawaited(_scanAgain()),
                      ),
                    ],
                  ),
                ),
                SessionRowsSliver(
                  state: state,
                  onOpen: (answer) => unawaited(_openAnswer(answer, state)),
                  onRetryRows: () => unawaited(_cubit.reloadRows()),
                  onMore: () => unawaited(_cubit.more()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
