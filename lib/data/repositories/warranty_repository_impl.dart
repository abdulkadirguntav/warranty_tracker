import '../../domain/entities/warranty_item.dart';
import '../../domain/entities/service_record.dart';
import '../../domain/entities/product_document.dart';
import '../../domain/repositories/warranty_repository.dart';
import '../datasources/warranty_local_data_source.dart';
import '../models/warranty_item_hive_model.dart';
import '../models/service_record_hive_model.dart';
import '../models/product_document_hive_model.dart';

/// Concrete [WarrantyRepository] backed by the local Hive data source.
///
/// Responsibilities:
/// * Map between domain entities and Hive models.
/// * Enforce the sorting rule: nearest effective expiration first.
/// * Load related service records and documents for each item.
/// * Cascade deletes (item -> its service records and documents).
class WarrantyRepositoryImpl implements WarrantyRepository {
  final WarrantyLocalDataSource _dataSource;

  WarrantyRepositoryImpl(this._dataSource);

  @override
  Future<List<WarrantyItem>> getAllItems() async {
    final models = _dataSource.getAllItems();
    final entities = <WarrantyItem>[];
    for (final m in models) {
      final entity = m.toEntity();
      final item = entity.copyWith(
        serviceRecords: _getServiceRecordsForSync(entity.id),
        documents: _getDocumentsForSync(entity.id),
      );
      entities.add(item);
    }
    _sortByEffectiveExpiration(entities);
    return entities;
  }

  @override
  Future<WarrantyItem?> getItem(String id) async {
    final model = _dataSource.getItemById(id);
    if (model == null) return null;
    final entity = model.toEntity();
    return entity.copyWith(
      serviceRecords: _getServiceRecordsForSync(id),
      documents: _getDocumentsForSync(id),
    );
  }

  @override
  Future<void> saveItem(WarrantyItem item) async {
    final model = WarrantyItemHiveModel(
      id: item.id,
      productName: item.productName,
      brandCategory: item.brandCategory,
      purchaseDate: item.purchaseDate,
      warrantyDurationInMonths: item.warrantyDurationInMonths,
      endDate: item.endDate,
      receiptImagePath: item.receiptImagePath,
      productImagePath: item.productImagePath,
      notes: item.notes,
      extendedWarrantyMonths: item.extendedWarrantyMonths,
      extendedWarrantyEndDate: item.extendedWarrantyEndDate,
    );
    await _dataSource.putItem(model);
  }

  @override
  Future<void> deleteItem(String id) async {
    // Cascade delete: remove all service records and documents for this item.
    final records = _dataSource.getServiceRecordsFor(id);
    for (final r in records) {
      await _dataSource.deleteServiceRecord(r.id);
    }
    final docs = _dataSource.getDocumentsFor(id);
    for (final d in docs) {
      await _dataSource.deleteDocument(d.id);
    }
    await _dataSource.deleteItem(id);
  }

  @override
  Future<int> itemCount() async => _dataSource.itemCount();

  // ── Service records ──────────────────────────────────────────────
  @override
  Future<List<ServiceRecord>> getServiceRecords(String warrantyItemId) async {
    return _getServiceRecordsForSync(warrantyItemId);
  }

  List<ServiceRecord> _getServiceRecordsForSync(String warrantyItemId) {
    final models = _dataSource.getServiceRecordsFor(warrantyItemId);
    final records = models.map((m) => m.toEntity()).toList();
    records.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    return records;
  }

  @override
  Future<void> saveServiceRecord(ServiceRecord record) async {
    final model = ServiceRecordHiveModel.fromEntity(record);
    await _dataSource.putServiceRecord(model);
  }

  @override
  Future<void> deleteServiceRecord(String id) async {
    await _dataSource.deleteServiceRecord(id);
  }

  // ── Product documents ────────────────────────────────────────────
  @override
  Future<List<ProductDocument>> getDocuments(String warrantyItemId) async {
    return _getDocumentsForSync(warrantyItemId);
  }

  List<ProductDocument> _getDocumentsForSync(String warrantyItemId) {
    final models = _dataSource.getDocumentsFor(warrantyItemId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveDocument(ProductDocument document) async {
    final model = ProductDocumentHiveModel.fromEntity(document);
    await _dataSource.putDocument(model);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _dataSource.deleteDocument(id);
  }

  // ── Clear all ────────────────────────────────────────────────────
  @override
  Future<void> clearAll() async {
    await _dataSource.clearAllData();
  }

  /// Sorts items so the closest *effective* expiration is first.
  /// Expired items are kept on top (nearest expiration), then
  /// expiring-soon, then active. Ties broken by product name.
  void _sortByEffectiveExpiration(List<WarrantyItem> items) {
    items.sort((a, b) {
      final aEnd = a.effectiveEndDate;
      final bEnd = b.effectiveEndDate;
      if (aEnd != bEnd) {
        return aEnd.compareTo(bEnd);
      }
      return a.productName.compareTo(b.productName);
    });
  }
}
