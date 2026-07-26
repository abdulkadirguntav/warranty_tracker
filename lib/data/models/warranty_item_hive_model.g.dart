// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warranty_item_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WarrantyItemHiveModelAdapter extends TypeAdapter<WarrantyItemHiveModel> {
  @override
  final typeId = 0;

  @override
  WarrantyItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WarrantyItemHiveModel(
      id: fields[0] as String,
      productName: fields[1] as String,
      brandCategory: fields[2] as String,
      purchaseDate: fields[3] as DateTime,
      warrantyDurationInMonths: (fields[4] as num).toInt(),
      endDate: fields[5] as DateTime,
      receiptImagePath: fields[6] as String?,
      productImagePath: fields[8] as String?,
      notes: fields[7] as String,
      extendedWarrantyMonths: (fields[9] as num?)?.toInt(),
      extendedWarrantyEndDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WarrantyItemHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.brandCategory)
      ..writeByte(3)
      ..write(obj.purchaseDate)
      ..writeByte(4)
      ..write(obj.warrantyDurationInMonths)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.receiptImagePath)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.productImagePath)
      ..writeByte(9)
      ..write(obj.extendedWarrantyMonths)
      ..writeByte(10)
      ..write(obj.extendedWarrantyEndDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarrantyItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
