import 'package:flutter/cupertino.dart';

import 'Flight.dart';
import 'package:floor/floor.dart';

@dao
abstract class FlightDAO{

  @insert
  Future<void> insertFlight(Flight flight);

  @delete
  Future<int> deleteFlight(Flight flight);
}