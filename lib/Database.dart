import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'TypeConverter.dart';

import 'Flight.dart';
import 'FlightDAO.dart';

part 'Database.g.dart';

@Database(version: 1, entities: [Flight])
@TypeConverters([DateTimeConverter])
abstract class ToDoDatabase extends FloorDatabase{

  //get interface to database
  FlightDAO get GetDao; // 1 function for giving access to insert, update delete


}