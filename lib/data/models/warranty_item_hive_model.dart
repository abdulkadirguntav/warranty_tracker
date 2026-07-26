import 'package:hive_ce/hive_ce.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/warranty_item.dart';
import '../../core/utils/warranty_calculator.dart';

part 'warranty_item_hive_model.g.dart';

/// Hive-persisted representation of a [WarrantyItem].
///
/// We keep a separate data-model class (rather than annotating the domain
/// entity directly) so the domain layer never depends on Hive. The model
/// knows how to convert to/from the pure entity.
@HiveType(typeId: 0)
class WarrantyItemHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String brandCategory;

  @HiveField(3)
  final DateTime purchaseDate;

  @HiveField(4)
  final int warrantyDurationInMonths;

  @HiveField(5)
  final DateTime endDate;

  @HiveField(6)
  final String? receiptImagePath;

  @HiveField(7)
  final String notes;

  @HiveField(8)
  final String? productImagePath;

  // ── Extended warranty (new fields, backward-compatible) ──────────
  @HiveField(9)
  final int? extendedWarrantyMonths;

  @HiveField(10)
  final DateTime? extendedWarrantyEndDate;

  WarrantyItemHiveModel({
    required this.id,
    required this.productName,
    required this.brandCategory,
    required this.purchaseDate,
    required this.warrantyDurationInMonths,
    required this.endDate,
    this.receiptImagePath,
    this.productImagePath,
    required this.notes,
    this.extendedWarrantyMonths,
    this.extendedWarrantyEndDate,
  });

  /// Converts the stored Hive model into the pure domain entity.
  WarrantyItem toEntity() {
    return WarrantyItem(
      id: id,
      productName: productName,
      brandCategory: brandCategory,
      purchaseDate: purchaseDate,
      warrantyDurationInMonths: warrantyDurationInMonths,
      endDate: endDate,
      receiptImagePath: receiptImagePath,
      productImagePath: productImagePath,
      notes: notes,
      extendedWarrantyMonths: extendedWarrantyMonths,
      extendedWarrantyEndDate: extendedWarrantyEndDate,
    );
  }

  /// Creates a brand-new Hive model from raw form inputs, generating a UUID
  /// and auto-calculating the end date from the purchase date + duration.
  factory WarrantyItemHiveModel.create({
    required String productName,
    required String brandCategory,
    required DateTime purchaseDate,
    required int warrantyDurationInMonths,
    String? receiptImagePath,
    String? productImagePath,
    required String notes,
    int? extendedWarrantyMonths,
    DateTime? extendedWarrantyEndDate,
  }) {
    final endDate = WarrantyCalculator.calculateEndDate(
      purchaseDate: purchaseDate,
      warrantyDurationInMonths: warrantyDurationInMonths,
    );
    return WarrantyItemHiveModel(
      id: const Uuid().v4(),
      productName: productName,
      brandCategory: brandCategory,
      purchaseDate: purchaseDate,
      warrantyDurationInMonths: warrantyDurationInMonths,
      endDate: endDate,
      receiptImagePath: receiptImagePath,
      productImagePath: productImagePath,
      notes: notes,
      extendedWarrantyMonths: extendedWarrantyMonths,
      extendedWarrantyEndDate: extendedWarrantyEndDate,
    );
  }
}
