import 'package:floor/floor.dart';

@entity
class Customer {
  static int ID = 1;

  @primaryKey
  final int id;

  final String firstName;
  final String lastName;
  final String address;
  final DateTime birthday;


  Customer(this.id, this.firstName, this.lastName, this.address, this.birthday) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}