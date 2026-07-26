import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/warranty_item.dart';
import '../../domain/entities/service_record.dart';
import '../../domain/entities/product_document.dart';
import '../../domain/repositories/warranty_repository.dart';

/// Service for backing up and restoring warranty data to/from JSON.
///
/// The backup includes:
/// - Product (warranty item) data
/// - Service history
/// - Document metadata (file paths, labels, descriptions)
/// - Warranty dates, categories, notes, extended warranty fields
///
/// Schema versioning is included so future schema changes can be handled
/// with migration logic.
class BackupService {
  BackupService(this._repository);
  final WarrantyRepository _repository;

  /// Exports all data to a JSON string and writes it to a file in the
  /// app's documents directory. Returns the path of the saved file.
  Future<String> exportBackup() async {
    final items = await _repository.getAllItems();

    final backup = BackupData(
      schemaVersion: AppConstants.backupSchemaVersion,
      app: AppConstants.backupAppName,
      exportedAt: DateTime.now().toIso8601String(),
      items: items.map(_itemToJson).toList(),
    );

    final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'warranty_backup_$timestamp.json';
    final filePath = p.join(appDir.path, 'backups', fileName);

    final backupDir = Directory(p.dirname(filePath));
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }

    await File(filePath).writeAsString(jsonStr);
    return filePath;
  }

  /// Imports warranty data from a JSON string. Validates the schema
  /// and restores all items, service records, and documents.
  ///
  /// Returns the number of items imported.
  Future<int> importBackup(String jsonStr) async {
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Backup root is not a JSON object.');
      }
      json = decoded;
    } catch (e) {
      throw FormatException('Invalid JSON file: $e');
    }

    // Validate schema.
    if (!json.containsKey('schemaVersion')) {
      throw const FormatException('Missing required field: schemaVersion');
    }
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int || schemaVersion < 1) {
      throw FormatException('Invalid schemaVersion: $schemaVersion');
    }
    if (schemaVersion > AppConstants.backupSchemaVersion) {
      throw FormatException(
        'Backup schema version $schemaVersion is newer than supported '
        'version ${AppConstants.backupSchemaVersion}.',
      );
    }

    final jsonItems = json['items'];
    if (jsonItems is! List) {
      throw const FormatException('Missing or invalid "items" field.');
    }

    // Migration hook: future schema changes can be handled here.
    final migratedItems = _migrateItems(schemaVersion, jsonItems);

    // Parse ALL entries BEFORE touching the store. If any entry is malformed
    // we surface the error and the user keeps their existing data intact.
    final parsed = <WarrantyItem>[];
    for (var i = 0; i < migratedItems.length; i++) {
      final entry = migratedItems[i];
      if (entry is! Map<String, dynamic>) {
        throw FormatException(
          'Invalid item at index $i: expected a JSON object, got '
          '${entry.runtimeType}.',
        );
      }
      try {
        parsed.add(itemFromJson(entry));
      } on FormatException {
        rethrow;
      } catch (e) {
        throw FormatException('Invalid item at index $i: $e');
      }
    }

    // Only now is it safe to wipe the store and restore.
    await _repository.clearAll();

    int count = 0;
    for (final item in parsed) {
      // Save the warranty item.
      await _repository.saveItem(item);

      // Save service records.
      for (final record in item.serviceRecords) {
        await _repository.saveServiceRecord(record);
      }

      // Save documents.
      for (final doc in item.documents) {
        await _repository.saveDocument(doc);
      }
      count++;
    }

    return count;
  }

  // Package-private entry point used both by [importBackup] and by tests.
  // Exposed via a leading underscore-free alias so tests can reuse it.
  WarrantyItem itemFromJson(Map<String, dynamic> json) => _itemFromJson(json);

  // ── Serialization ────────────────────────────────────────────────

  Map<String, dynamic> _itemToJson(WarrantyItem item) {
    return {
      'id': item.id,
      'productName': item.productName,
      'brandCategory': item.brandCategory,
      'purchaseDate': item.purchaseDate.toIso8601String(),
      'warrantyDurationInMonths': item.warrantyDurationInMonths,
      'endDate': item.endDate.toIso8601String(),
      'receiptImagePath': item.receiptImagePath,
      'productImagePath': item.productImagePath,
      'notes': item.notes,
      'extendedWarrantyMonths': item.extendedWarrantyMonths,
      'extendedWarrantyEndDate': item.extendedWarrantyEndDate
          ?.toIso8601String(),
      'serviceRecords': item.serviceRecords.map(_recordToJson).toList(),
      'documents': item.documents.map(_docToJson).toList(),
    };
  }

  Map<String, dynamic> _recordToJson(ServiceRecord record) {
    return {
      'id': record.id,
      'warrantyItemId': record.warrantyItemId,
      'serviceDate': record.serviceDate.toIso8601String(),
      'serviceCenter': record.serviceCenter,
      'description': record.description,
      'cost': record.cost,
      'trackingNumber': record.trackingNumber,
      'notes': record.notes,
    };
  }

  Map<String, dynamic> _docToJson(ProductDocument doc) {
    return {
      'id': doc.id,
      'warrantyItemId': doc.warrantyItemId,
      'filePath': doc.filePath,
      'label': doc.label,
      'description': doc.description,
    };
  }

  // ── Deserialization ───────────────────────────────────────────────

  WarrantyItem _itemFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('Missing or invalid "id" field.');
    }
    final productName = json['productName'];
    if (productName is! String) {
      throw const FormatException('Missing or invalid "productName" field.');
    }
    final brandCategory = json['brandCategory'];
    if (brandCategory is! String) {
      throw const FormatException('Missing or invalid "brandCategory" field.');
    }
    final purchaseRaw = json['purchaseDate'];
    if (purchaseRaw is! String) {
      throw const FormatException('Missing or invalid "purchaseDate" field.');
    }
    final endRaw = json['endDate'];
    if (endRaw is! String) {
      throw const FormatException('Missing or invalid "endDate" field.');
    }
    final duration = json['warrantyDurationInMonths'];
    if (duration is! num) {
      throw const FormatException(
        'Missing or invalid "warrantyDurationInMonths" field.',
      );
    }

    final serviceRecordsJson = json['serviceRecords'] as List? ?? [];
    final documentsJson = json['documents'] as List? ?? [];

    final serviceRecords = serviceRecordsJson
        .map((r) => _recordFromJson(r as Map<String, dynamic>))
        .toList();
    final documents = documentsJson
        .map((d) => _docFromJson(d as Map<String, dynamic>))
        .toList();

    return WarrantyItem(
      id: id,
      productName: productName,
      brandCategory: brandCategory,
      purchaseDate: DateTime.parse(purchaseRaw),
      warrantyDurationInMonths: duration.toInt(),
      endDate: DateTime.parse(endRaw),
      receiptImagePath: json['receiptImagePath'] as String?,
      productImagePath: json['productImagePath'] as String?,
      notes: json['notes'] as String? ?? '',
      extendedWarrantyMonths:
          (json['extendedWarrantyMonths'] as num?)?.toInt(),
      extendedWarrantyEndDate: json['extendedWarrantyEndDate'] != null
          ? DateTime.parse(json['extendedWarrantyEndDate'] as String)
          : null,
      serviceRecords: serviceRecords,
      documents: documents,
    );
  }

  ServiceRecord _recordFromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      id: json['id'] as String,
      warrantyItemId: json['warrantyItemId'] as String,
      serviceDate: DateTime.parse(json['serviceDate'] as String),
      serviceCenter: json['serviceCenter'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num?)?.toDouble(),
      trackingNumber: json['trackingNumber'] as String?,
      notes: json['notes'] as String? ?? '',
    );
  }

  ProductDocument _docFromJson(Map<String, dynamic> json) {
    return ProductDocument(
      id: json['id'] as String,
      warrantyItemId: json['warrantyItemId'] as String,
      filePath: json['filePath'] as String,
      label: json['label'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  // ── Migration ─────────────────────────────────────────────────────

  /// Handles migration of item JSON from an older schema version.
  /// Currently a no-op since we're on version 1, but the hook is here
  /// for future schema changes.
  List<dynamic> _migrateItems(int fromVersion, List<dynamic> items) {
    // No migrations needed yet for version 1.
    if (fromVersion == 1) return items;
    return items;
  }
}

/// Top-level backup container.
class BackupData {
  final int schemaVersion;
  final String app;
  final String exportedAt;
  final List<Map<String, dynamic>> items;

  BackupData({
    required this.schemaVersion,
    required this.app,
    required this.exportedAt,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'app': app,
      'exportedAt': exportedAt,
      'items': items,
    };
  }
}
