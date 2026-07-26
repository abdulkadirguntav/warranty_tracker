import '../../core/constants/app_constants.dart';
import '../../core/utils/warranty_calculator.dart';
import 'service_record.dart';
import 'product_document.dart';

/// Core domain entity representing a warranty-tracked product.
///
/// This is a plain Dart class with no external dependencies, keeping the
/// domain layer completely framework-agnostic (clean architecture).
class WarrantyItem {
  final String id;
  final String productName;
  final String brandCategory;
  final DateTime purchaseDate;
  final int warrantyDurationInMonths;
  final DateTime endDate;
  final String? receiptImagePath;
  final String? productImagePath;
  final String notes;

  // ── Extended warranty ──────────────────────────────────────────
  /// Optional extended warranty duration in months (beyond original warranty).
  final int? extendedWarrantyMonths;

  /// Optional explicit extended warranty end date.
  /// If provided, takes precedence over [extendedWarrantyMonths].
  final DateTime? extendedWarrantyEndDate;

  // ── Related data (kept in memory, persisted in separate Hive boxes) ─
  final List<ServiceRecord> serviceRecords;
  final List<ProductDocument> documents;

  WarrantyItem({
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
    this.serviceRecords = const [],
    this.documents = const [],
  });

  /// The effective warranty end date, accounting for any extended warranty.
  ///
  /// If an explicit [extendedWarrantyEndDate] is set, it takes priority.
  /// Otherwise, the extended months are added to the original [endDate].
  /// If no extended warranty is configured, returns the original [endDate].
  DateTime get effectiveEndDate {
    if (extendedWarrantyEndDate != null) {
      return extendedWarrantyEndDate!;
    }
    if (extendedWarrantyMonths != null && extendedWarrantyMonths! > 0) {
      return WarrantyCalculator.calculateEndDateEx(
        baseDate: endDate,
        additionalMonths: extendedWarrantyMonths!,
      );
    }
    return endDate;
  }

  /// Number of days remaining until the effective warranty expires.
  ///
  /// Returns a negative number if the warranty has already expired.
  int get remainingDays => effectiveEndDate.difference(DateTime.now()).inDays;

  /// Whether the effective warranty has already expired.
  bool get isExpired => remainingDays < 0;

  /// Whether the effective warranty will expire within the given [days] window.
  ///
  /// Defaults to the app-wide threshold defined in
  /// [AppConstants.expiringSoonThresholdDays] so the value stays in sync
  /// with the calculator and the UI filter logic.
  bool isExpiringSoon({
    int days = AppConstants.expiringSoonThresholdDays,
  }) =>
      !isExpired && remainingDays <= days;

  /// Warranty status as an enum, useful for color-coding in the UI.
  ///
  /// Uses [AppConstants.expiringSoonThresholdDays] so the boundary between
  /// "active" and "expiring soon" matches the rest of the app.
  WarrantyStatus get status {
    if (isExpired) return WarrantyStatus.expired;
    if (remainingDays <= AppConstants.expiringSoonThresholdDays) {
      return WarrantyStatus.expiringSoon;
    }
    return WarrantyStatus.active;
  }

  /// Progress of the warranty period, from 0.0 (just purchased) to 1.0
  /// (fully expired). Uses the [effectiveEndDate]. Clamped to [0.0, 1.0].
  double get progress {
    final totalDuration = effectiveEndDate.difference(purchaseDate).inDays;
    if (totalDuration <= 0) return 1.0;
    final elapsed = DateTime.now().difference(purchaseDate).inDays;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  /// Whether this item has any extended warranty configured.
  bool get hasExtendedWarranty =>
      (extendedWarrantyMonths != null && extendedWarrantyMonths! > 0) ||
      extendedWarrantyEndDate != null;

  /// Creates a copy of this item with the given fields replaced.
  WarrantyItem copyWith({
    String? id,
    String? productName,
    String? brandCategory,
    DateTime? purchaseDate,
    int? warrantyDurationInMonths,
    DateTime? endDate,
    String? receiptImagePath,
    String? productImagePath,
    String? notes,
    int? extendedWarrantyMonths,
    DateTime? extendedWarrantyEndDate,
    bool clearExtendedWarrantyMonths = false,
    bool clearExtendedWarrantyEndDate = false,
    List<ServiceRecord>? serviceRecords,
    List<ProductDocument>? documents,
  }) {
    return WarrantyItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brandCategory: brandCategory ?? this.brandCategory,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyDurationInMonths:
          warrantyDurationInMonths ?? this.warrantyDurationInMonths,
      endDate: endDate ?? this.endDate,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      productImagePath: productImagePath ?? this.productImagePath,
      notes: notes ?? this.notes,
      extendedWarrantyMonths: clearExtendedWarrantyMonths
          ? null
          : (extendedWarrantyMonths ?? this.extendedWarrantyMonths),
      extendedWarrantyEndDate: clearExtendedWarrantyEndDate
          ? null
          : (extendedWarrantyEndDate ?? this.extendedWarrantyEndDate),
      serviceRecords: serviceRecords ?? this.serviceRecords,
      documents: documents ?? this.documents,
    );
  }

  @override
  String toString() {
    return 'WarrantyItem(id: $id, productName: $productName, '
        'brandCategory: $brandCategory, endDate: $endDate, '
        'effectiveEndDate: $effectiveEndDate, '
        'remainingDays: $remainingDays, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WarrantyItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Qualitative status of a warranty, used for color-coded UI indicators.
enum WarrantyStatus {
  /// Warranty is still valid with more than 3 months remaining.
  active,

  /// Warranty is still valid but will expire within 3 months.
  expiringSoon,

  /// Warranty has expired.
  expired,
}
