// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_record_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceRecordHiveModelAdapter
    extends TypeAdapter<ServiceRecordHiveModel> {
  @override
  final typeId = 1;

  @override
  ServiceRecordHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceRecordHiveModel(
      id: fields[0] as String,
      warrantyItemId: fields[1] as String,
      serviceDate: fields[2] as DateTime,
      serviceCenter: fields[3] as String,
      description: fields[4] as String,
      cost: (fields[5] as num?)?.toDouble(),
      trackingNumber: fields[6] as String?,
      notes: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ServiceRecordHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.warrantyItemId)
      ..writeByte(2)
      ..write(obj.serviceDate)
      ..writeByte(3)
      ..write(obj.serviceCenter)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.cost)
      ..writeByte(6)
      ..write(obj.trackingNumber)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceRecordHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
