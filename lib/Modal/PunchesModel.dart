import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'PunchesModel.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class PunchesModel extends HiveObject {
  @HiveField(1)
  String time;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  String address;

  PunchesModel({
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory PunchesModel.fromJson(Map<String, dynamic> json) =>
      _$PunchesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PunchesModelToJson(this);
}
