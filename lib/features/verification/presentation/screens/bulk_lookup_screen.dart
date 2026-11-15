import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';
import 'package:ziska_verify/features/verification/domain/entities/bulk.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/bulk_lookup_bloc.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/bulk_results_view.dart';
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
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// Bulk lookup (final.md Section 13.2).
class BulkLookupScreen extends StatelessWidget {
  const BulkLookupScreen({required this.scanner, super.key});

  final ScannerService scanner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<BulkLookupBloc, BulkLookupState>(
      listenWhen: (a, b) =>
          a.addProblemCount != b.addProblemCount ||
          (b.lastAdded != null && a.lastAdded?.id != b.lastAdded!.id),
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        final text = switch (state.addProblem) {
          AddRefused(:final refused) when state.formats != null =>
            refusedMessage(l10n, refused, state.formats!),
          AddDuplicate() => l10n.bulkDuplicate,
          AddListFull() => l10n.bulkFull(bulkMaxItems),
          _ => l10n.bulkAdded(state.lastAdded?.label ?? ''),
        };
        messenger.showSnackBar(
          SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
        );
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        appBar: AppBar(
          title: Text(l10n.bulkTitle),
          actions: [
            if (state.status != BulkStatus.done)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  // Shrinks at a large font instead of crowding out the
                  // title.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.bulkCount(state.entries.length, bulkMaxItems),
                        style: AppTypography.caption,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: switch ((state.formats, state.status)) {
          (_, BulkStatus.done) => BulkResultsView(
            outcome: state.outcome!,
            onOpen: (row) => context.pushNamed(
              RouteNames.lookupResult,
              extra: ResultView(
                result: row.result,
                // The row's label is already masked for a hidden code.
                input: CheckedInput(
                  way: row.way,
                  shown: row.label,
                  at: state.checkedAt ?? clock.now(),
                ),
                origin: ResultOrigin.bulk,
                formats: state.formats,
              ),
            ),
            onNewList: () =>
                context.read<BulkLookupBloc>().add(const BulkRestarted()),
          ),
          (null, _) => _FormatsPending(state: state),
          _ => _Composer(state: state, scanner: scanner),
        },
        // The send bar is the Scaffold's bottom bar, so the "Added …" snack
        // bars float above it instead of covering "Check N items".
        bottomNavigationBar:
            state.formats != null && state.status != BulkStatus.done
            ? _SendBar(state: state)
            : null,
      ),
    );
  }
}

class _FormatsPending extends StatelessWidget {
  const _FormatsPending({required this.state});

  final BulkLookupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.formatsFailure;
    if (failure == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        children: [
          ErrorBanner(
            message: '${l10n.formatsFailed} ${failure.message(l10n)}',
            requestId: failure.requestId,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.retry,
            onPressed: () => context.read<BulkLookupBloc>().add(
              const BulkFormatsRequested(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({required this.state, required this.scanner});

  final BulkLookupState state;
  final ScannerService scanner;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _input = TextEditingController();
  LookupWay _way = LookupWay.serial;
  ScannerSession? _session;
  String? _lastRaw;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _input.dispose();
    unawaited(_session?.dispose());
    super.dispose();
  }

  void _toggleScanner() {
    setState(() {
      if (_session == null) {
        _session = widget.scanner.createSession();
      } else {
        unawaited(_session!.dispose());
        _session = null;
      }
    });
  }

  void _onCode(String raw) {
    // A code held in front of the camera is read once.
    final now = clock.now();
    if (raw == _lastRaw && now.difference(_lastAt).inSeconds < 3) return;
    _lastRaw = raw;
    _lastAt = now;
    unawaited(HapticFeedback.selectionClick());
    context.read<BulkLookupBloc>().add(BulkItemAdded(LookupWay.qr, raw));
  }

  void _addTyped() {
    if (_input.text.isEmpty) return;
    context.read<BulkLookupBloc>().add(BulkItemAdded(_way, _input.text));
    _input.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    final formats = state.formats!;
    final sending = state.status == BulkStatus.sending;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              if (_session != null) ...[
                ClipRRect(
                  borderRadius: AppRadius.card,
                  child: SizedBox(
                    height: 220,
                    child: _session!.preview(
                      onCode: _onCode,
                      errorBuilder: (context, problem) => ColoredBox(
                        color: AppColors.scrim,
                        child: Center(
                          child: Text(
                            problem == ScannerProblem.permissionDenied
                                ? l10n.scannerPermissionDenied
                                : l10n.scannerFailed,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              AppButton(
                key: const Key('bulk.scan'),
                label: _session == null
                    ? l10n.bulkScanStart
                    : l10n.bulkScanStop,
                icon: _session == null
                    ? LucideIcons.qrCode
                    : LucideIcons.cameraOff,
                variant: AppButtonVariant.outlined,
                onPressed: sending ? null : _toggleScanner,
              ),
              const SizedBox(height: AppSpacing.lg),
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
                selected: {_way},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() {
                  _way = s.single;
                  _input.clear();
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppTextField(
                      fieldKey: const Key('bulk.input'),
                      secret: _way == LookupWay.hiddenCode,
                      label: _way == LookupWay.serial
                          ? l10n.waySerial
                          : l10n.wayHiddenCode,
                      hint: _way == LookupWay.serial
                          ? l10n.serialHint(formats.serialMaxDigits)
                          : l10n.hiddenCodeHint,
                      controller: _input,
                      keyboardType: _way == LookupWay.serial
                          ? TextInputType.number
                          : TextInputType.visiblePassword,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(64),
                        if (_way == LookupWay.serial)
                          const SerialInputFormatter(),
                      ],
                      textInputAction: TextInputAction.done,
                      enabled: !sending,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _addTyped(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 96,
                    child: AppButton(
                      key: const Key('bulk.add'),
                      label: l10n.bulkAdd,
                      onPressed: _input.text.isEmpty || sending
                          ? null
                          : _addTyped,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.entries.isEmpty)
                Text(l10n.bulkEmpty, style: AppTypography.caption)
              else ...[
                Row(
                  // The right side ends at the edge (a Flexible side
                  // leaves its unused share; spaceBetween puts it between).
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.bulkCount(state.entries.length, bulkMaxItems),
                        style: AppTypography.bodyStrong,
                      ),
                    ),
                    Flexible(
                      child: TextButton(
                        onPressed: sending
                            ? null
                            : () => context.read<BulkLookupBloc>().add(
                                const BulkListCleared(),
                              ),
                        child: Text(
                          l10n.bulkClearList,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.card,
                  ),
                  child: Column(
                    children: [
                      for (final (i, entry) in state.entries.indexed)
                        _EntryRow(
                          index: i,
                          entry: entry,
                          enabled: !sending,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.index,
    required this.entry,
    required this.enabled,
  });

  final int index;
  final BulkEntry entry;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, way) = switch (entry.way) {
      LookupWay.qr => (LucideIcons.qrCode, l10n.wayQr),
      LookupWay.serial => (LucideIcons.hash, l10n.waySerial),
      LookupWay.hiddenCode => (LucideIcons.tag, l10n.wayHiddenCode),
    };
    return ListTile(
      dense: true,
      leading: Text('${index + 1}', style: AppTypography.caption),
      title: Text(entry.label, style: AppTypography.bodyStrong),
      subtitle: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(child: Text(way, style: AppTypography.caption)),
        ],
      ),
      trailing: IconButton(
        tooltip: l10n.removeItem,
        icon: const Icon(LucideIcons.x, size: 18),
        onPressed: enabled
            ? () => context.read<BulkLookupBloc>().add(
                BulkItemRemoved(entry.id),
              )
            : null,
      ),
    );
  }
}

class _SendBar extends StatelessWidget {
  const _SendBar({required this.state});

  final BulkLookupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.failure;
    final count = state.entries.length;
    final nothingChecked =
        failure?.exception is ServiceUnavailableException ||
        failure?.exception is RateLimitedException;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: RetryCountdown(
            until: state.retryAt,
            builder: (context, seconds) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.status == BulkStatus.failed && failure != null) ...[
                  ErrorBanner(
                    message: seconds > 0
                        ? '${l10n.bulkNothingChecked} '
                              '${l10n.errorRateLimited(seconds)}'
                        : nothingChecked
                        ? l10n.bulkNothingChecked
                        : lookupFailureMessage(l10n, failure),
                    requestId: failure.requestId,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppButton(
                  key: const Key('bulk.send'),
                  label: state.status == BulkStatus.sending
                      ? l10n.bulkSending(count)
                      : nothingChecked
                      ? l10n.bulkSendAgain
                      : l10n.bulkSend(count),
                  loading: state.status == BulkStatus.sending,
                  onPressed: state.canSend && seconds == 0
                      ? () => context.read<BulkLookupBloc>().add(
                          const BulkSubmitted(),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
