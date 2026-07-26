/// Core domain entity representing an attached document / image for a
/// warranty item.
///
/// Supports documents of various types: receipt, warranty certificate,
/// service form, box label, or any other custom attachment.
class ProductDocument {
  final String id;
  final String warrantyItemId;

  /// File system path where the document image is stored.
  final String filePath;

  /// Human-readable label for the document (e.g. "Receipt",
  /// "Warranty Certificate", "Service Form", "Box Label", "Other").
  final String label;

  /// Optional description of the document.
  final String description;

  ProductDocument({
    required this.id,
    required this.warrantyItemId,
    required this.filePath,
    required this.label,
    this.description = '',
  });

  ProductDocument copyWith({
    String? id,
    String? warrantyItemId,
    String? filePath,
    String? label,
    String? description,
  }) {
    return ProductDocument(
      id: id ?? this.id,
      warrantyItemId: warrantyItemId ?? this.warrantyItemId,
      filePath: filePath ?? this.filePath,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }
}
