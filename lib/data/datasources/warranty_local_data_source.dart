import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../hive_registrar.g.dart';
import '../models/warranty_item_hive_model.dart';
import '../models/service_record_hive_model.dart';
import '../models/product_document_hive_model.dart';
import '../../core/constants/app_constants.dart';

/// Low-level data source that owns the Hive [Box] lifecycle for all
/// persistence boxes (warranty items, service records, product documents).
///
/// The repository layer sits above this and handles entity <-> model mapping
/// plus sorting logic, so this class only deals with raw box operations.
class WarrantyLocalDataSource {
  late Box<WarrantyItemHiveModel> _warrantyBox;
  late Box<ServiceRecordHiveModel> _serviceRecordBox;
  late Box<ProductDocumentHiveModel> _documentBox;
  bool _initialized = false;

  /// Opens all Hive boxes. Must be called once during app startup before any
  /// other method is invoked.
  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    Hive.registerAdapters();
    _warrantyBox = await Hive.openBox<WarrantyItemHiveModel>(
      AppConstants.warrantyBoxName,
    );
    _serviceRecordBox = await Hive.openBox<ServiceRecordHiveModel>(
      AppConstants.serviceRecordBoxName,
    );
    _documentBox = await Hive.openBox<ProductDocumentHiveModel>(
      AppConstants.productDocumentBoxName,
    );
    _initialized = true;
  }

  Box<WarrantyItemHiveModel> get warrantyBox {
    if (!_initialized) {
      throw StateError(
        'WarrantyLocalDataSource not initialized. Call init() first.',
      );
    }
    return _warrantyBox;
  }

  Box<ServiceRecordHiveModel> get serviceRecordBox {
    if (!_initialized) {
      throw StateError(
        'WarrantyLocalDataSource not initialized. Call init() first.',
      );
    }
    return _serviceRecordBox;
  }

  Box<ProductDocumentHiveModel> get documentBox {
    if (!_initialized) {
      throw StateError(
        'WarrantyLocalDataSource not initialized. Call init() first.',
      );
    }
    return _documentBox;
  }

  /// Clears all boxes and deletes them from disk. Intended for tests only.
  Future<void> clearAndClose() async {
    if (_initialized) {
      await _warrantyBox.clear();
      await _warrantyBox.deleteFromDisk();
      await _serviceRecordBox.clear();
      await _serviceRecordBox.deleteFromDisk();
      await _documentBox.clear();
      await _documentBox.deleteFromDisk();
      _initialized = false;
    }
  }

  // ── Warranty items ──────────────────────────────────────────────
  List<WarrantyItemHiveModel> getAllItems() {
    return _warrantyBox.values.toList();
  }

  WarrantyItemHiveModel? getItemById(String id) {
    return _warrantyBox.get(id);
  }

  Future<void> putItem(WarrantyItemHiveModel model) async {
    await _warrantyBox.put(model.id, model);
  }

  Future<void> deleteItem(String id) async {
    await _warrantyBox.delete(id);
  }

  int itemCount() => _warrantyBox.length;

  // ── Service records ─────────────────────────────────────────────
  List<ServiceRecordHiveModel> getAllServiceRecords() {
    return _serviceRecordBox.values.toList();
  }

  List<ServiceRecordHiveModel> getServiceRecordsFor(String warrantyItemId) {
    return _serviceRecordBox.values
        .where((r) => r.warrantyItemId == warrantyItemId)
        .toList();
  }

  Future<void> putServiceRecord(ServiceRecordHiveModel model) async {
    await _serviceRecordBox.put(model.id, model);
  }

  Future<void> deleteServiceRecord(String id) async {
    await _serviceRecordBox.delete(id);
  }

  // ── Product documents ───────────────────────────────────────────
  List<ProductDocumentHiveModel> getAllDocuments() {
    return _documentBox.values.toList();
  }

  List<ProductDocumentHiveModel> getDocumentsFor(String warrantyItemId) {
    return _documentBox.values
        .where((d) => d.warrantyItemId == warrantyItemId)
        .toList();
  }

  Future<void> putDocument(ProductDocumentHiveModel model) async {
    await _documentBox.put(model.id, model);
  }

  Future<void> deleteDocument(String id) async {
    await _documentBox.delete(id);
  }

  // ── Clear all ────────────────────────────────────────────────────
  Future<void> clearAllData() async {
    await _warrantyBox.clear();
    await _serviceRecordBox.clear();
    await _documentBox.clear();
  }
}
