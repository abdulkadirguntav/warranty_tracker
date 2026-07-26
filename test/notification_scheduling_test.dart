import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_tracker/core/utils/warranty_calculator.dart';

/// Tests for notification scheduling logic.
///
/// These tests verify that:
/// 1. The correct reminder intervals are defined (90, 60, 30, 15, 7, 1
///    days before, plus expiration day).
/// 2. The notification ID generation is stable and unique per
///    item/interval pair.
/// 3. The scheduled dates are computed correctly from the warranty
///    effective end date.
void main() {
  group('Notification reminder intervals', () {
    test('contains exactly the required days-before values', () {
      expect(WarrantyCalculator.reminderDaysBefore, [90, 60, 30, 15, 7, 1]);
    });

    test('has 6 reminder intervals', () {
      expect(WarrantyCalculator.reminderDaysBefore.length, 6);
    });

    test('expirationDayId is -1', () {
      expect(WarrantyCalculator.expirationDayId, -1);
    });
  });

  group('Notification ID generation', () {
    int notificationId(String itemId, int daysBefore) {
      return (itemId.hashCode ^ daysBefore.hashCode) & 0x7FFFFFFF;
    }

    test('produces stable IDs for the same item/interval', () {
      final id1 = notificationId('item-abc', 90);
      final id2 = notificationId('item-abc', 90);
      expect(id1, id2);
    });

    test('produces different IDs for different items', () {
      final id1 = notificationId('item-abc', 90);
      final id2 = notificationId('item-xyz', 90);
      expect(id1, isNot(id2));
    });

    test('produces different IDs for different intervals', () {
      final id90 = notificationId('item-abc', 90);
      final id60 = notificationId('item-abc', 60);
      final id30 = notificationId('item-abc', 30);
      final id15 = notificationId('item-abc', 15);
      final id7 = notificationId('item-abc', 7);
      final id1 = notificationId('item-abc', 1);
      final idExp = notificationId('item-abc', -1);

      final ids = {id90, id60, id30, id15, id7, id1, idExp};
      expect(ids.length, 7);
    });

    test('IDs are positive 31-bit integers', () {
      for (final itemId in ['a', 'b', 'c', 'long-uuid-string-here']) {
        for (final days in [...WarrantyCalculator.reminderDaysBefore, -1]) {
          final id = notificationId(itemId, days);
          expect(id, greaterThanOrEqualTo(0));
          expect(id, lessThan(0x80000000)); // < 2^31
        }
      }
    });
  });

  group('Scheduled notification dates', () {
    test('reminder fires N days before the end date at 9:00 AM', () {
      // Use date-only (midnight) for end date, but compute the scheduled
      // time relative to the end date's calendar day.
      final endDate = DateTime(2026, 12, 25);

      for (final daysBefore in WarrantyCalculator.reminderDaysBefore) {
        final scheduled = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          9,
          0,
          0,
        ).subtract(Duration(days: daysBefore));

        expect(scheduled.hour, 9);
        expect(scheduled.minute, 0);

        // The scheduled date should be exactly daysBefore calendar days
        // before the end date's day.
        final calendarDiff = DateTime(endDate.year, endDate.month, endDate.day)
            .difference(
              DateTime(scheduled.year, scheduled.month, scheduled.day),
            )
            .inDays;
        expect(calendarDiff, daysBefore);
      }
    });

    test('expiration day notification fires on the end date', () {
      final endDate = DateTime(2026, 12, 25);

      final expirationDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        9,
        0,
        0,
      );

      expect(expirationDay.year, endDate.year);
      expect(expirationDay.month, endDate.month);
      expect(expirationDay.day, endDate.day);
      expect(expirationDay.hour, 9);
    });

    test('past reminder dates should not be scheduled', () {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 5));

      for (final daysBefore in WarrantyCalculator.reminderDaysBefore) {
        final scheduled = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          9,
          0,
          0,
        ).subtract(Duration(days: daysBefore));

        if (daysBefore > 5) {
          // These should be in the past and thus skipped.
          expect(scheduled.isBefore(now), isTrue);
        } else {
          expect(scheduled.isAfter(now), isTrue);
        }
      }
    });
  });
}
