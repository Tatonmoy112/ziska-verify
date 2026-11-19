import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/core/services/media/photo_service.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/incidents/presentation/bloc/report_incident_bloc.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/navy_app_bar.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// Report incident (final.md Section 13.5).
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({
    required this.pickRetailUser,
    this.pickCheck,
    super.key,
  });

  /// Picks one of the official's own checks; `null` without `history:own`
  /// (the picker reads the history).
  final Future<String?> Function(BuildContext context)? pickCheck;

  /// Opens the retail user picker; wired by the router (Section 4.2).
  final Future<({String id, String name})?> Function(BuildContext context)
  pickRetailUser;

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _note = TextEditingController();

  /// The last [ReportIncidentState.samePhotoCount] already shown.
  int _shownSame = 0;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(l10n.reportCamera),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(l10n.reportGallery),
              onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null && mounted) {
      context.read<ReportIncidentBloc>().add(PhotoPickRequested(source));
    }
  }

  /// Done: while a photo is sending or can be sent again, leaving loses
  /// it, so ask first (guide 6.2: keep a failed photo and send it again).
  Future<void> _done(ReportIncidentState state) async {
    final pending = state.photos.any(
      (p) =>
          p.status == PhotoStatus.waiting ||
          p.status == PhotoStatus.sending ||
          (p.status == PhotoStatus.failed && p.canRetry),
    );
    if (pending) {
      final l10n = AppLocalizations.of(context);
      final leave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.reportLeaveTitle),
          content: Text(l10n.reportLeaveBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.reportStay),
            ),
            TextButton(
              key: const Key('report.leave'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.reportLeave),
            ),
          ],
        ),
      );
      if (leave != true || !mounted) return;
    }
    if (mounted) context.pop();
  }

  Future<void> _chooseCheck() async {
    final ref = await widget.pickCheck!(context);
    if (ref != null && mounted) {
      context.read<ReportIncidentBloc>().add(CheckRefChosen(ref));
    }
  }

  Future<void> _chooseRetailUser() async {
    final user = await widget.pickRetailUser(context);
    if (user != null && mounted) {
      context.read<ReportIncidentBloc>().add(RetailUserChosen(user));
    }
  }

  static ReportPhoto? _lastPhotoFailure(ReportIncidentState state) => state
      .photos
      .where(
        (p) =>
            p.status == PhotoStatus.failed &&
            p.failure != null &&
            p.failure!.exception is! RateLimitedException,
      )
      .lastOrNull;

  /// A 409 shows the server's message when it gives one ("The report has 3
  /// photos already.", guide section 6.2); the app's text otherwise.
  static String _photoMessage(AppLocalizations l10n, ReportPhoto photo) {
    final failure = photo.failure!;
    final e = failure.exception;
    if (photo.canRetry) return failure.message(l10n);
    if (e is ConflictException) {
      final text = e.message?.trim();
      return text == null || text.isEmpty ? l10n.reportPhotoConflict : text;
    }
    return l10n.reportPhotoRefused;
  }

  String _filingError(AppLocalizations l10n, ReportIncidentState state) =>
      switch (state.failure!.exception) {
        NotFoundException() => switch (state.missing) {
          MissingLink.check => l10n.reportCheckGone,
          MissingLink.retailUser => l10n.reportRetailUserGone,
          MissingLink.route || null => l10n.errorNotAvailable,
        },
        NetworkException(:final wasNotSent) =>
          wasNotSent ? l10n.errorNetwork : l10n.reportUnconfirmed,
        _ when state.filing == FilingStatus.unconfirmed =>
          l10n.reportUnreadable,
        _ => state.failure!.message(l10n),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ReportIncidentBloc, ReportIncidentState>(
      listenWhen: (a, b) =>
          a.photoProblemCount != b.photoProblemCount ||
          a.samePhotoCount != b.samePhotoCount,
      listener: (context, state) {
        final previous = _shownSame;
        _shownSame = state.samePhotoCount;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.samePhotoCount != previous
                  ? l10n.reportPhotoSame
                  : state.photoProblem == PhotoProblem.tooLarge
                  ? l10n.reportPhotoTooLarge
                  : l10n.reportPhotoUnreadable,
            ),
          ),
        );
      },
      builder: (context, state) {
        final bloc = context.read<ReportIncidentBloc>();
        final editable = state.canEdit;
        return Scaffold(
          backgroundColor: AppColors.surfaceMuted,
          appBar: NavyAppBar(title: l10n.reportTitle),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              if (state.isFiled)
                _FiledBanner(id: state.reportId!)
              else
                _Info(text: l10n.reportWhenNotNeeded),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                fieldKey: const Key('report.note'),
                label: l10n.reportNoteLabel,
                hint: l10n.reportNoteHint,
                controller: _note,
                enabled: editable,
                minLines: 4,
                maxLines: 8,
                // The server counts characters as code points (guide
                // sections 3.6, 6.1), so an emoji of two counts as two.
                inputFormatters: const [
                  CodePointLimit(ReportRules.noteMaxLength),
                ],
                counter:
                    '${_note.text.runes.length}/${ReportRules.noteMaxLength}',
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              if (state.checkRef != null)
                _LinkRow(
                  icon: LucideIcons.fileCheck,
                  label: l10n.reportCheckLabel,
                  value: state.checkRef!,
                  onClear: editable
                      ? () => bloc.add(const CheckRefCleared())
                      : null,
                )
              else if (editable && widget.pickCheck != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('report.check'),
                    onPressed: () => unawaited(_chooseCheck()),
                    icon: const Icon(LucideIcons.fileCheck, size: 18),
                    label: Text(l10n.reportChooseCheck),
                  ),
                ),
              if (state.retailUser != null)
                _LinkRow(
                  icon: LucideIcons.store,
                  label: l10n.reportRetailUserLabel,
                  value: state.retailUser!.name,
                  onClear: editable
                      ? () => bloc.add(const RetailUserChosen(null))
                      : null,
                )
              else if (editable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('report.retailUser'),
                    onPressed: () => unawaited(_chooseRetailUser()),
                    icon: const Icon(LucideIcons.store, size: 18),
                    label: Text(l10n.reportChooseRetailUser),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.reportPhotosLabel.toUpperCase(),
                style: AppTypography.fieldLabel,
              ),
              Text(l10n.reportPhotosHint, style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final photo in state.photos)
                    _PhotoTile(
                      photo: photo,
                      onRetry: () => bloc.add(PhotoRetried(photo.localId)),
                      onRemove: () => bloc.add(PhotoRemoved(photo.localId)),
                    ),
                  if (bloc.canAddPhoto && state.filing != FilingStatus.filing)
                    _AddPhotoTile(
                      label: l10n.reportAddPhoto,
                      onTap: () => unawaited(_addPhoto()),
                    ),
                ],
              ),
              // The last refused or failed photo, with its reference (guide
              // section 1); a 429 counts down on its own tile.
              if (_lastPhotoFailure(state) case final failed?) ...[
                const SizedBox(height: AppSpacing.sm),
                FailureBanner(
                  key: const Key('report.photoFailure'),
                  failure: failed.failure!,
                  message: _photoMessage(l10n, failed),
                ),
              ],
              // The hour is over: a photo still waiting or failed is not sent.
              if (bloc.photoHourOver &&
                  state.photos.any(
                    (p) => p.canRetry || p.status == PhotoStatus.waiting,
                  )) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.reportPhotoWindowOver, style: AppTypography.caption),
              ],
              if (state.filing == FilingStatus.failed ||
                  state.filing == FilingStatus.unconfirmed) ...[
                const SizedBox(height: AppSpacing.md),
                FailureBanner(
                  failure: state.failure!,
                  retryAt: state.retryAt,
                  message: _filingError(l10n, state),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (state.isFiled)
                AppButton(
                  key: const Key('report.done'),
                  label: l10n.reportDone,
                  onPressed: () => unawaited(_done(state)),
                )
              else if (state.filing == FilingStatus.unconfirmed)
                // The report may be filed: look, never file again here.
                AppButton(
                  key: const Key('report.checkMyReports'),
                  label: l10n.reportCheckMyReports,
                  onPressed: () =>
                      context.pushReplacementNamed(RouteNames.myReports),
                )
              else
                AppButton(
                  key: const Key('report.submit'),
                  label: l10n.reportFile,
                  loading: state.filing == FilingStatus.filing,
                  onPressed: _note.text.trim().isEmpty
                      ? null
                      : () => bloc.add(ReportSubmitted(_note.text)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.infoBackground,
      borderRadius: AppRadius.card,
      border: Border.all(color: AppColors.infoBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(LucideIcons.info, color: AppColors.infoAccent, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(text, style: AppTypography.caption)),
      ],
    ),
  );
}

class _FiledBanner extends StatelessWidget {
  const _FiledBanner({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.circleCheck, color: AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(l10n.reportFiled(id), style: AppTypography.bodyStrong),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: AppColors.primary),
    title: Text(label, style: AppTypography.caption),
    subtitle: Text(value, style: AppTypography.bodyStrong),
    trailing: onClear == null
        ? null
        : IconButton(
            tooltip: AppLocalizations.of(context).removeItem,
            icon: const Icon(LucideIcons.x),
            onPressed: onClear,
          ),
  );
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.onRetry,
    required this.onRemove,
  });

  final ReportPhoto photo;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (overlay, hint) = switch (photo.status) {
      PhotoStatus.waiting => (null, null),
      PhotoStatus.sending => (
        const CircularProgressIndicator(color: AppColors.onPrimary),
        null,
      ),
      PhotoStatus.sent => (
        const Icon(LucideIcons.circleCheck, color: AppColors.onPrimary),
        l10n.reportPhotoSent(photo.number ?? 0),
      ),
      PhotoStatus.failed => (
        Icon(
          photo.canRetry ? LucideIcons.refreshCw : LucideIcons.circleX,
          color: AppColors.onPrimary,
        ),
        photo.canRetry
            ? l10n.reportPhotoFailedRetry
            // 409: three photos already, or the hour is over (guide 6.2).
            : photo.failure?.exception is ConflictException
            ? l10n.reportPhotoConflict
            : l10n.reportPhotoRefused,
      ),
    };
    final removable =
        photo.status == PhotoStatus.waiting ||
        (photo.status == PhotoStatus.failed && !photo.canRetry);
    return SizedBox(
      width: 104,
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: photo.canRetry ? onRetry : null,
                child: ClipRRect(
                  borderRadius: AppRadius.input,
                  child: SizedBox.square(
                    dimension: 104,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(photo.bytes, fit: BoxFit.cover),
                        if (overlay != null)
                          ColoredBox(
                            color: AppColors.scrim.withValues(alpha: 0.45),
                            child: Center(child: overlay),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (removable)
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton.filledTonal(
                    tooltip: AppLocalizations.of(context).removeItem,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: onRemove,
                  ),
                ),
            ],
          ),
          if (hint != null)
            // A 429 counts down before the photo can be sent again.
            RetryCountdown(
              until: photo.retryAt,
              builder: (context, seconds) => Text(
                seconds > 0 ? l10n.errorRateLimited(seconds) : hint,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('report.addPhoto'),
    onTap: onTap,
    borderRadius: AppRadius.input,
    child: Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.imagePlus, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    ),
  );
}
