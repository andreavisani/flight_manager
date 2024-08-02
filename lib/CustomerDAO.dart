import 'package:flutter/cupertino.dart';

import 'Customer.dart';
import 'package:floor/floor.dart';

@dao
abstract class CustomerDAO{


  @Query('SELECT * FROM Customer') // ToDoItem is the entity object
  Future<List<Customer>> selectEverything(); // returns an arrayList of ToDoItems

@insert //make it an insert function to generate
Future<int> insertCustomer(Customer customer);

  @delete  // generate the deletion statement in code
  Future<void> deleteCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);

}


