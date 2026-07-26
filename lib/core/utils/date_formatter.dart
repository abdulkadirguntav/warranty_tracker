import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Reusable date formatting helpers so the presentation layer never
/// constructs formatters inline. Date formatting honors the active
/// locale through [Intl.defaultLocale], which is set by the
/// localization delegate at load time.
class DateFormatter {
  static DateFormat get _dayMonthYear =>
      DateFormat('dd MMM yyyy', Intl.getCurrentLocale());
  static DateFormat get _shortDate =>
      DateFormat('dd/MM/yyyy', Intl.getCurrentLocale());

  /// e.g. "10 Jul 2026"
  static String format(DateTime date) => _dayMonthYear.format(date);

  /// e.g. "10/07/2026"
  static String short(DateTime date) => _shortDate.format(date);

  /// Human readable "remaining" string, e.g.:
  /// "120 days left", "Expired 5 days ago", "Expires today".
  ///
  /// Uses the provided [AppLocalizations] to produce a localized phrase.
  static String remaining(DateTime endDate, AppLocalizations l) {
    final days = endDate.difference(DateTime.now()).inDays;
    if (days < 0) {
      final abs = -days;
      return abs == 1 ? l.expiredOneDayAgo : l.get('expiredDaysAgo').replaceAll('{n}', '$abs');
    }
    if (days == 0) return l.expiresToday;
    if (days == 1) return l.oneDayLeft;
    return '$days ${l.daysLeft}';
  }

  /// Returns a short "X days" string used inside the countdown ring.
  static String daysValue(int days, AppLocalizations l) {
    final value = days < 0 ? 0 : days;
    return '$value ${l.daysUnit}';
  }
}

/// Extension to translate [AppLocalizations] placeholder templates
/// against values returned from [DateFormatter].
extension LocalizedStringX on String {
  /// Replaces the `{date}` placeholder with [value].
  String withDate(String value) => replaceAll('{date}', value);

  /// Replaces the `{name}` placeholder with [value].
  String withName(String value) => replaceAll('{name}', value);

  /// Replaces the `{n}` placeholder with [value].
  String withN(int value) => replaceAll('{n}', '$value');

  /// Replaces the `{value}` placeholder with [value].
  String withValue(String value) => replaceAll('{value}', value);
}
