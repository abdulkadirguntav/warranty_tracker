import 'package:hive_ce/hive_ce.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/service_record.dart';

part 'service_record_hive_model.g.dart';

/// Hive-persisted representation of a [ServiceRecord].
///
/// Keyed by record ID in a dedicated Hive box, filtered by
/// [warrantyItemId] when queried.
@HiveType(typeId: 1)
class ServiceRecordHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String warrantyItemId;

  @HiveField(2)
  final DateTime serviceDate;

  @HiveField(3)
  final String serviceCenter;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final double? cost;

  @HiveField(6)
  final String? trackingNumber;

  @HiveField(7)
  final String notes;

  ServiceRecordHiveModel({
    required this.id,
    required this.warrantyItemId,
    required this.serviceDate,
    required this.serviceCenter,
    required this.description,
    this.cost,
    this.trackingNumber,
    required this.notes,
  });

  /// Converts the stored Hive model into the pure domain entity.
  ServiceRecord toEntity() {
    return ServiceRecord(
      id: id,
      warrantyItemId: warrantyItemId,
      serviceDate: serviceDate,
      serviceCenter: serviceCenter,
      description: description,
      cost: cost,
      trackingNumber: trackingNumber,
      notes: notes,
    );
  }

  /// Creates a brand-new Hive model from a domain entity.
  factory ServiceRecordHiveModel.fromEntity(ServiceRecord entity) {
    return ServiceRecordHiveModel(
      id: entity.id,
      warrantyItemId: entity.warrantyItemId,
      serviceDate: entity.serviceDate,
      serviceCenter: entity.serviceCenter,
      description: entity.description,
      cost: entity.cost,
      trackingNumber: entity.trackingNumber,
      notes: entity.notes,
    );
  }

  /// Creates a new model with a generated UUID for a new record.
  factory ServiceRecordHiveModel.create({
    required String warrantyItemId,
    required DateTime serviceDate,
    required String serviceCenter,
    required String description,
    double? cost,
    String? trackingNumber,
    required String notes,
  }) {
    return ServiceRecordHiveModel(
      id: const Uuid().v4(),
      warrantyItemId: warrantyItemId,
      serviceDate: serviceDate,
      serviceCenter: serviceCenter,
      description: description,
      cost: cost,
      trackingNumber: trackingNumber,
      notes: notes,
    );
  }
}
