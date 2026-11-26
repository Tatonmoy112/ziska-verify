import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/serial_stack_cubit.dart';
import 'package:ziska_verify/features/verification/presentation/models/result_view.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/session_counters.dart';
import 'package:ziska_verify/features/verification/presentation/widgets/verification_result_card.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/navy_app_bar.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

class SerialStackScreen extends StatefulWidget {
  const SerialStackScreen({
    this.onOpenSession,
    super.key,
  });
  final void Function(String id)? onOpenSession;
  @override
  State<SerialStackScreen> createState() => _SerialStackScreenState();
}

class _SerialStackScreenState extends State<SerialStackScreen>
    with WidgetsBindingObserver {
  final _input = TextEditingController();
  late SerialStackCubit _cubit;
  @override
  void initState() {
    super.initState();
    _input.addListener(() => _cubit.edit(_input.text));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<SerialStackCubit>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.resume();
    } else {
      _cubit.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _input.dispose();
    super.dispose();
  }

  /// The answer was lost: the stack may already be recorded (a session of
  /// kind `serial`, guide §4.7), and sending it again checks every serial
  /// again. Sent only once the official says so (UI audit 2026-11-22, 6.2).
  Future<void> _resend() async {
    final l = AppLocalizations.of(context);
    final send = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.serialStackResendTitle),
        content: Text(l.serialStackResendBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const Key('serials.resend'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.serialStackResendConfirm),
          ),
        ],
      ),
    );
    if (send == true && mounted) unawaited(_cubit.submit());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final busy = context.select<SerialStackCubit, bool>((c) => c.state.busy);
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: NavyAppBar(title: l.serialStackTitle),
        body: BlocBuilder<SerialStackCubit, SerialStackState>(
          builder: (_, state) {
            final result = state.result;
            if (result != null) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.md,
                        AppSpacing.screen,
                        AppSpacing.sm,
                      ),
                      child: SessionCounters(totals: result.session),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: result.items.length,
                    itemBuilder: (_, i) {
                      final row = result.items[i];
                      final style = outcomeStyle(row.result.outcome, l);
                      final product = row.result.item?.product.name;
                      return ListTile(
                        key: Key('serials.row.${row.serial}'),
                        title: Text(
                          row.serial,
                          style: AppTypography.bodyStrong,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [style.title, ?product].join(' · '),
                              style: AppTypography.caption.copyWith(
                                color: style.color,
                              ),
                            ),
                            Text(
                              row.result.ref,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            for (final reason in row.result.reasons)
                              ReasonChip(reason: reason),
                          ],
                        ),
                        leading: Icon(style.icon, color: style.color),
                        onTap: () async {
                          _cubit.pause();
                          await openResult(
                            context,
                            ResultView(
                              result: row.result,
                              input: CheckedInput(
                                way: LookupWay.serial,
                                shown: row.serial,
                                at: state.checkedAt!,
                              ),
                              origin: ResultOrigin.manyItems,
                              formats: state.formats,
                            ),
                          );
                          if (mounted) _cubit.resume();
                        },
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.screen),
                      child: Column(
                        children: [
                          if (widget.onOpenSession != null)
                            TextButton(
                              onPressed: () =>
                                  widget.onOpenSession!(result.session.id),
                              child: Text(l.serialStackHistory),
                            ),
                          AppButton(
                            label: l.serialStackNew,
                            onPressed: () {
                              _input.clear();
                              _cubit.reset();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            if (state.formats == null && state.failure == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return RetryCountdown(
              until: state.retryAt,
              builder: (_, seconds) => ListView(
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  Text(l.serialStackHint, style: AppTypography.body),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l.serialStackTitle,
                    fieldKey: const Key('serials.input'),
                    controller: _input,
                    minLines: 4,
                    maxLines: 8,
                    enabled: !state.busy && !state.submitted,
                    onChanged: (_) => setState(() {}),
                  ),
                  // How many go, before sending (SRS FR-STK-01: 1 to 50),
                  // counted by the cubit as the stack is sent: each value
                  // prepared, so "1000-001" and "1000001" are one serial.
                  // It follows the box itself, so Clear takes it away too
                  // (finding F-3).
                  if (state.draft case final parsed?)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        parsed.repeats > 0
                            ? l.serialStackCountRepeats(
                                parsed.counted,
                                parsed.repeats,
                              )
                            : l.serialStackCount(parsed.counted),
                        key: const Key('serials.count'),
                        style: AppTypography.caption.copyWith(
                          color: parsed.tooMany
                              ? AppColors.danger
                              : AppColors.textBody,
                        ),
                      ),
                    ),
                  if (state.failure != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    FailureBanner(
                      failure: state.failure!,
                      message: state.recorded
                          ? l.serialStackRecorded
                          : state.uncertain
                          ? l.serialStackUncertain
                          : state.failure!.exception.reason ==
                                VerificationReason.serialStackSize
                          ? l.serialStackLimit
                          : state.failure!.exception.reason ==
                                    VerificationReason.serialInput &&
                                state.badSerial != null
                          ? l.serialStackBadSerial(
                              state.badSerial!.position,
                              state.badSerial!.value,
                              state.formats!.serialMaxDigits,
                            )
                          : state.failure!.exception is NetworkException
                          ? l.serialStackNotSent
                          : state.failure!.message(l),
                      retryAt: state.retryAt,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (state.recorded)
                    AppButton(
                      key: const Key('serials.new'),
                      label: l.serialStackNew,
                      onPressed: () {
                        _input.clear();
                        _cubit.reset();
                      },
                    )
                  else
                    AppButton(
                      key: const Key('serials.submit'),
                      label: state.uncertain
                          ? l.serialStackRetry
                          : l.serialStackSubmit,
                      loading: state.busy,
                      onPressed: seconds > 0 || state.busy
                          ? null
                          : () {
                              if (state.formats == null) {
                                unawaited(_cubit.load());
                                return;
                              }
                              if (state.uncertain) {
                                unawaited(_resend());
                                return;
                              }
                              unawaited(_cubit.submitText(_input.text));
                            },
                    ),
                  TextButton(
                    onPressed: state.busy
                        ? null
                        : () {
                            _input.clear();
                            _cubit.reset();
                          },
                    child: Text(l.clear),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
