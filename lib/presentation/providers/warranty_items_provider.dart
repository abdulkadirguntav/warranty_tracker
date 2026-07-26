import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/warranty_item.dart';
import '../../domain/entities/service_record.dart';
import '../../domain/entities/product_document.dart';
import '../../domain/repositories/warranty_repository.dart';
import 'repository_providers.dart';

/// Notifier that holds the in-memory list of warranty items and exposes
/// CRUD actions to the UI.
///
/// End-of-day refresh: [refresh] is called on creation (via [build]) and
/// can be called again every time the app resumes — the remaining-days
/// getters in [WarrantyItem] recompute against `DateTime.now()` on each
/// read, keeping the UI accurate with no background work.
class WarrantyItemsNotifier extends Notifier<List<WarrantyItem>> {
  late WarrantyRepository _repository;

  @override
  List<WarrantyItem> build() {
    final repoAsync = ref.watch(warrantyRepositoryProvider);
    _repository = repoAsync.maybeWhen(
      data: (repo) => repo,
      orElse: () => _NullRepository(),
    );
    refresh();
    return const [];
  }

  /// Reloads all items from the repository (sorted by nearest expiration).
  Future<void> refresh() async {
    state = await _repository.getAllItems();
  }

  /// Inserts or updates [item] and refreshes the in-memory list.
  /// Also schedules/reschedules warranty expiration notifications.
  Future<void> saveItem(WarrantyItem item) async {
    await _repository.saveItem(item);
    await refresh();

    // Schedule notifications for this item.
    ref.read(notificationServiceProvider.future).then((service) {
      service.scheduleItemNotifications(item);
    });
  }

  /// Deletes the item identified by [id] and refreshes the list.
  /// Also cancels any scheduled notifications for this item.
  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    await refresh();

    // Cancel notifications for this item.
    ref.read(notificationServiceProvider.future).then((service) {
      service.cancelItemNotifications(id);
    });
  }

  /// Returns a single item by id from the repository.
  Future<WarrantyItem?> getItem(String id) => _repository.getItem(id);

  // ── Service records ──────────────────────────────────────────────
  Future<List<ServiceRecord>> getServiceRecords(String itemId) =>
      _repository.getServiceRecords(itemId);

  Future<void> saveServiceRecord(ServiceRecord record) async {
    await _repository.saveServiceRecord(record);
    await refresh();
  }

  Future<void> deleteServiceRecord(String id) async {
    await _repository.deleteServiceRecord(id);
    await refresh();
  }

  // ── Product documents ────────────────────────────────────────────
  Future<List<ProductDocument>> getDocuments(String itemId) =>
      _repository.getDocuments(itemId);

  Future<void> saveDocument(ProductDocument document) async {
    await _repository.saveDocument(document);
    await refresh();
  }

  Future<void> deleteDocument(String id) async {
    await _repository.deleteDocument(id);
    await refresh();
  }
}

/// Synchronous provider exposing the [WarrantyItemsNotifier].
final warrantyItemsProvider =
    NotifierProvider<WarrantyItemsNotifier, List<WarrantyItem>>(
      WarrantyItemsNotifier.new,
    );

/// A no-op repository used while the Hive box is still opening.
/// It is replaced automatically when [warrantyRepositoryProvider] resolves.
class _NullRepository implements WarrantyRepository {
  @override
  Future<List<WarrantyItem>> getAllItems() async => const [];
  @override
  Future<WarrantyItem?> getItem(String id) async => null;
  @override
  Future<void> saveItem(WarrantyItem item) async {}
  @override
  Future<void> deleteItem(String id) async {}
  @override
  Future<int> itemCount() async => 0;
  @override
  Future<List<ServiceRecord>> getServiceRecords(String warrantyItemId) async =>
      const [];
  @override
  Future<void> saveServiceRecord(ServiceRecord record) async {}
  @override
  Future<void> deleteServiceRecord(String id) async {}
  @override
  Future<List<ProductDocument>> getDocuments(String warrantyItemId) async =>
      const [];
  @override
  Future<void> saveDocument(ProductDocument document) async {}
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<void> clearAll() async {}
}
