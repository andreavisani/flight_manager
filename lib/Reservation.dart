import 'package:floor/floor.dart';

@entity
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int customerId;
  final int flightId;
  final String reservationDate;
  final String reservationName;

  // constructor
  Reservation({
    this.id,
    required this.customerId,
    required this.flightId,
    required this.reservationDate,
    required this.reservationName,
  });

  // create new reservation object
  Reservation setId(int id) {
    return Reservation(
      id: id,
      customerId: customerId,
      flightId: flightId,
      reservationDate: reservationDate,
      reservationName: reservationName,
    );
  }
}
