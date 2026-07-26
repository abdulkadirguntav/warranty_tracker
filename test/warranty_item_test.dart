import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_tracker/domain/entities/warranty_item.dart';

void main() {
  group('WarrantyItem.effectiveEndDate', () {
    test('returns original endDate when no extended warranty', () {
      final item = WarrantyItem(
        id: 'test1',
        productName: 'Test Product',
        brandCategory: 'Electronics',
        purchaseDate: DateTime(2026, 1, 1),
        warrantyDurationInMonths: 12,
        endDate: DateTime(2027, 1, 1),
        notes: '',
      );
      expect(item.effectiveEndDate, DateTime(2027, 1, 1));
      expect(item.hasExtendedWarranty, isFalse);
    });

    test('uses extendedWarrantyMonths to compute effective end date', () {
      final item = WarrantyItem(
        id: 'test2',
        productName: 'Test Product',
        brandCategory: 'Electronics',
        purchaseDate: DateTime(2026, 1, 1),
        warrantyDurationInMonths: 12,
        endDate: DateTime(2027, 1, 1),
        extendedWarrantyMonths: 6,
        notes: '',
      );
      expect(item.effectiveEndDate, DateTime(2027, 7, 1));
      expect(item.hasExtendedWarranty, isTrue);
    });

    test('uses explicit extendedWarrantyEndDate when provided', () {
      final item = WarrantyItem(
        id: 'test3',
        productName: 'Test Product',
        brandCategory: 'Electronics',
        purchaseDate: DateTime(2026, 1, 1),
        warrantyDurationInMonths: 12,
        endDate: DateTime(2027, 1, 1),
        extendedWarrantyMonths: 6,
        extendedWarrantyEndDate: DateTime(2027, 12, 1),
        notes: '',
      );
      expect(item.effectiveEndDate, DateTime(2027, 12, 1));
      expect(item.hasExtendedWarranty, isTrue);
    });

    test(
      'extendedWarrantyEndDate takes priority over extendedWarrantyMonths',
      () {
        final item = WarrantyItem(
          id: 'test4',
          productName: 'Test Product',
          brandCategory: 'Electronics',
          purchaseDate: DateTime(2026, 1, 1),
          warrantyDurationInMonths: 12,
          endDate: DateTime(2027, 1, 1),
          extendedWarrantyMonths: 6,
          extendedWarrantyEndDate: DateTime(2028, 6, 1),
          notes: '',
        );
        expect(item.effectiveEndDate, DateTime(2028, 6, 1));
      },
    );

    test(
      'does not treat 0 extendedWarrantyMonths as active extended warranty',
      () {
        final item = WarrantyItem(
          id: 'test5',
          productName: 'Test Product',
          brandCategory: 'Electronics',
          purchaseDate: DateTime(2026, 1, 1),
          warrantyDurationInMonths: 12,
          endDate: DateTime(2027, 1, 1),
          extendedWarrantyMonths: 0,
          notes: '',
        );
        expect(item.hasExtendedWarranty, isFalse);
        expect(item.effectiveEndDate, DateTime(2027, 1, 1));
      },
    );
  });

  group('WarrantyItem.status', () {
    test('returns active when > 90 days remain on effective end date', () {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 200));
      final item = WarrantyItem(
        id: 'active',
        productName: 'Active Product',
        brandCategory: 'Electronics',
        purchaseDate: now.subtract(const Duration(days: 10)),
        warrantyDurationInMonths: 24,
        endDate: endDate,
        notes: '',
      );
      expect(item.status, WarrantyStatus.active);
    });

    test(
      'returns expiringSoon when <= 90 days remain on effective end date',
      () {
        final now = DateTime.now();
        final endDate = now.add(const Duration(days: 30));
        final item = WarrantyItem(
          id: 'expiring',
          productName: 'Expiring Product',
          brandCategory: 'Electronics',
          purchaseDate: now.subtract(const Duration(days: 335)),
          warrantyDurationInMonths: 12,
          endDate: endDate,
          notes: '',
        );
        expect(item.status, WarrantyStatus.expiringSoon);
      },
    );

    test('returns expired when effective end date is in the past', () {
      final now = DateTime.now();
      final item = WarrantyItem(
        id: 'expired',
        productName: 'Expired Product',
        brandCategory: 'Electronics',
        purchaseDate: now.subtract(const Duration(days: 400)),
        warrantyDurationInMonths: 12,
        endDate: now.subtract(const Duration(days: 400)),
        notes: '',
      );
      expect(item.status, WarrantyStatus.expired);
    });

    test(
      'uses effectiveEndDate for status when extended warranty is active',
      () {
        final now = DateTime.now();
        final originalEnd = now.subtract(const Duration(days: 10));
        final extendedEnd = now.add(const Duration(days: 200));
        final item = WarrantyItem(
          id: 'extended',
          productName: 'Extended Product',
          brandCategory: 'Electronics',
          purchaseDate: now.subtract(const Duration(days: 400)),
          warrantyDurationInMonths: 12,
          endDate: originalEnd,
          extendedWarrantyEndDate: extendedEnd,
          notes: '',
        );
        expect(item.status, WarrantyStatus.active);
      },
    );
  });

  group('WarrantyItem.copyWith', () {
    test('preserves fields not overwritten', () {
      final item = WarrantyItem(
        id: 'copy-test',
        productName: 'Original',
        brandCategory: 'Electronics',
        purchaseDate: DateTime(2026, 1, 1),
        warrantyDurationInMonths: 12,
        endDate: DateTime(2027, 1, 1),
        notes: 'some notes',
      );
      final copy = item.copyWith(productName: 'Updated');
      expect(copy.productName, 'Updated');
      expect(copy.brandCategory, 'Electronics');
      expect(copy.endDate, DateTime(2027, 1, 1));
      expect(copy.notes, 'some notes');
    });

    test('can clear extended warranty fields', () {
      final item = WarrantyItem(
        id: 'clear-test',
        productName: 'Product',
        brandCategory: 'Electronics',
        purchaseDate: DateTime(2026, 1, 1),
        warrantyDurationInMonths: 12,
        endDate: DateTime(2027, 1, 1),
        extendedWarrantyMonths: 6,
        extendedWarrantyEndDate: DateTime(2027, 7, 1),
        notes: '',
      );
      final copy = item.copyWith(
        clearExtendedWarrantyMonths: true,
        clearExtendedWarrantyEndDate: true,
      );
      expect(copy.extendedWarrantyMonths, isNull);
      expect(copy.extendedWarrantyEndDate, isNull);
      expect(copy.hasExtendedWarranty, isFalse);
    });
  });

  group('WarrantyItem.progress', () {
    test('returns 0.0 for a just-purchased item', () {
      final now = DateTime.now();
      final item = WarrantyItem(
        id: 'progress-test',
        productName: 'Test',
        brandCategory: 'Electronics',
        purchaseDate: now,
        warrantyDurationInMonths: 12,
        endDate: now.add(const Duration(days: 365)),
        notes: '',
      );
      expect(item.progress, lessThan(0.01));
    });

    test('returns value between 0 and 1 for half-elapsed warranty', () {
      final now = DateTime.now();
      final totalDays = 365;
      final elapsed = 180;
      final item = WarrantyItem(
        id: 'progress-test2',
        productName: 'Test',
        brandCategory: 'Electronics',
        purchaseDate: now.subtract(Duration(days: elapsed)),
        warrantyDurationInMonths: 12,
        endDate: now.add(Duration(days: totalDays - elapsed)),
        notes: '',
      );
      final progress = item.progress;
      expect(progress, greaterThan(0.4));
      expect(progress, lessThan(0.6));
    });
  });
}
