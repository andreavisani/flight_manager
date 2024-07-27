import 'package:flutter/cupertino.dart';

import 'Flight.dart';
import 'package:floor/floor.dart';

@dao
abstract class FlightDAO{

  @insert
  Future<void> insertFlight(Flight flight);

  @delete
  Future<int> deleteFlight(Flight flight);

  @Query('SELECT * FROM Flight') // ToDoItem is the entity objejct
  Future<List<Flight>> selectEverything(); // returns an arrayList of ToDoItems

  @update
  Future<void> updateFlight(Flight flight);

}