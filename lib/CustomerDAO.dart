import 'package:flutter/cupertino.dart';

import 'Customer.dart';
import 'package:floor/floor.dart';

@dao
abstract class CustomerDAO{


  @Query('SELECT * FROM Customer') // ToDoItem is the entity object
  Future<List<Customer>> selectEverything(); // returns an arrayList of ToDoItems

}