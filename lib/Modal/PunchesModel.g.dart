// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PunchesModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PunchesModelAdapter extends TypeAdapter<PunchesModel> {
  @override
  final int typeId = 1;

  @override
  PunchesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PunchesModel(
      time: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      address: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PunchesModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PunchesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PunchesModel _$PunchesModelFromJson(Map<String, dynamic> json) => PunchesModel(
      time: json['time'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
    );

Map<String, dynamic> _$PunchesModelToJson(PunchesModel instance) =>
    <String, dynamic>{
      'time': instance.time,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
    };
