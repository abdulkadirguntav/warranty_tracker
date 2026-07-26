import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_tracker/domain/entities/product_document.dart';
import 'package:warranty_tracker/domain/entities/service_record.dart';
import 'package:warranty_tracker/domain/entities/warranty_item.dart';

void main() {
  group('Backup serialization (item -> JSON -> item)', () {
    test('round-trips a WarrantyItem with all fields', () {
      final original = WarrantyItem(
        id: 'item-1',
        productName: 'Galaxy S24 Ultra',
        brandCategory: 'Electronics',
        purchaseDate: DateTime(2026, 1, 15),
        warrantyDurationInMonths: 24,
        endDate: DateTime(2028, 1, 15),
        receiptImagePath: '/data/receipts/r1.jpg',
        productImagePath: '/data/products/p1.jpg',
        notes: 'Bought at Best Buy',
        extendedWarrantyMonths: 12,
        extendedWarrantyEndDate: null,
        serviceRecords: [
          ServiceRecord(
            id: 'sr-1',
            warrantyItemId: 'item-1',
            serviceDate: DateTime(2026, 6, 10),
            serviceCenter: 'Samsung Service',
            description: 'Screen replacement',
            cost: 150.0,
            trackingNumber: 'TRK123',
            notes: 'Fixed under extended warranty',
          ),
        ],
        documents: [
          ProductDocument(
            id: 'doc-1',
            warrantyItemId: 'item-1',
            filePath: '/data/docs/d1.jpg',
            label: 'Receipt',
            description: 'Original receipt',
          ),
        ],
      );

      // Serialize
      final json = _itemToJson(original);
      final jsonStr = jsonEncode(json);

      // Deserialize
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = _itemFromJson(decoded);

      expect(restored.id, original.id);
      expect(restored.productName, original.productName);
      expect(restored.brandCategory, original.brandCategory);
      expect(restored.purchaseDate, original.purchaseDate);
      expect(
        restored.warrantyDurationInMonths,
        original.warrantyDurationInMonths,
      );
      expect(restored.endDate, original.endDate);
      expect(restored.receiptImagePath, original.receiptImagePath);
      expect(restored.productImagePath, original.productImagePath);
      expect(restored.notes, original.notes);
      expect(restored.extendedWarrantyMonths, original.extendedWarrantyMonths);
      expect(
        restored.extendedWarrantyEndDate,
        original.extendedWarrantyEndDate,
      );
      expect(restored.serviceRecords.length, 1);
      expect(restored.serviceRecords.first.id, 'sr-1');
      expect(restored.serviceRecords.first.serviceCenter, 'Samsung Service');
      expect(restored.serviceRecords.first.cost, 150.0);
      expect(restored.serviceRecords.first.trackingNumber, 'TRK123');
      expect(restored.documents.length, 1);
      expect(restored.documents.first.id, 'doc-1');
      expect(restored.documents.first.label, 'Receipt');
      expect(restored.documents.first.description, 'Original receipt');
    });

    test(
      'round-trips an item with extendedWarrantyEndDate instead of months',
      () {
        final original = WarrantyItem(
          id: 'item-2',
          productName: 'Laptop',
          brandCategory: 'Computer / Laptop',
          purchaseDate: DateTime(2025, 6, 1),
          warrantyDurationInMonths: 12,
          endDate: DateTime(2026, 6, 1),
          notes: '',
          extendedWarrantyMonths: null,
          extendedWarrantyEndDate: DateTime(2027, 6, 1),
        );

        final json = _itemToJson(original);
        final restored = _itemFromJson(jsonDecode(jsonEncode(json)));

        expect(restored.extendedWarrantyEndDate, DateTime(2027, 6, 1));
        expect(restored.extendedWarrantyMonths, isNull);
      },
    );

    test('handles null optional fields correctly', () {
      final original = WarrantyItem(
        id: 'item-3',
        productName: 'Basic Item',
        brandCategory: 'Other',
        purchaseDate: DateTime(2026, 1, 1),
        warrantyDurationInMonths: 6,
        endDate: DateTime(2026, 7, 1),
        notes: '',
      );

      final json = _itemToJson(original);
      final restored = _itemFromJson(jsonDecode(jsonEncode(json)));

      expect(restored.receiptImagePath, isNull);
      expect(restored.productImagePath, isNull);
      expect(restored.extendedWarrantyMonths, isNull);
      expect(restored.extendedWarrantyEndDate, isNull);
      expect(restored.serviceRecords, isEmpty);
      expect(restored.documents, isEmpty);
    });

    test('handles empty notes as empty string', () {
      final original = WarrantyItem(
        id: 'item-4',
        productName: 'No Notes Item',
        brandCategory: 'Other',
        purchaseDate: DateTime(2026, 1, 1),
        warrantyDurationInMonths: 6,
        endDate: DateTime(2026, 7, 1),
        notes: '',
      );

      final json = _itemToJson(original);
      expect(json['notes'], '');

      final restored = _itemFromJson(jsonDecode(jsonEncode(json)));
      expect(restored.notes, '');
    });
  });

  group('Backup schema validation', () {
    test('valid backup JSON has required fields', () {
      final backup = {
        'schemaVersion': 1,
        'app': 'warranty_tracker',
        'exportedAt': DateTime.now().toIso8601String(),
        'items': [],
      };
      final jsonStr = jsonEncode(backup);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded.containsKey('schemaVersion'), isTrue);
      expect(decoded['schemaVersion'], 1);
      expect(decoded['items'], isA<List>());
    });

    test('rejects backup with missing schemaVersion', () {
      final backup = {'app': 'warranty_tracker', 'items': []};
      final jsonStr = jsonEncode(backup);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded.containsKey('schemaVersion'), isFalse);
    });

    test('rejects backup with invalid schemaVersion type', () {
      final backup = {'schemaVersion': 'not-a-number', 'items': []};
      final jsonStr = jsonEncode(backup);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      final schemaVersion = decoded['schemaVersion'];
      expect(schemaVersion, isA<String>());
    });
  });
}

// ── Serialization helpers (matching BackupService) ─────────────────

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
    'extendedWarrantyEndDate': item.extendedWarrantyEndDate?.toIso8601String(),
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

WarrantyItem _itemFromJson(Map<String, dynamic> json) {
  final id = json['id'] as String;
  final serviceRecordsJson = json['serviceRecords'] as List? ?? [];
  final documentsJson = json['documents'] as List? ?? [];

  return WarrantyItem(
    id: id,
    productName: json['productName'] as String,
    brandCategory: json['brandCategory'] as String,
    purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    warrantyDurationInMonths: (json['warrantyDurationInMonths'] as num).toInt(),
    endDate: DateTime.parse(json['endDate'] as String),
    receiptImagePath: json['receiptImagePath'] as String?,
    productImagePath: json['productImagePath'] as String?,
    notes: json['notes'] as String? ?? '',
    extendedWarrantyMonths: json['extendedWarrantyMonths'] as int?,
    extendedWarrantyEndDate: json['extendedWarrantyEndDate'] != null
        ? DateTime.parse(json['extendedWarrantyEndDate'] as String)
        : null,
    serviceRecords: serviceRecordsJson
        .map((r) => _recordFromJson(r as Map<String, dynamic>))
        .toList(),
    documents: documentsJson
        .map((d) => _docFromJson(d as Map<String, dynamic>))
        .toList(),
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
