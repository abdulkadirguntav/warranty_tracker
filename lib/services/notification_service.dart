import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_constants.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../domain/entities/warranty_item.dart';

/// Service for scheduling and cancelling local warranty expiration
/// notifications using `flutter_local_notifications`.
///
/// For each warranty item, reminders fire at:
/// 90, 60, 30, 15, 7, 1 day(s) before the effective end date, and on the
/// expiration day itself ("Warranty expired").
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes the notification plugin, timezone data, and Android
  /// notification channel. Must be called once during app startup.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // Create the Android notification channel.
    const channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Requests notification permissions on iOS and Android 13+.
  /// Returns `true` if permissions are granted.
  Future<bool> requestPermissions() async {
    await init();

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    bool androidGranted = true;
    bool iosGranted = true;

    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      androidGranted = granted ?? true;
    }

    if (iosImpl != null) {
      iosGranted =
          (await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          )) ??
          true;
    }

    return androidGranted && iosGranted;
  }

  /// Schedules all reminder notifications for a [WarrantyItem].
  ///
  /// Cancels any previously-scheduled notifications for this item first
  /// (so editing an item correctly reschedules).
  Future<void> scheduleItemNotifications(WarrantyItem item) async {
    await init();
    await cancelItemNotifications(item.id);

    final effectiveEnd = item.effectiveEndDate;
    final now = tz.TZDateTime.now(tz.local);

    // Schedule reminders at 90, 60, 30, 15, 7, 1 day(s) before expiration.
    for (final daysBefore in WarrantyCalculator.reminderDaysBefore) {
      final scheduledDate = tz.TZDateTime(
        tz.local,
        effectiveEnd.year,
        effectiveEnd.month,
        effectiveEnd.day,
        9, // 9:00 AM
        0,
        0,
      ).subtract(Duration(days: daysBefore));

      if (scheduledDate.isAfter(now)) {
        await _scheduleNotification(
          id: _notificationId(item.id, daysBefore),
          title: _reminderTitle(daysBefore, item.productName),
          body: _reminderBody(daysBefore, effectiveEnd),
          scheduledDate: scheduledDate,
        );
      }
    }

    // Also schedule a notification on the expiration day itself.
    final expirationDay = tz.TZDateTime(
      tz.local,
      effectiveEnd.year,
      effectiveEnd.month,
      effectiveEnd.day,
      9,
      0,
      0,
    );

    if (expirationDay.isAfter(now)) {
      await _scheduleNotification(
        id: _notificationId(item.id, WarrantyCalculator.expirationDayId),
        // See note in [_reminderTitle] about localization of notifications.
        title: 'Warranty expired',
        body:
            'The warranty for "${item.productName}" has expired today '
            '(${effectiveEnd.day}/${effectiveEnd.month}/${effectiveEnd.year}).',
        scheduledDate: expirationDay,
      );
    }
  }

  /// Cancels all notifications for a warranty item.
  Future<void> cancelItemNotifications(String itemId) async {
    await init();

    for (final daysBefore in WarrantyCalculator.reminderDaysBefore) {
      await _plugin.cancel(_notificationId(itemId, daysBefore));
    }
    await _plugin.cancel(
      _notificationId(itemId, WarrantyCalculator.expirationDayId),
    );
  }

  /// Cancels every pending notification created by the app.
  Future<void> cancelAllNotifications() async {
    await init();
    await _plugin.cancelAll();
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Generates a stable 31-bit integer ID from the item UUID and the
  /// days-before offset. Used as the notification ID.
  int _notificationId(String itemId, int daysBefore) {
    return (itemId.hashCode ^ daysBefore.hashCode) & 0x7FFFFFFF;
  }

  String _reminderTitle(int daysBefore, String productName) {
    // NOTE: These notification strings are intentionally in English. Local
    // notifications are scheduled by the platform layer without a
    // BuildContext, so a future improvement would either (a) snapshot the
    // active locale when scheduling and store a localized payload, or
    // (b) tag the notification with a template id and resolve it in
    // [onDidReceiveNotificationResponse].
    if (daysBefore >= 90) {
      return 'Warranty reminder: $productName';
    }
    return 'Warranty expires in $daysBefore day${daysBefore == 1 ? '' : 's'}: $productName';
  }

  String _reminderBody(int daysBefore, DateTime endDate) {
    // See note in [_reminderTitle] about localization.
    return 'The warranty will expire on '
        '${endDate.day}/${endDate.month}/${endDate.year} '
        '($daysBefore day${daysBefore == 1 ? '' : 's'} remaining). '
        'Review your coverage and consider extending if needed.';
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
