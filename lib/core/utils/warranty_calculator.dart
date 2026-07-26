import '../constants/app_constants.dart';

/// Pure functions for warranty date arithmetic.
///
/// Centralising these rules makes them trivial to unit-test and reuse
/// from both the data and presentation layers.
class WarrantyCalculator {
  WarrantyCalculator._();

  /// Calculates the warranty end date by adding a number of months to the
  /// [purchaseDate].
  ///
  /// Handles month-overflow correctly (e.g. Jan 31 + 1 month => Feb 28).
  static DateTime calculateEndDate({
    required DateTime purchaseDate,
    required int warrantyDurationInMonths,
  }) {
    return _addMonths(purchaseDate, warrantyDurationInMonths);
  }

  /// Calculates an end date by adding [additionalMonths] to [baseDate].
  ///
  /// Used for extended warranty: [baseDate] is the original warranty end
  /// date and [additionalMonths] is the extended warranty duration.
  static DateTime calculateEndDateEx({
    required DateTime baseDate,
    required int additionalMonths,
  }) {
    return _addMonths(baseDate, additionalMonths);
  }

  static DateTime _addMonths(DateTime date, int months) {
    final newMonth = (date.month + months) % 12;
    final yearsToAdd = (date.month + months) ~/ 12;
    var newYear = date.year + yearsToAdd;
    if (newMonth == 0) {
      newYear -= 1;
    }
    final month = newMonth == 0 ? 12 : newMonth;
    final day = _clampDay(date.day, month, newYear);

    return DateTime(newYear, month, day);
  }

  /// Returns the last valid day of [month]/[year], clamping [day] so it
  /// never overflows (e.g. 31 => 28/29 for February).
  static int _clampDay(int day, int month, int year) {
    const monthLengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var maxDay = monthLengths[month - 1];
    if (month == 2) {
      final isLeap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
      if (isLeap) maxDay = 29;
    }
    return day > maxDay ? maxDay : day;
  }

  /// Whole days from [now] until [endDate].
  static int remainingDays(DateTime endDate, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return endDate.difference(reference).inDays;
  }
  /// Warranty status derived from the remaining days.
  ///
  /// * [expiredThreshold] defaults to 0 (i.e. negative remaining).
  /// * [expiringSoonThreshold] defaults to [AppConstants.expiringSoonThresholdDays]
  ///   (~3 months), so the calculator stays in sync with the rest of the app.
  static WarrantyLevel level({
    required DateTime endDate,
    DateTime? now,
    int expiringSoonThreshold = AppConstants.expiringSoonThresholdDays,
  }) {
    final remaining = remainingDays(endDate, now: now);
    if (remaining < 0) return WarrantyLevel.expired;
    if (remaining <= expiringSoonThreshold) return WarrantyLevel.expiringSoon;
    return WarrantyLevel.active;
  }

  /// Remaining-warranty fraction, used by the countdown ring.
  ///
  /// Returns the **inverse** of the elapsed fraction:
  /// * `1.0` when nothing has elapsed (just purchased) → full ring.
  /// * `0.0` when the warranty has expired → empty ring.
  ///
  /// The ring therefore shrinks as time passes. Clamped to `[0.0, 1.0]`.
  static double remainingFraction({
    required DateTime purchaseDate,
    required DateTime endDate,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final total = endDate.difference(purchaseDate).inDays;
    if (total <= 0) {
      return reference.isBefore(endDate) ? 1.0 : 0.0;
    }
    final elapsed = reference.difference(purchaseDate).inDays;
    final elapsedClamped = elapsed.clamp(0, total);
    final remaining = total - elapsedClamped;
    return (remaining / total).clamp(0.0, 1.0);
  }

  /// Days before the [endDate] that a reminder should fire.
  ///
  /// Mirrors [AppConstants.notificationReminderDays] so there is a single
  /// source of truth; the cached pointer simply avoids the const-list
  /// indirection at call sites that read this value at hot paths.
  static const List<int> reminderDaysBefore =
      AppConstants.notificationReminderDays;
  static const int expirationDayId = -1;
}

/// Coarse warranty status used for color-coding list items.
enum WarrantyLevel { active, expiringSoon, expired }
