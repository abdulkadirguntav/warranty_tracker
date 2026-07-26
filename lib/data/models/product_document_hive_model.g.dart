// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_document_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductDocumentHiveModelAdapter
    extends TypeAdapter<ProductDocumentHiveModel> {
  @override
  final typeId = 2;

  @override
  ProductDocumentHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductDocumentHiveModel(
      id: fields[0] as String,
      warrantyItemId: fields[1] as String,
      filePath: fields[2] as String,
      label: fields[3] as String,
      description: fields[4] == null ? '' : fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductDocumentHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.warrantyItemId)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDocumentHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
