import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'TypeConverter.dart';

import 'Flight.dart';
import 'FlightDAO.dart';
import 'Customer.dart';
import 'CustomerDAO.dart';
import 'Reservation.dart';
import 'ReservationDAO.dart';

part 'Database.g.dart';

@Database(version: 1, entities: [Flight, Customer, Reservation])
@TypeConverters([DateTimeConverter])
abstract class FlightManagerDatabase extends FloorDatabase{


  CustomerDAO get customerDAO;

  ///get interface to database

  FlightDAO get GetDao; // 1 function for giving access to insert, update delete

  ReservationDAO get ReservationDao;

}