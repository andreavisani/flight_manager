import 'package:floor/floor.dart';
import 'TypeConverter.dart';

@entity
@TypeConverters([DateTimeConverter])
class Flight {
  static int ID = 1;

  @primaryKey
  final int id;

  DateTime departureTime;
  DateTime arrivalTime;

  String departureCity;
  String destinationCity;

  Flight(this.id, this.departureCity, this.destinationCity, this.departureTime, this.arrivalTime) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}
