import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/warranty_item.dart';
import '../../l10n/app_localizations.dart';
import '../providers/repository_providers.dart';
import '../providers/search_filter_provider.dart';
import '../providers/warranty_items_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/empty_state.dart';
import '../widgets/warranty_item_card.dart';

/// Dashboard — Premium "Warranty Wallet" home screen.
///
/// Design:
/// * Minimal AppBar with logo + greeting
/// * Rounded search bar
/// * Gradient summary card (Teal → Blue)
/// * Segmented tab bar + category filter chips
/// * Shadow-based product cards (no borders)
/// * Pull-to-refresh (no refresh button in AppBar)
/// * Large rounded FAB
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(warrantyFilterProvider.notifier)
            .set(WarrantyFilter.values[_tabController.index]);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(warrantyItemsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() =>
      ref.read(warrantyItemsProvider.notifier).refresh();

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 450) return;

    final nextIndex = velocity < 0
        ? _tabController.index + 1
        : _tabController.index - 1;
    if (nextIndex < 0 || nextIndex >= _tabController.length) return;

    _tabController.animateTo(nextIndex);
    ref
        .read(warrantyFilterProvider.notifier)
        .set(WarrantyFilter.values[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(filteredItemsProvider);
    final allItems = ref.watch(warrantyItemsProvider);
    final repoAsync = ref.watch(warrantyRepositoryProvider);
    final theme = Theme.of(context);

    // Summary stats computed from ALL items (the filters don't apply here).
    //
    // "active" = warranty still in force (i.e. not yet expired), which
    // includes both the green "active" and amber "expiring soon" sub-states.
    final activeTimerCount = allItems.where((i) => !i.isExpired).length;
    final expiredCount = allItems.where((i) => i.isExpired).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: repoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: '$e', l: l),
        data: (_) => RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.brandBlue,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: _onHorizontalSwipe,
            child: CustomScrollView(
              slivers: [
                // ── Premium header (no AppBar widget) ──────────────
                SliverToBoxAdapter(child: _Header(l: l)),

                // ── Search bar ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SearchBar(
                    controller: _searchController,
                    l: l,
                    onChanged: (v) =>
                        ref.read(searchQueryProvider.notifier).set(v),
                  ),
                ),

                // ── Gradient summary card ──────────────────────────
                if (allItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SummaryCard(
                      total: allItems.length,
                      active: activeTimerCount,
                      expired: expiredCount,
                      l: l,
                    ),
                  ),

                // ── Tab bar (filter) ───────────────────────────────
                SliverToBoxAdapter(
                  child: _FilterTabs(controller: _tabController, l: l),
                ),

                // ── Category chips ─────────────────────────────────
                SliverToBoxAdapter(child: _CategoryChips(l: l)),

                // ── Product list ───────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  sliver: items.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                background: _DismissBackground(l: l),
                                confirmDismiss: (_) =>
                                    _confirmDismiss(context, l, item),
                                onDismissed: (_) async {
                                  await ref
                                      .read(warrantyItemsProvider.notifier)
                                      .deleteItem(item.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l.deletedItem.withName(
                                          item.productName,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: WarrantyItemCard(item: item),
                              ),
                            );
                          }, childCount: items.length),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppConstants.routeAddEdit);
          if (mounted) {
            ref.read(warrantyItemsProvider.notifier).refresh();
          }
        },
        tooltip: l.addWarrantyTitle,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Future<bool?> _confirmDismiss(
    BuildContext context,
    AppLocalizations l,
    WarrantyItem item,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteItemTitle),
        content: Text(l.deleteItemBody.withName(item.productName)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: OutlinedButton.styleFrom(minimumSize: const Size(112, 48)),
              child: Text(l.cancel),
            ),
          ),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                minimumSize: const Size(112, 48),
              ),
              child: Text(l.delete),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        12,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppLogo(size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warrantify',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.brandBlueDeep,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Appearance (theme) icon
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.palette_outlined,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () => context.push(AppConstants.routeAppearance),
            tooltip: l.appearance,
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.l,
    required this.onChanged,
  });
  final TextEditingController controller;
  final AppLocalizations l;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: l.searchHint,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, _) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      controller.clear();
                      // Manually notify provider since clear() doesn't
                      // trigger onChanged.
                      onChanged('');
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.active,
    required this.expired,
    required this.l,
  });

  /// Total number of tracked items.
  final int total;

  /// Items whose warranty is still in force (not yet expired).
  final int active;

  /// Items whose warranty has already lapsed.
  final int expired;

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.summaryCardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandBlue.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.summaryTotal,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatChip(
                  label: l.summaryActive,
                  value: active,
                  color: const Color(0xFF4ADE80),
                ),
                const SizedBox(width: 10),
                _StatChip(
                  label: l.summaryExpired,
                  value: expired,
                  color: const Color(0xFFF87171),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.controller, required this.l});
  final TabController controller;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
        ),
        child: TabBar(
          controller: controller,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: AppTheme.brandBlue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brandBlue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.5),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: l.tabAll),
            Tab(text: l.tabActive),
            Tab(text: l.tabExpired),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(usedCategoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);
    if (categories.isEmpty) return const SizedBox(height: 8);

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ...categories.map((c) {
            final isSel = selected == c;
            return _Chip(
              label: c.localizedName(l),
              selected: isSel,
              onTap: () => ref
                  .read(selectedCategoryProvider.notifier)
                  .set(isSel ? null : c),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.brandBlue
                : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.brandBlue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: AppTheme.expired,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            l.dismissDeleteLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.l});
  final String message;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.expired.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.expired,
              ),
            ),
            const SizedBox(height: 16),
            Text(l.loadFailed, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
