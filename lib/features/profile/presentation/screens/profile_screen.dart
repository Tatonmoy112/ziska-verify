import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_radius.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';
import 'package:ziska_verify/shared/widgets/icon_action_tile.dart';
import 'package:ziska_verify/shared/widgets/label_value_row.dart';
import 'package:ziska_verify/shared/widgets/navy_status_bar.dart';
import 'package:ziska_verify/shared/widgets/tab_visibility.dart';

/// The Profile tab (Figma "Profile"; final.md §13.7). Actions and
/// content that belong to other features are passed in by the router.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.versionInfo,
    required this.onChooseLanguage,
    required this.onChangePassword,
    required this.onContactSupport,
    required this.onLogout,
    this.totals,
    super.key,
  });

  final Future<({String version, String build})> versionInfo;

  /// The official's check counts: a `card` from History, and `refresh`,
  /// called each time the tab comes into view and on a pull. Given only to
  /// a profile that can read History; without it there are no counts and
  /// the pull does nothing.
  final ({Widget card, Future<void> Function() refresh})? totals;

  /// Applies the language `en` or `bn` at once and keeps it on the phone.
  final Future<void> Function(String languageCode) onChooseLanguage;
  final VoidCallback onChangePassword;

  /// Opens the mail app for `email` or the dialler for `phone`; `false`
  /// when the phone has no such app.
  final Future<bool> Function({String? email, String? phone}) onContactSupport;
  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TabVisibility {
  /// Whether the tab was in view at the last check; the shell turns
  /// tickers off for the tabs it keeps off stage.

  /// Log out is running: the button spins (the login ends either way).
  bool _loggingOut = false;

  /// Each time the tab comes into view, the counts are asked for again.
  @override
  void onTabShown({required bool firstTime}) =>
      unawaited(widget.totals?.refresh());

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    // Profile may be gone by the answer (the login ended and the router
    // moved on): there is nothing left to log out of (P-20).
    if (!mounted || !(confirmed ?? false) || _loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  /// The languages offered, each named in its own language.
  static const _languages = [('en', 'English'), ('bn', 'বাংলা')];

  static String _languageName(String code) => _languages
      .firstWhere((l) => l.$1 == code, orElse: () => _languages.first)
      .$2;

  /// English or Bangla, the current one marked (final.md §13.7).
  Future<void> _chooseLanguage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.xs,
              ),
              child: Semantics(
                header: true,
                child: Text(l10n.languageTitle, style: AppTypography.heading),
              ),
            ),
            for (final (code, name) in _languages)
              ListTile(
                key: Key('language.$code'),
                selected: code == current,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                title: Text(name, style: AppTypography.bodyStrong),
                trailing: code == current
                    ? const Icon(LucideIcons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(code),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) {
      await widget.onChooseLanguage(picked);
    }
  }

  /// Contacts support; says so when the phone has no mail or phone app.
  Future<void> _contact(
    BuildContext context, {
    String? email,
    String? phone,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final opened = await widget.onContactSupport(email: email, phone: phone);
    if (opened) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          email != null ? l10n.noMailApp(email) : l10n.noPhoneApp(phone!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<ProfileCubit>().state.profile;
    if (profile == null) return const SizedBox.shrink();
    final supportEmail = profile.supportEmail;
    final supportPhone = profile.supportPhone;

    final totals = widget.totals;

    return NavyStatusBar(
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        body: RefreshIndicator(
          // Pull to refresh asks for the counts again (the profile itself is
          // loaded at start).
          onRefresh: () async => totals?.refresh(),
          notificationPredicate: (_) => totals != null,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _HeaderAndCard(
                profile: profile,
                title: l10n.profileTitle,
                rows: [
                  _InfoRow(
                    label: l10n.organisationLabel,
                    value: profile.organisation ?? '—',
                  ),
                  _InfoRow(label: l10n.emailLabel, value: profile.email),
                  _InfoRow(label: l10n.roleLabel, value: profile.role),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  AppSpacing.screen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (totals != null) ...[
                      totals.card,
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    // What the role allows, by the SRS names (FR-ACC-15).
                    Text(
                      l10n.permissionsSection,
                      style: AppTypography.fieldLabel,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _Card(
                      key: const Key('profile.permissions'),
                      children: [
                        for (final (permission, icon, title) in [
                          (
                            Permission.lookup,
                            LucideIcons.shieldCheck,
                            l10n.permissionLookup,
                          ),
                          (
                            Permission.bulkLookup,
                            LucideIcons.layers,
                            l10n.permissionBulkLookup,
                          ),
                          (
                            Permission.ownHistory,
                            LucideIcons.clock,
                            l10n.permissionHistory,
                          ),
                          (
                            Permission.report,
                            LucideIcons.flag,
                            l10n.permissionReport,
                          ),
                        ])
                          if (profile.can(permission))
                            IconActionTile(
                              contentPadding: _rowPadding,
                              key: Key('profile.permission.${permission.key}'),
                              icon: icon,
                              title: title,
                            ),
                        // Only the app's permissions are kept (the mapper).
                        if (profile.permissions.isEmpty)
                          IconActionTile(
                            contentPadding: _rowPadding,
                            icon: LucideIcons.circleSlash,
                            title: l10n.permissionsNone,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(l10n.accountSection, style: AppTypography.fieldLabel),
                    const SizedBox(height: AppSpacing.xs),
                    _Card(
                      children: [
                        IconActionTile(
                          contentPadding: _rowPadding,
                          icon: LucideIcons.lock,
                          title: l10n.changePasswordRow,
                          onTap: widget.onChangePassword,
                        ),
                        IconActionTile(
                          contentPadding: _rowPadding,
                          key: const Key('profile.language'),
                          icon: LucideIcons.languages,
                          title: l10n.languageRow,
                          subtitle: _languageName(
                            Localizations.localeOf(context).languageCode,
                          ),
                          onTap: () => unawaited(_chooseLanguage(context)),
                        ),
                        // Each channel the office set (guide section 3.8):
                        // email and phone both, or "Not set".
                        if (supportEmail != null)
                          IconActionTile(
                            contentPadding: _rowPadding,
                            key: const Key('profile.supportEmail'),
                            icon: LucideIcons.mail,
                            title: l10n.supportContactRow,
                            subtitle: supportEmail,
                            onTap: () => unawaited(
                              _contact(context, email: supportEmail),
                            ),
                          ),
                        if (supportPhone != null)
                          IconActionTile(
                            contentPadding: _rowPadding,
                            key: const Key('profile.supportPhone'),
                            icon: LucideIcons.phone,
                            title: l10n.supportContactRow,
                            subtitle: supportPhone,
                            onTap: () => unawaited(
                              _contact(context, phone: supportPhone),
                            ),
                          ),
                        if (supportEmail == null && supportPhone == null)
                          IconActionTile(
                            contentPadding: _rowPadding,
                            icon: LucideIcons.mail,
                            title: l10n.supportContactRow,
                            subtitle: l10n.supportNotSet,
                          ),
                        FutureBuilder(
                          future: widget.versionInfo,
                          builder: (context, snapshot) => IconActionTile(
                            contentPadding: _rowPadding,
                            icon: LucideIcons.clock,
                            title: l10n.appVersionRow,
                            subtitle: snapshot.data == null
                                ? null
                                : l10n.appVersionValue(
                                    snapshot.data!.version,
                                    snapshot.data!.build,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      key: const Key('profile.logout'),
                      variant: AppButtonVariant.danger,
                      icon: LucideIcons.logOut,
                      label: l10n.logout,
                      loading: _loggingOut,
                      onPressed: _loggingOut
                          ? null
                          : () => unawaited(_confirmLogout(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The navy band with the title, and the white identity card overlapping
/// it (Figma "Profile"): the initials in a round avatar standing over the
/// card's top edge, the name, the role as a green pill, then the rows.
class _HeaderAndCard extends StatelessWidget {
  const _HeaderAndCard({
    required this.profile,
    required this.title,
    required this.rows,
  });

  final Profile profile;
  final String title;
  final List<Widget> rows;

  static const _avatar = 72.0;

  /// How far the card reaches up into the navy band.
  static const _overlap = 40.0;

  String get _initials {
    final parts = profile.name.trim().split(RegExp(r'\s+'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.characters.first.toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    // The band holds the title (it grows with the font size) and the part
    // of the card that overlaps it.
    final titleHeight = MediaQuery.textScalerOf(
      context,
    ).scale(AppTypography.headline.fontSize! * AppTypography.headline.height!);
    // The avatar's top sits a gap under the title; the card's top runs
    // through the avatar's middle.
    final cardTop =
        top + AppSpacing.md + titleHeight + AppSpacing.md + _avatar / 2;
    final band = cardTop + _overlap;

    return Stack(
      children: [
        SizedBox(
          height: band,
          width: double.infinity,
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                top + AppSpacing.md,
                AppSpacing.screen,
                0,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            cardTop,
            AppSpacing.screen,
            0,
          ),
          child: _Card(
            key: const Key('profile.identity'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: _avatar),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.name, style: AppTypography.heading),
                          const SizedBox(height: AppSpacing.xxs),
                          _RolePill(role: profile.role),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ...rows,
            ],
          ),
        ),
        // The avatar stands half over the card's top edge.
        Positioned(
          left: AppSpacing.screen + AppSpacing.md,
          top: cardTop - _avatar / 2,
          child: ExcludeSemantics(
            child: Container(
              key: const Key('profile.avatar'),
              width: _avatar,
              height: _avatar,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                _initials,
                style: AppTypography.headline.copyWith(
                  color: AppColors.onPrimary,
                ),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The role as a green pill with a dot ("● FIELD INSPECTOR").
class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('profile.role'),
      decoration: const BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: 6),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                role.toUpperCase(),
                style: AppTypography.fieldLabel.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
                color: AppColors.border,
              ),
            child,
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: LabelValueRow(label: label, value: value, oneLine: true),
    );
  }
}

/// Profile's rows: a little room above and below (P-40).
const _rowPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.md,
  vertical: AppSpacing.xxs,
);
