import 'package:flight_manager/Flight.dart';
import 'package:flight_manager/FlightDAO.dart';
import 'package:flight_manager/main.dart';
import 'package:flutter/material.dart';

import 'Customer.dart';
import 'CustomerDAO.dart';
import 'Database.dart';


class CustomersPage extends StatefulWidget {
  @override
  State<CustomersPage> createState() {
    return CustomersPageState();
  }
}

class CustomersPageState extends State<CustomersPage> {

  var customer = <Customer>[];

  late CustomerDAO customerDAO;

  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();

    $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build().then((database) {
      customerDAO = database.customerDAO;

      //now you can query
      customerDAO.selectEverything().then(  (listOfItems){
        setState(() {
          customer.addAll(listOfItems);

        });

      });
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  void selectCustomer(Customer customer) {
    setState(() {
      selectedCustomer = customer;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Customers"),
        actions: [
          OutlinedButton(onPressed: () { Navigator.pop(context); }, child: Text("Go Back")),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: customer.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    selectCustomer(customer[index]);
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text("${customer[index].firstName} ${customer[index].lastName}")
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: selectedCustomer == null
                ? Center(child: Text("Select a customer to view details"))
                : CustomerDetailsPage(
              customer: selectedCustomer!,
              deleteCustomer: (customer) {
                setState(() {
                  customerDAO.deleteCustomer(customer);
                  // customer.remove(customer);
                  selectedCustomer = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Customer deleted'),
                    backgroundColor: Colors.teal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { Navigator.pushNamed(context, '/addCustomer'); },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class CustomerDetailsPage extends StatelessWidget {
  final Customer customer;
  final Function(Customer) deleteCustomer;

  const CustomerDetailsPage({
    Key? key,
    required this.customer,
    required this.deleteCustomer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID: ${customer.id}",

            ),
            SizedBox(height: 10),
            Text(
              "First Name: ${customer.firstName}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Last Name: ${customer.lastName}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Address: ${customer.address}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Birthday: ${customer.birthday.toLocal().toString().split(' ')[0]}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                deleteCustomer(customer);
                Navigator.of(context).pop(); // Navigate back to the previous screen
              },
              icon: Icon(Icons.delete),
              label: Text("Delete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}