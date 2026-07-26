import 'package:hive_ce/hive_ce.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product_document.dart';

part 'product_document_hive_model.g.dart';

/// Hive-persisted representation of a [ProductDocument].
///
/// Keyed by document ID in a dedicated Hive box, filtered by
/// [warrantyItemId] when queried.
@HiveType(typeId: 2)
class ProductDocumentHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String warrantyItemId;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final String label;

  @HiveField(4)
  final String description;

  ProductDocumentHiveModel({
    required this.id,
    required this.warrantyItemId,
    required this.filePath,
    required this.label,
    this.description = '',
  });

  /// Converts the stored Hive model into the pure domain entity.
  ProductDocument toEntity() {
    return ProductDocument(
      id: id,
      warrantyItemId: warrantyItemId,
      filePath: filePath,
      label: label,
      description: description,
    );
  }

  /// Creates a Hive model from a domain entity.
  factory ProductDocumentHiveModel.fromEntity(ProductDocument entity) {
    return ProductDocumentHiveModel(
      id: entity.id,
      warrantyItemId: entity.warrantyItemId,
      filePath: entity.filePath,
      label: entity.label,
      description: entity.description,
    );
  }

  /// Creates a new model with a generated UUID.
  factory ProductDocumentHiveModel.create({
    required String warrantyItemId,
    required String filePath,
    required String label,
    String description = '',
  }) {
    return ProductDocumentHiveModel(
      id: const Uuid().v4(),
      warrantyItemId: warrantyItemId,
      filePath: filePath,
      label: label,
      description: description,
    );
  }
}
