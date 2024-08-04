import 'package:floor/floor.dart';

@entity
class Airplane {
  @primaryKey
  final int id;
  final String name;
  final int passengers;
  final double speed;
  final double distance;

  Airplane({
    required this.id,
    required this.name,
    required this.passengers,
    required this.speed,
    required this.distance,
  });
}
