import 'package:floor/floor.dart';

@Entity(tableName: 'airplanes')
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String type;
  final int passengers;
  final double maxSpeed;
  final double range;

  Airplane({
    this.id,
    required this.type,
    required this.passengers,
    required this.maxSpeed,
    required this.range,
  });
}
