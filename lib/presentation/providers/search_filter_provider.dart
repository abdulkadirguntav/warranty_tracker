import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/brand_category.dart';
import '../../domain/entities/warranty_item.dart';
import 'warranty_items_provider.dart';

/// Filter tabs on the dashboard.
///
/// Kept intentionally simple: an item is either still under warranty ([active])
/// or its warranty has already lapsed ([expired]); "expiring soon" is only a
/// visual hint (badge / ring colour), not a separate filter bucket.
enum WarrantyFilter { all, active, expired }

/// Search query string (empty = no search).
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Selected category for filtering (null = all categories).
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, BrandCategory?>(
      SelectedCategoryNotifier.new,
    );

class SelectedCategoryNotifier extends Notifier<BrandCategory?> {
  @override
  BrandCategory? build() => null;

  void set(BrandCategory? category) {
    state = category;
  }
}

/// Selected warranty status filter.
final warrantyFilterProvider =
    NotifierProvider<WarrantyFilterNotifier, WarrantyFilter>(
      WarrantyFilterNotifier.new,
    );

class WarrantyFilterNotifier extends Notifier<WarrantyFilter> {
  @override
  WarrantyFilter build() => WarrantyFilter.all;

  void set(WarrantyFilter filter) {
    state = filter;
  }
}

/// Derived list of items after applying search, category, and status
/// filters. Stays sorted by nearest effective expiration date.
final filteredItemsProvider = Provider<List<WarrantyItem>>((ref) {
  final items = ref.watch(warrantyItemsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final category = ref.watch(selectedCategoryProvider);
  final filter = ref.watch(warrantyFilterProvider);

  var result = items.where((item) {
    // Search filter: product name, category label, notes.
    if (query.isNotEmpty) {
      final nameMatch = item.productName.toLowerCase().contains(query);
      final categoryMatch = _matchesCategoryLabel(item.brandCategory, query);
      if (!nameMatch && !categoryMatch) {
        final notesMatch = item.notes.toLowerCase().contains(query);
        if (!notesMatch) return false;
      }
    }

    // Category filter (matches canonical label; localized selection is
    // resolved to a BrandCategory instance by the UI before calling set()).
    if (category != null) {
      if (item.brandCategory != category.label) return false;
    }

    // Status filter.
    //
    // "active" means "not yet expired" so the tab surfaces every product
    // whose warranty is still in force, regardless of how close it is to
    // expiring. "expired" surfaces only items past their effective end date.
    switch (filter) {
      case WarrantyFilter.all:
        break;
      case WarrantyFilter.active:
        if (item.isExpired) return false;
      case WarrantyFilter.expired:
        if (!item.isExpired) return false;
    }

    return true;
  }).toList();

  // Re-sort: nearest effective expiration first.
  result.sort((a, b) {
    final aEnd = a.effectiveEndDate;
    final bEnd = b.effectiveEndDate;
    if (aEnd != bEnd) return aEnd.compareTo(bEnd);
    return a.productName.compareTo(b.productName);
  });

  return result;
});

/// Returns true if the lowercase [query] matches either the canonical
/// English category label for [canonicalLabel] or any of its localized
/// variants (EN / TR). Keeps search consistent across locales.
bool _matchesCategoryLabel(String canonicalLabel, String query) {
  if (canonicalLabel.toLowerCase().contains(query)) return true;
  for (final cat in BrandCategory.all) {
    if (cat.label == canonicalLabel) {
      for (final name in cat.allLocalizedNames) {
        if (name.toLowerCase().contains(query)) return true;
      }
    }
  }
  return false;
}

/// List of categories that are actually used by existing items.
final usedCategoriesProvider = Provider<List<BrandCategory>>((ref) {
  final items = ref.watch(warrantyItemsProvider);
  final usedLabels = items.map((i) => i.brandCategory).toSet();
  return BrandCategory.all.where((c) => usedLabels.contains(c.label)).toList();
});
