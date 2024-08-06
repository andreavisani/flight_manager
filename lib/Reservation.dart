import 'package:floor/floor.dart';

/// Entity class representing a reservation in the database
@entity
class Reservation {
  /// Primary key for the reservation table, set to auto-generate
  @PrimaryKey(autoGenerate: true)
  final int? id;
  /// Foreign key referencing the customer who made the reservation
  final int customerId;
  /// Foreign key referencing the flight associated with the reservation
  final int flightId;
  /// Date of the reservation
  final String reservationDate;
  /// Name of the reservation
  final String reservationName;

  /// Constructor to create a Reservation object
  Reservation({
    this.id,
    required this.customerId,
    required this.flightId,
    required this.reservationDate,
    required this.reservationName,
  });

  /// Method to create a new Reservation object with a specified ID
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
