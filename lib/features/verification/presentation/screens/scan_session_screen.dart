import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/scan_session_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/scan_frame.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_counters.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/large_text.dart';
import 'package:ziska_verify/shared/widgets/navy_app_bar.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

class ScanSessionScreen extends StatefulWidget {
  const ScanSessionScreen({
    required this.scanner,
    required this.onOpenSettings,
    required this.onOpenResult,
    super.key,
  });
  final ScannerService scanner;
  final Future<bool> Function() onOpenSettings;
  final OpenLookupResult onOpenResult;
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
      await widget.onOpenResult(answer.result, answer.checked, state.formats);
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
          builder: (_, state) => _BottomBar(
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
                return _SessionSummary(
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
                      _CameraArea(
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
                            : _LiveResult(
                                key: ValueKey(state.answered),
                                result: state.latest!,
                                repeat: state.repeat,
                                onTap: () => unawaited(_open(state)),
                              ),
                      ),
                      if (state.notChecked > 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screen,
                            AppSpacing.sm,
                            AppSpacing.screen,
                            0,
                          ),
                          child: Text(
                            l.sessionNotChecked(state.notChecked),
                            key: const Key('session.notChecked'),
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.md,
                          AppSpacing.screen,
                          0,
                        ),
                        // The backend's totals; zeros before the first scan
                        // of a new session. A resumed one without its totals
                        // says so until a scan answers (no false zeros).
                        child: state.totals == null && state.resumed
                            ? Padding(
                                key: const Key('session.resumed'),
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Text(
                                  l.sessionResumedCounts,
                                  style: AppTypography.caption,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : SessionCounters(
                                totals:
                                    state.totals ??
                                    SessionTotals(
                                      id: state.id!,
                                      scanned: 0,
                                      valid: 0,
                                      warning: 0,
                                      notFound: 0,
                                      unassigned: 0,
                                    ),
                              ),
                      ),
                      if (state.busy) const LinearProgressIndicator(),
                      if (state.failure != null)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: FailureBanner(
                            failure: state.failure!,
                            retryAt: state.retryAt,
                            message:
                                state.failure!.exception.reason ==
                                    VerificationReason.scanInput
                                ? l.notProductQr
                                // Nothing is queued: scan the product
                                // again (FR-SCN-15, guide section 4.6).
                                : state.failure!.exception is NetworkException
                                ? l.sessionNoConnection
                                : state.failure!.exception
                                      is ServiceUnavailableException
                                ? l.sessionBusy
                                : state.failure!.message(l),
                          ),
                        ),
                      if (state.renewed)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            _cubit.canReadHistory
                                ? l.sessionRenewedHistory
                                : l.sessionRenewed,
                            key: const Key('session.renewed'),
                            style: AppTypography.caption,
                          ),
                        ),
                      if (state.restarted)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            l.sessionRestarted,
                            key: const Key('session.restarted'),
                            style: AppTypography.caption,
                          ),
                        ),
                      if (state.repeat)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              l.sessionRepeat,
                              key: const Key('session.repeat'),
                              style: AppTypography.bodyStrong.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                      if (state.latest != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screen,
                            AppSpacing.sm,
                            AppSpacing.screen,
                            0,
                          ),
                          child: InkWell(
                            key: const Key('session.latest'),
                            onTap: () => unawaited(_open(state)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                VerificationResultCard(result: state.latest!),
                                if (state.latest!.item != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.xs,
                                    ),
                                    child: Text(
                                      [
                                        state.latest!.item!.serial,
                                        state.latest!.item!.product.name,
                                      ].join(' · '),
                                      key: const Key('session.latest.item'),
                                      style: AppTypography.caption,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (state.failure != null)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.screen),
                          child: RetryCountdown(
                            until: state.retryAt,
                            builder: (_, seconds) => AppButton(
                              key: const Key('session.scanAgain'),
                              label: l.sessionScanAgain,
                              onPressed: seconds > 0 || state.busy
                                  ? null
                                  : () async {
                                      await _camera.stop();
                                      _cubit.resume();
                                      await _camera.start();
                                    },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (state.rowsFailed)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screen,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.sessionRowsFailed,
                              style: AppTypography.caption,
                            ),
                          ),
                          RetryCountdown(
                            until: state.rowsRetryAt,
                            builder: (_, wait) => TextButton(
                              key: const Key('session.rowsRetry'),
                              onPressed: state.loadingMore || wait > 0
                                  ? null
                                  : () => unawaited(_cubit.reloadRows()),
                              child: Text(
                                wait > 0 ? l.errorRateLimited(wait) : l.retry,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverList.builder(
                  itemCount:
                      state.rows.length + (state.nextCursor == null ? 0 : 1),
                  itemBuilder: (_, i) {
                    if (i == state.rows.length) {
                      return RetryCountdown(
                        until: state.rowsRetryAt,
                        builder: (_, wait) => TextButton(
                          onPressed: state.loadingMore || wait > 0
                              ? null
                              : () => unawaited(_cubit.more()),
                          child: Text(
                            wait > 0
                                ? l.errorRateLimited(wait)
                                : l.sessionsMore,
                          ),
                        ),
                      );
                    }
                    final row = state.rows[i];
                    final answer = state.answers[row.ref];
                    return _ScanRow(
                      key: ValueKey(row.ref),
                      row: row,
                      onTap: answer == null
                          ? null
                          : () => unawaited(_openAnswer(answer, state)),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The camera of scanner mode: dark, with the overlay, the frame, and its
/// hint, as the single scanner (SRS 7.1 "Scanner mode: the camera …").
/// A camera problem says what to do, styled like the rest of the app.
class _CameraArea extends StatelessWidget {
  const _CameraArea({
    required this.height,
    required this.preview,
    required this.onOpenSettings,
    this.frameColor,
    this.checking,
    this.live,
  });

  final double height;

  /// The colour of the last result, around the frame.
  final Color? frameColor;

  /// "Checking…" while a scan is being checked or reads wait.
  final String? checking;

  /// The last result, across the bottom of the camera.
  final Widget? live;
  final Widget Function(
    Widget Function(BuildContext, ScannerProblem) onError,
  )
  preview;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      key: const Key('session.camera'),
      height: height,
      child: ColoredBox(
        color: AppColors.textStrong,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Room at the bottom for the live result, so it never covers
            // the frame (and the frame does not move when it appears).
            const strip = 72.0;
            final room = constraints.maxHeight - strip;
            final side = (room * 0.7).clamp(120.0, 260.0);
            final frame = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                room / 2 + AppSpacing.md,
              ),
              width: side,
              height: side,
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                preview(
                  (context, problem) => _CameraProblem(
                    problem: problem,
                    onOpenSettings: onOpenSettings,
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: ScanOverlayPainter(window: frame),
                  ),
                ),
                Positioned(
                  left: AppSpacing.screen,
                  right: AppSpacing.screen,
                  bottom: constraints.maxHeight - frame.top + AppSpacing.sm,
                  child: Text(
                    l.scanFrameHint.toUpperCase(),
                    key: const Key('session.hint'),
                    textAlign: TextAlign.center,
                    style: AppTypography.fieldLabel.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: frame,
                  child: ScanFrame(key: const Key('session.frame'), size: side),
                ),
                if (frameColor != null)
                  Positioned.fromRect(
                    rect: frame.inflate(4),
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        key: const Key('session.frameResult'),
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: frameColor!, width: 3),
                        ),
                      ),
                    ),
                  ),
                if (checking != null)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _Checking(text: checking!),
                  ),
                Positioned(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: live ?? const SizedBox.shrink(),
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

class _CameraProblem extends StatelessWidget {
  const _CameraProblem({required this.problem, required this.onOpenSettings});

  final ScannerProblem problem;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = switch (problem) {
      ScannerProblem.permissionDenied => l.scannerPermissionDenied,
      ScannerProblem.unsupported => l.scannerUnsupported,
      ScannerProblem.other => l.scannerFailed,
    };
    return ColoredBox(
      color: AppColors.textStrong,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.cameraOff,
                color: AppColors.onPrimary,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                text,
                key: const Key('session.cameraProblem'),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.onPrimary),
              ),
              if (problem == ScannerProblem.permissionDenied) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l.openSettings,
                  variant: AppButtonVariant.tonal,
                  onPressed: onOpenSettings,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The last answer, over the camera: its colour, title, serial and product.
/// Read aloud by screen readers as it changes.
class _LiveResult extends StatelessWidget {
  const _LiveResult({
    required this.result,
    required this.repeat,
    required this.onTap,
    super.key,
  });

  final LookupResult result;
  final bool repeat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = outcomeStyle(result.outcome, l);
    final item = result.item;
    final detail = [
      if (item != null) ...[item.serial, item.product.name],
    ].join(' · ');
    final title = repeat ? '${style.title} · ${l.sessionRepeat}' : style.title;
    return Semantics(
      liveRegion: true,
      label: [title, if (detail.isNotEmpty) detail].join('. '),
      excludeSemantics: true,
      button: true,
      child: Material(
        key: const Key('session.live'),
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: style.color, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(style.icon, color: style.color, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStrong.copyWith(
                          color: style.color,
                        ),
                      ),
                      if (detail.isNotEmpty)
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textStrong,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One scan in the list: its result's icon and colour, serial and product.
/// Opens the full result when this run answered it.
class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.row, this.onTap, super.key});

  final RecoveredScan row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = outcomeStyle(row.outcome, AppLocalizations.of(context));
    return ListTile(
      onTap: onTap,
      leading: Icon(style.icon, color: style.color),
      title: Text(row.serial ?? row.ref, style: AppTypography.bodyStrong),
      subtitle: Text(
        [style.title, ?row.product].join(' · '),
        style: AppTypography.caption.copyWith(color: style.color),
      ),
      trailing: onTap == null
          ? null
          : const Icon(LucideIcons.chevronRight, color: AppColors.textMuted),
    );
  }
}

/// Finish while scanning; Scan more and Done on the summary.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.state,
    required this.onFinish,
    required this.onScanMore,
    required this.onDone,
  });

  final ScanSessionState state;
  final VoidCallback onFinish;
  final VoidCallback onScanMore;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (state.phase) {
      case SessionPhase.starting ||
          SessionPhase.startFailed ||
          SessionPhase.closed:
        return const SizedBox.shrink();
      case SessionPhase.scanning || SessionPhase.finishing || SessionPhase.done:
        break;
    }
    final Widget child;
    if (state.done) {
      final scanMore = AppButton(
        key: const Key('session.scanMore'),
        variant: AppButtonVariant.outlined,
        label: l.sessionScanMore,
        onPressed: onScanMore,
      );
      final done = AppButton(
        key: const Key('session.done'),
        label: l.sessionDone,
        onPressed: onDone,
      );
      // Side by side; stacked at a large font, so no label is cut.
      child = isLargeText(context)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                done,
                const SizedBox(height: AppSpacing.xs),
                scanMore,
              ],
            )
          : Row(
              children: [
                Expanded(child: scanMore),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: done),
              ],
            );
    } else {
      child = AppButton(
        key: const Key('session.finish'),
        label: state.finishing ? l.sessionFinishing : l.sessionFinish,
        loading: state.finishing,
        // Once a scan has been answered: an empty summary says nothing.
        onPressed: state.finishing || state.rows.isEmpty ? null : onFinish,
      );
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.sm,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// After Finish: every scan of the session together, with the totals.
class _SessionSummary extends StatelessWidget {
  const _SessionSummary({
    required this.state,
    required this.onOpen,
    required this.onMore,
  });

  final ScanSessionState state;
  final ValueChanged<ScanAnswer> onOpen;

  /// The next page of a resumed session's scans (UI audit 2026-11-22, 5.3).
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final totals = state.totals;
    final count = totals?.scanned ?? state.rows.length;
    return ListView(
      key: const Key('session.summary'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l.sessionSummaryTitle,
                  style: AppTypography.heading,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l.sessionSummaryCount(count),
                key: const Key('session.summary.count'),
                style: AppTypography.body,
              ),
              if (totals != null) ...[
                const SizedBox(height: AppSpacing.md),
                SessionCounters(totals: totals),
              ],
              if (state.notChecked > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.sessionNotChecked(state.notChecked),
                  key: const Key('session.summary.notChecked'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
        for (final row in state.rows)
          _ScanRow(
            key: ValueKey('summary.${row.ref}'),
            row: row,
            onTap: switch (state.answers[row.ref]) {
              final answer? => () => onOpen(answer),
              null => null,
            },
          ),
        // A resumed session's scans come a page at a time: say how many
        // show, and load the rest (final.md §13.2: every product).
        if (state.nextCursor != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                Text(
                  l.sessionSummaryShowing(state.rows.length, count),
                  key: const Key('session.summary.showing'),
                  style: AppTypography.body,
                ),
                RetryCountdown(
                  until: state.rowsRetryAt,
                  builder: (_, wait) => TextButton(
                    key: const Key('session.summary.more'),
                    onPressed: state.loadingMore || wait > 0 ? null : onMore,
                    child: Text(
                      wait > 0 ? l.errorRateLimited(wait) : l.sessionsMore,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A small "Checking…" over the camera while answers are on their way.
class _Checking extends StatelessWidget {
  const _Checking({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const Key('session.checking'),
    decoration: BoxDecoration(
      color: AppColors.textStrong.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.caption.copyWith(color: AppColors.onPrimary),
          ),
        ],
      ),
    ),
  );
}
