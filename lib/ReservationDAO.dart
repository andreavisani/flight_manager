import 'package:floor/floor.dart';
import 'Reservation.dart';

/// Data Access Object (DAO) for the Reservation entity.
/// Provides methods to interact with the Reservation table in the database.
@dao
abstract class ReservationDAO {

  /// Inserts a new Reservation into the database.
  ///
  /// Takes a [Reservation] object as input.
  /// Returns the ID of the inserted reservation as a [Future<int>].
  @insert
  Future<int> insertReservation(Reservation reservation);

  /// Updates an existing Reservation in the database.
  ///
  /// Takes a [Reservation] object as input.
  /// The Reservation to be updated is identified by its ID.
  /// Returns a [Future<void>] indicating the operation completion.
  @update
  Future<void> updateReservation(Reservation reservation);

  /// Retrieves all reservations from the database.
  ///
  /// Returns a list of all [Reservation] objects as a [Future<List<Reservation>>].
  @Query("SELECT * FROM Reservation")
  Future<List<Reservation>> selectEverything();


  /// Retrieves a Reservation by its ID.
  ///
  /// Takes an [int] ID as input.
  /// Returns the corresponding [Reservation] object as a [Future<Reservation?>].
  /// If no reservation is found with the given ID, returns null.
  @Query("SELECT * FROM Reservation WHERE id = :id")
  Future<Reservation?> getReservationById(int id);

  /// Deletes a Reservation from the database.
  ///
  /// Takes a [Reservation] object as input.
  /// The Reservation to be deleted is identified by its ID.
  /// Returns a [Future<void>] indicating the operation completion.
  @delete
  Future<void> deleteReservation(Reservation reservation);
}