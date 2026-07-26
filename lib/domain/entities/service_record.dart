/// Core domain entity representing a service / repair record for a
/// warranty item.
///
/// This is a plain Dart class with no external dependencies, keeping the
/// domain layer framework-agnostic (clean architecture).
class ServiceRecord {
  final String id;
  final String warrantyItemId;

  /// When the repair / service was performed.
  final DateTime serviceDate;

  /// Name of the service center or repair shop.
  final String serviceCenter;

  /// Description of what was done.
  final String description;

  /// Cost of the repair (nullable — some services are free under warranty).
  final double? cost;

  /// Courier or service tracking number (optional).
  final String? trackingNumber;

  /// Additional free-text notes (optional).
  final String notes;

  ServiceRecord({
    required this.id,
    required this.warrantyItemId,
    required this.serviceDate,
    required this.serviceCenter,
    required this.description,
    this.cost,
    this.trackingNumber,
    required this.notes,
  });

  ServiceRecord copyWith({
    String? id,
    String? warrantyItemId,
    DateTime? serviceDate,
    String? serviceCenter,
    String? description,
    double? cost,
    String? trackingNumber,
    String? notes,
    bool clearCost = false,
    bool clearTrackingNumber = false,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      warrantyItemId: warrantyItemId ?? this.warrantyItemId,
      serviceDate: serviceDate ?? this.serviceDate,
      serviceCenter: serviceCenter ?? this.serviceCenter,
      description: description ?? this.description,
      cost: clearCost ? null : (cost ?? this.cost),
      trackingNumber: clearTrackingNumber
          ? null
          : (trackingNumber ?? this.trackingNumber),
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'ServiceRecord(id: $id, warrantyItemId: $warrantyItemId, '
        'serviceDate: $serviceDate, serviceCenter: $serviceCenter, '
        'cost: $cost)';
  }
}
