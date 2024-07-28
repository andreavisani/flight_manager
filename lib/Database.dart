import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'TypeConverter.dart';

import 'Flight.dart';
import 'FlightDAO.dart';
import 'Customer.dart';
import 'CustomerDAO.dart';

part 'Database.g.dart';

@Database(version: 1, entities: [Flight, Customer])
@TypeConverters([DateTimeConverter])
abstract class FlightManagerDatabase extends FloorDatabase{

  //get interface to database
  CustomerDAO get customerDAO;
  FlightDAO get GetDao; // 1 function for giving access to insert, update delete


}