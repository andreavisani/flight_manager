// import 'package:flutter/cupertino.dart';
//
// import 'Reservation.dart';
// import 'package:floor/floor.dart';
//
// @dao
// abstract class ReservationDAO{
//
//   @insert
//   Future<void> insertReservation(Reservation reservation);
//
//   @Query('SELECT * FROM Reservation') // ToDoItem is the entity object
//   Future<List<Reservation>> selectEverything(); // returns an arrayList of ToDoItems
//
// }
import 'package:floor/floor.dart';
import 'Reservation.dart';

@dao
abstract class ReservationDAO {
  @insert
  Future<int> insertReservation(Reservation reservation);

  @update
  Future<void> updateReservation(Reservation reservation);

  @Query("SELECT * FROM Reservation")
  Future<List<Reservation>> selectEverything();


  @Query("SELECT * FROM Reservation WHERE id = :id")
  Future<Reservation?> getReservationById(int id);

  @delete
  Future<void> deleteReservation(Reservation reservation);
}