import '../entities/warranty_item.dart';
import '../entities/service_record.dart';
import '../entities/product_document.dart';

/// Abstract contract for warranty item persistence.
///
/// The domain layer defines *what* operations are available without caring
/// *how* they are implemented. The data layer provides the concrete
/// implementation (backed by Hive CE).
abstract class WarrantyRepository {
  /// Returns all warranty items, sorted by nearest expiration first
  /// (using the *effective* end date, accounting for extended warranty).
  Future<List<WarrantyItem>> getAllItems();

  /// Returns a single item by its [id], or `null` if not found.
  /// The returned item includes its service records and documents.
  Future<WarrantyItem?> getItem(String id);

  /// Inserts or updates the given [item].
  ///
  /// If an item with the same [id] already exists it is replaced,
  /// otherwise a new record is created.
  Future<void> saveItem(WarrantyItem item);

  /// Deletes the item identified by [id], along with its service
  /// records and documents.
  Future<void> deleteItem(String id);

  /// Returns the total count of stored warranty items.
  Future<int> itemCount();

  // ── Service records ──────────────────────────────────────────────
  /// Returns all service records for the given [warrantyItemId].
  Future<List<ServiceRecord>> getServiceRecords(String warrantyItemId);

  /// Saves (inserts or updates) a service record.
  Future<void> saveServiceRecord(ServiceRecord record);

  /// Deletes a service record by [id].
  Future<void> deleteServiceRecord(String id);

  // ── Product documents ────────────────────────────────────────────
  /// Returns all documents for the given [warrantyItemId].
  Future<List<ProductDocument>> getDocuments(String warrantyItemId);

  /// Saves (inserts or updates) a product document.
  Future<void> saveDocument(ProductDocument document);

  /// Deletes a product document by [id].
  Future<void> deleteDocument(String id);

  // ── Backup / restore ─────────────────────────────────────────────
  /// Clears all stored data (items, service records, documents).
  Future<void> clearAll();
}
