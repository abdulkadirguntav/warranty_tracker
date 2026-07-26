import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_tracker/core/utils/warranty_calculator.dart';

void main() {
  group('WarrantyCalculator.calculateEndDate', () {
    test('adds months correctly within the same year', () {
      final result = WarrantyCalculator.calculateEndDate(
        purchaseDate: DateTime(2026, 1, 15),
        warrantyDurationInMonths: 6,
      );
      expect(result, DateTime(2026, 7, 15));
    });

    test('crosses year boundary correctly', () {
      final result = WarrantyCalculator.calculateEndDate(
        purchaseDate: DateTime(2026, 11, 15),
        warrantyDurationInMonths: 3,
      );
      expect(result, DateTime(2027, 2, 15));
    });

    test('handles month overflow (Jan 31 + 1 month => Feb 28)', () {
      final result = WarrantyCalculator.calculateEndDate(
        purchaseDate: DateTime(2026, 1, 31),
        warrantyDurationInMonths: 1,
      );
      expect(result, DateTime(2026, 2, 28));
    });

    test(
      'handles month overflow in leap year (Jan 31 + 1 month => Feb 29)',
      () {
        final result = WarrantyCalculator.calculateEndDate(
          purchaseDate: DateTime(2024, 1, 31),
          warrantyDurationInMonths: 1,
        );
        expect(result, DateTime(2024, 2, 29));
      },
    );

    test('handles 24 months (2 years)', () {
      final result = WarrantyCalculator.calculateEndDate(
        purchaseDate: DateTime(2026, 3, 10),
        warrantyDurationInMonths: 24,
      );
      expect(result, DateTime(2028, 3, 10));
    });

    test('handles 0 months returns same date', () {
      final result = WarrantyCalculator.calculateEndDate(
        purchaseDate: DateTime(2026, 6, 15),
        warrantyDurationInMonths: 0,
      );
      expect(result, DateTime(2026, 6, 15));
    });
  });

  group('WarrantyCalculator.calculateEndDateEx (extended warranty)', () {
    test('adds months to a base date correctly', () {
      final base = DateTime(2026, 6, 15);
      final result = WarrantyCalculator.calculateEndDateEx(
        baseDate: base,
        additionalMonths: 12,
      );
      expect(result, DateTime(2027, 6, 15));
    });

    test('handles month overflow (Jan 31 + 1 month => Feb 28)', () {
      final base = DateTime(2026, 1, 31);
      final result = WarrantyCalculator.calculateEndDateEx(
        baseDate: base,
        additionalMonths: 1,
      );
      expect(result, DateTime(2026, 2, 28));
    });

    test('adds 6 months to base date', () {
      final base = DateTime(2026, 9, 20);
      final result = WarrantyCalculator.calculateEndDateEx(
        baseDate: base,
        additionalMonths: 6,
      );
      expect(result, DateTime(2027, 3, 20));
    });
  });

  group('WarrantyCalculator.remainingDays', () {
    test('returns positive days when end date is in the future', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2026, 7, 23);
      expect(WarrantyCalculator.remainingDays(endDate, now: now), 10);
    });

    test('returns negative days when end date is in the past', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2026, 7, 3);
      expect(WarrantyCalculator.remainingDays(endDate, now: now), -10);
    });

    test('returns 0 when end date is today', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2026, 7, 13);
      expect(WarrantyCalculator.remainingDays(endDate, now: now), 0);
    });
  });

  group('WarrantyCalculator.level', () {
    test('returns active when more than 90 days remain', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2027, 7, 13);
      expect(
        WarrantyCalculator.level(endDate: endDate, now: now),
        WarrantyLevel.active,
      );
    });

    test('returns expiringSoon when <= 90 days remain', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2026, 8, 13);
      expect(
        WarrantyCalculator.level(endDate: endDate, now: now),
        WarrantyLevel.expiringSoon,
      );
    });

    test('returns expired when end date is in the past', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2026, 6, 13);
      expect(
        WarrantyCalculator.level(endDate: endDate, now: now),
        WarrantyLevel.expired,
      );
    });

    test('returns expiringSoon at exactly 90 days', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2026, 10, 11);
      final days = WarrantyCalculator.remainingDays(endDate, now: now);
      expect(days, 90);
      expect(
        WarrantyCalculator.level(endDate: endDate, now: now),
        WarrantyLevel.expiringSoon,
      );
    });

    test('respects custom threshold', () {
      final now = DateTime(2026, 7, 13);
      final endDate = DateTime(2026, 7, 20);
      expect(
        WarrantyCalculator.level(
          endDate: endDate,
          now: now,
          expiringSoonThreshold: 7,
        ),
        WarrantyLevel.expiringSoon,
      );
    });
  });

  group('WarrantyCalculator.reminderDaysBefore', () {
    test('contains the correct reminder intervals', () {
      expect(WarrantyCalculator.reminderDaysBefore, [90, 60, 30, 15, 7, 1]);
    });

    test('expirationDayId is -1', () {
      expect(WarrantyCalculator.expirationDayId, -1);
    });
  });
}
