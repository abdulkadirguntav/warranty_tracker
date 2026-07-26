import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_tracker/domain/entities/brand_category.dart';
import 'package:warranty_tracker/domain/entities/warranty_item.dart';
import 'package:warranty_tracker/presentation/providers/search_filter_provider.dart';
import 'package:warranty_tracker/presentation/providers/warranty_items_provider.dart';

/// Tests for the dashboard filtering and search logic.
///
/// These tests use a ProviderContainer with overrides to inject mock
/// warranty items and verify that the [filteredItemsProvider] correctly
/// applies search queries, category filters, and status filters.
void main() {
  late List<WarrantyItem> mockItems;

  setUp(() {
    final now = DateTime.now();
    mockItems = [
      // Active item (Electronics)
      WarrantyItem(
        id: 'active-1',
        productName: 'Galaxy S24 Ultra',
        brandCategory: BrandCategory.electronics.label,
        purchaseDate: now.subtract(const Duration(days: 10)),
        warrantyDurationInMonths: 24,
        endDate: now.add(const Duration(days: 700)),
        notes: 'Bought at Best Buy',
      ),
      // Expiring soon item (Mobile)
      WarrantyItem(
        id: 'expiring-1',
        productName: 'iPhone 15 Pro',
        brandCategory: BrandCategory.mobile.label,
        purchaseDate: now.subtract(const Duration(days: 340)),
        warrantyDurationInMonths: 12,
        endDate: now.add(const Duration(days: 25)),
        notes: 'Serial: ABC123',
      ),
      // Expired item (Computer)
      WarrantyItem(
        id: 'expired-1',
        productName: 'Dell XPS 15',
        brandCategory: BrandCategory.computer.label,
        purchaseDate: now.subtract(const Duration(days: 800)),
        warrantyDurationInMonths: 12,
        endDate: now.subtract(const Duration(days: 400)),
        notes: 'Need to check warranty',
      ),
      // Active item with extended warranty (Electronics)
      WarrantyItem(
        id: 'active-extended-1',
        productName: 'Sony TV',
        brandCategory: BrandCategory.electronics.label,
        purchaseDate: now.subtract(const Duration(days: 340)),
        warrantyDurationInMonths: 12,
        endDate: now.subtract(const Duration(days: 5)),
        extendedWarrantyMonths: 12,
        notes: 'Extended warranty purchased',
      ),
    ];
  });

  ProviderContainer createContainer({
    String searchQuery = '',
    BrandCategory? selectedCategory,
    WarrantyFilter filter = WarrantyFilter.all,
  }) {
    final container = ProviderContainer(
      overrides: [
        warrantyItemsProvider.overrideWith(() {
          return _MockItemsNotifier(mockItems);
        }),
      ],
    );

    // Set provider states.
    container.read(searchQueryProvider.notifier).set(searchQuery);
    container.read(selectedCategoryProvider.notifier).set(selectedCategory);
    container.read(warrantyFilterProvider.notifier).set(filter);

    return container;
  }

  group('filteredItemsProvider - no filters', () {
    test('returns all items sorted by nearest effective expiration', () {
      final container = createContainer();
      final items = container.read(filteredItemsProvider);

      expect(items.length, 4);
      // expired-1 should be first (most negative effective end date).
      // active-extended-1: effective end = endDate + 12 months = ~360 days from now
      // expiring-1: 25 days from now
      // active-1: 700 days from now
      // expired-1: -400 days from now
      expect(items[0].id, 'expired-1');
      expect(items[1].id, 'expiring-1');
      expect(items[2].id, 'active-extended-1');
      expect(items[3].id, 'active-1');

      container.dispose();
    });
  });

  group('filteredItemsProvider - search', () {
    test('filters by product name', () {
      final container = createContainer(searchQuery: 'iPhone');
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'expiring-1');

      container.dispose();
    });

    test('filters by category label', () {
      final container = createContainer(searchQuery: 'mobile');
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'expiring-1');

      container.dispose();
    });

    test('filters by notes', () {
      final container = createContainer(searchQuery: 'Best Buy');
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'active-1');

      container.dispose();
    });

    test('search is case-insensitive', () {
      final container = createContainer(searchQuery: 'galaxy');
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'active-1');

      container.dispose();
    });

    test('returns all items when query is empty', () {
      final container = createContainer(searchQuery: '');
      final items = container.read(filteredItemsProvider);

      expect(items.length, 4);

      container.dispose();
    });

    test('returns no items when query matches nothing', () {
      final container = createContainer(searchQuery: 'nonexistent');
      final items = container.read(filteredItemsProvider);

      expect(items, isEmpty);

      container.dispose();
    });
  });

  group('filteredItemsProvider - category filter', () {
    test('filters by Electronics category', () {
      final container = createContainer(
        selectedCategory: BrandCategory.electronics,
      );
      final items = container.read(filteredItemsProvider);

      expect(items.length, 2);
      expect(items.any((i) => i.id == 'active-1'), isTrue);
      expect(items.any((i) => i.id == 'active-extended-1'), isTrue);

      container.dispose();
    });

    test('filters by Computer category', () {
      final container = createContainer(
        selectedCategory: BrandCategory.computer,
      );
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'expired-1');

      container.dispose();
    });

    test('returns all when category is null', () {
      final container = createContainer(selectedCategory: null);
      final items = container.read(filteredItemsProvider);

      expect(items.length, 4);

      container.dispose();
    });
  });

  group('filteredItemsProvider - status filter', () {
    test(
      'active filter returns every item whose warranty has not expired yet',
      () {
        final container = createContainer(filter: WarrantyFilter.active);
        final items = container.read(filteredItemsProvider);

        // active-1 (active), expiring-1 (expiring soon) and
        // active-extended-1 (active via extended warranty) are all still
        // under warranty and should appear under the "Active" tab.
        expect(items.length, 3);
        expect(items.every((i) => !i.isExpired), isTrue);
        expect(items.any((i) => i.id == 'active-1'), isTrue);
        expect(items.any((i) => i.id == 'expiring-1'), isTrue);
        expect(items.any((i) => i.id == 'active-extended-1'), isTrue);
        expect(items.any((i) => i.id == 'expired-1'), isFalse);

        container.dispose();
      },
    );

    test('filters by expired status', () {
      final container = createContainer(filter: WarrantyFilter.expired);
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'expired-1');

      container.dispose();
    });

    test('returns all when filter is all', () {
      final container = createContainer(filter: WarrantyFilter.all);
      final items = container.read(filteredItemsProvider);

      expect(items.length, 4);

      container.dispose();
    });
  });

  group('filteredItemsProvider - combined filters', () {
    test('search + category filter', () {
      final container = createContainer(
        searchQuery: 'Sony',
        selectedCategory: BrandCategory.electronics,
      );
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'active-extended-1');

      container.dispose();
    });

    test('search + status filter', () {
      // 'iPhone' matches the expiring-soon item, which is still under
      // warranty and therefore surfaced by the Active tab.
      final container = createContainer(
        searchQuery: 'iPhone',
        filter: WarrantyFilter.active,
      );
      final items = container.read(filteredItemsProvider);

      expect(items.length, 1);
      expect(items[0].id, 'expiring-1');

      container.dispose();
    });

    test('category + status filter', () {
      final container = createContainer(
        selectedCategory: BrandCategory.electronics,
        filter: WarrantyFilter.active,
      );
      final items = container.read(filteredItemsProvider);

      expect(items.length, 2);

      container.dispose();
    });

    test('all filters combined - no results', () {
      final container = createContainer(
        searchQuery: 'Dell',
        selectedCategory: BrandCategory.electronics,
        filter: WarrantyFilter.active,
      );
      final items = container.read(filteredItemsProvider);

      expect(items, isEmpty);

      container.dispose();
    });
  });

  group('usedCategoriesProvider', () {
    test('returns only categories used by items', () {
      final container = createContainer();
      final categories = container.read(usedCategoriesProvider);

      expect(categories.length, 3);
      expect(categories.any((c) => c == BrandCategory.electronics), isTrue);
      expect(categories.any((c) => c == BrandCategory.mobile), isTrue);
      expect(categories.any((c) => c == BrandCategory.computer), isTrue);
      expect(categories.any((c) => c == BrandCategory.kitchen), isFalse);

      container.dispose();
    });
  });
}

/// Mock notifier that returns a fixed list of items.
class _MockItemsNotifier extends WarrantyItemsNotifier {
  _MockItemsNotifier(this._items);

  final List<WarrantyItem> _items;

  @override
  List<WarrantyItem> build() {
    return _items;
  }
}
