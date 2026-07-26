import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/notification_service.dart';

/// Provider that initializes the notification service and requests
/// permissions on app startup.
final notificationInitProvider = FutureProvider<void>((ref) async {
  final service = NotificationService.instance;
  await service.init();
  await service.requestPermissions();
});
