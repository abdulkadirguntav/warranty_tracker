import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/warranty_local_data_source.dart';
import '../../data/repositories/warranty_repository_impl.dart';
import '../../domain/repositories/warranty_repository.dart';
import '../../services/notification_service.dart';

/// Providers wiring the data layer together.
///
/// Splitting "infrastructure" providers from feature providers keeps the
/// dependency graph easy to read and test.

/// Provides the lazily-initialized Hive data source.
///
/// Because [init] is async we expose a [FutureProvider] that the app shell
/// awaits before rendering any screen.
final dataSourceProvider = FutureProvider<WarrantyLocalDataSource>((ref) async {
  final ds = WarrantyLocalDataSource();
  await ds.init();
  ref.onDispose(() => ds.clearAndClose());
  return ds;
});

/// Provides the concrete [WarrantyRepository] implementation once the
/// data source is ready.
final warrantyRepositoryProvider = FutureProvider<WarrantyRepository>((
  ref,
) async {
  final ds = await ref.watch(dataSourceProvider.future);
  return WarrantyRepositoryImpl(ds);
});

/// Provides the [NotificationService] singleton.
final notificationServiceProvider = FutureProvider<NotificationService>((
  ref,
) async {
  final service = NotificationService.instance;
  await service.init();
  return service;
});
