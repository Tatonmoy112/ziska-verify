import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ziska_verify/core/pagination/paginated_state.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/buttons/app_button.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';
import 'package:ziska_verify/shared/widgets/app_empty_state.dart';
import 'package:ziska_verify/shared/widgets/failure_banner.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// A cursor-paged list (final.md Sections 10.4, 14.1). Builds every status
/// and asks for the next page when the list is scrolled to within 5 items
/// of the end. Feature screens never build pagination UI themselves.
class AppPaginatedList<T> extends StatelessWidget {
  const AppPaginatedList({
    required this.state,
    required this.itemBuilder,
    required this.placeholderItem,
    required this.onNextPage,
    required this.onRetry,
    required this.onRefresh,
    required this.emptyTitle,
    this.emptyBody,
    this.header,
    super.key,
  });

  final PaginatedState<T> state;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// A sample item drawn as the loading skeleton.
  final T placeholderItem;
  final VoidCallback onNextPage;

  /// Retries the page that failed (first or next).
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String? emptyBody;

  /// Shown above the items (filters, totals); scrolls with the list.
  final Widget? header;

  static const _prefetchDistance = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = state.items;
    final Widget body;

    switch (state.status) {
      case PaginationStatus.initial:
      case PaginationStatus.loadingFirst when items.isEmpty:
        body = Skeletonizer(
          child: Column(
            children: [
              for (var i = 0; i < 6; i++) itemBuilder(context, placeholderItem),
            ],
          ),
        );
      case PaginationStatus.empty:
        body = AppEmptyState(
          icon: LucideIcons.inbox,
          title: emptyTitle,
          body: emptyBody,
        );
      case PaginationStatus.failureFirst:
        body = Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screen,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              FailureBanner(
                failure: state.failure!,
                retryAt: state.retryAt,
                message: state.failure!.message(l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              // After a 429 the banner counts down; Retry waits for it.
              RetryCountdown(
                until: state.retryAt,
                builder: (_, wait) => AppButton(
                  label: l10n.retry,
                  onPressed: wait > 0 ? null : onRetry,
                ),
              ),
            ],
          ),
        );
      case PaginationStatus.loadingFirst:
      case PaginationStatus.success:
      case PaginationStatus.loadingMore:
      case PaginationStatus.failureMore:
        body = const SizedBox.shrink();
    }

    final showItems =
        items.isNotEmpty &&
        state.status != PaginationStatus.failureFirst &&
        state.status != PaginationStatus.empty;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount:
            (header == null ? 0 : 1) + (showItems ? items.length : 1) + 1,
        itemBuilder: (context, index) {
          var i = index;
          if (header != null) {
            if (i == 0) return header!;
            i -= 1;
          }
          if (!showItems) {
            return i == 0 ? body : const SizedBox.shrink();
          }
          if (i < items.length) {
            // The next page is asked for near the end; the BLoC drops
            // repeats while one is in flight (Section 10.5). Only after a
            // page that arrived: a failed page waits for Retry, never
            // asked again by itself (Section 10.6).
            if (i >= items.length - _prefetchDistance &&
                state.status == PaginationStatus.success &&
                state.canLoadMore) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onNextPage(),
              );
            }
            return itemBuilder(context, items[i]);
          }
          return _Footer(state: state, onRetry: onRetry);
        },
      ),
    );
  }
}

class _Footer<T> extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});

  final PaginatedState<T> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (state.status) {
      PaginationStatus.loadingMore ||
      PaginationStatus.loadingFirst => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      PaginationStatus.failureMore => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            FailureBanner(
              failure: state.failure!,
              retryAt: state.retryAt,
              message: state.failure!.message(l10n),
            ),
            const SizedBox(height: AppSpacing.sm),
            RetryCountdown(
              until: state.retryAt,
              builder: (_, wait) => AppButton(
                label: l10n.retry,
                variant: AppButtonVariant.outlined,
                onPressed: wait > 0 ? null : onRetry,
              ),
            ),
          ],
        ),
      ),
      _ when state.hasReachedEnd => const SizedBox(height: AppSpacing.lg),
      _ => const SizedBox.shrink(),
    };
  }
}
