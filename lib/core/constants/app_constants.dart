/// App-wide constants gathered in a single place for discoverability.
///
/// Keeping route paths, box names, and UI thresholds here avoids scattered
/// magic values throughout the codebase.
class AppConstants {
  AppConstants._();

  // ── Routing ──────────────────────────────────────────────────────
  static const String routeHome = '/';
  static const String routeAddEdit = '/add-edit';
  static const String routeDetails = '/details';
  static const String routeAppearance = '/appearance';

  // ── Hive ────────────────────────────────────────────────────────
  static const String warrantyBoxName = 'warranty_items';
  static const String serviceRecordBoxName = 'service_records';
  static const String productDocumentBoxName = 'product_documents';

  // ── Warranty thresholds (in days) ───────────────────────────────
  /// A warranty is "expiring soon" if fewer than this many days remain.
  static const int expiringSoonThresholdDays = 90; // ~3 months

  // ── Form defaults ───────────────────────────────────────────────
  static const int defaultWarrantyMonths = 24;
  static const List<int> commonWarrantyDurations = [
    6,
    12,
    18,
    24,
    36,
    48,
    60,
    72,
  ];
  static const List<int> commonExtendedWarrantyDurations = [
    3,
    6,
    12,
    18,
    24,
    36,
    48,
    60,
  ];

  // ── Image storage ───────────────────────────────────────────────
  static const String receiptImageFolder = 'receipts';
  static const String productImageFolder = 'products';
  static const String documentsImageFolder = 'documents';

  // ── Notification constants ─────────────────────────────────────
  /// Days before expiration to send a reminder notification.
  static const List<int> notificationReminderDays = [90, 60, 30, 15, 7, 1];

  /// Notification channel configuration for Android.
  static const String notificationChannelId = 'warranty_reminders';
  static const String notificationChannelName = 'Warranty Reminders';
  static const String notificationChannelDescription =
      'Reminders for upcoming warranty expiration dates.';

  // ── Backup schema ───────────────────────────────────────────────
  static const int backupSchemaVersion = 1;
  static const String backupAppName = 'warranty_tracker';
}
