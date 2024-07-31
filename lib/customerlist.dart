import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Customer.dart';
import 'CustomerDAO.dart';
import 'Database.dart';
import 'AddCustomer.dart';

/// A stateful widget that displays a list of customers and their details.
class CustomersPage extends StatefulWidget {
  @override
  State<CustomersPage> createState() {
    return CustomersPageState();
  }
}

/// The state class for [CustomersPage] that manages the list of customers and their interactions.
class CustomersPageState extends State<CustomersPage> {
  /// The list of customers.
  var customer = <Customer>[];
  /// The DAO for managing customer data.
  late CustomerDAO customerDAO;
  /// The currently selected customer.
  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();

    $FloorFlightManagerDatabase
        .databaseBuilder('app_database.db')
        .build()
        .then((database) {
      customerDAO = database.customerDAO;

      // Fetch the customer list from the database
      customerDAO.selectEverything().then((listOfItems) {
        setState(() {
          customer.addAll(listOfItems);
        });
      });
    });
  }

  /// Selects a customer to display their details.
  /// [customer] is the customer to be selected.
  void selectCustomer(Customer customer) {
    setState(() {
      selectedCustomer = customer;
    });
  }

  /// Shows a dialog to confirm deletion of a customer.
  /// [context] is the build context.
  /// [customer] is the customer to be deleted.
  void showDeleteDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Customer'),
          content: Text('Are you sure you want to delete this customer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                deleteCustomer(customer);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  /// Deletes a customer from the database.
  ///
  /// [customer] is the customer to be deleted.
  void deleteCustomer(Customer customer) {
    customerDAO.deleteCustomer(customer).then((_) {
      // Fetch updated customer list after deletion
      customerDAO.selectEverything().then((updatedList) {
        setState(() {
          this.customer = updatedList;
          selectedCustomer = null; // Deselect customer after deletion
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
      }).catchError((error) {
        // Handle any errors that occur during fetching
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching updated customer list'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );
      });
    }).catchError((error) {
      // Handle any errors that occur during deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting customer'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );
    });
  }

  /// Shows an instructions dialog.
  ///
  /// [context] is the build context.
  void showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: Text('Select a customer to view their details.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Refreshes the customer list by fetching updated data from the database.
  void _refreshCustomerList() {
    customerDAO.selectEverything().then((listOfItems) {
      setState(() {
        customer = listOfItems;
        selectedCustomer = null; // Deselect customer after refresh
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing customer list'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Customers"),
        actions: [
          Row(
            children: [
              Text("Info:"),
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  showInstructionsDialog(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _refreshCustomerList,
              ),
            ],
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Go Back")),
        ],
      ),
      body: responsiveLayout(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newCustomer = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomer()),
          );
          if (newCustomer != null && newCustomer is Customer) {
            setState(() {
              customer.add(newCustomer);
            });
          }
        },
        icon: Icon(Icons.add),
        label: Text('Add'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Builds the responsive layout for the page based on screen size.
  ///
  /// [context] is the build context.
  ///
  /// Returns a widget representing the layout.
  Widget responsiveLayout(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    if (width > 720) {
      // Landscape mode
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Select a customer to view details",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: customer.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          selectCustomer(customer[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${customer[index].firstName} ${customer[index].lastName}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (selectedCustomer != null)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("ID: ${selectedCustomer!.id}"),
                        SizedBox(height: 4),
                        Text("First Name: ${selectedCustomer!.firstName}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Last Name: ${selectedCustomer!.lastName}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Address: ${selectedCustomer!.address}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                            "Birthday: ${selectedCustomer!.birthday.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (selectedCustomer != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddCustomer(
                                          customer: selectedCustomer),
                                    ),
                                  ).then((updatedCustomer) {
                                    if (updatedCustomer != null &&
                                        updatedCustomer is Customer) {
                                      setState(() {
                                        final index = customer.indexWhere(
                                            (c) => c.id == updatedCustomer.id);
                                        if (index != -1) {
                                          customer[index] = updatedCustomer;
                                        }
                                        selectedCustomer = updatedCustomer;
                                      });
                                    }
                                  });
                                }
                              },
                              icon: Icon(Icons.update),
                              label: Text("Update"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (selectedCustomer != null) {
                                  showDeleteDialog(context, selectedCustomer!);
                                }
                              },
                              icon: Icon(Icons.delete),
                              label: Text("Delete"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Portrait mode
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Select a customer to view details",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: customer.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    selectCustomer(customer[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${customer[index].firstName} ${customer[index].lastName}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedCustomer != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${selectedCustomer!.id}"),
                      SizedBox(height: 10),
                      Text("First Name: ${selectedCustomer!.firstName}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Last Name: ${selectedCustomer!.lastName}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Address: ${selectedCustomer!.address}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text(
                          "Birthday: ${selectedCustomer!.birthday.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (selectedCustomer != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddCustomer(customer: selectedCustomer),
                                  ),
                                ).then((updatedCustomer) {
                                  if (updatedCustomer != null &&
                                      updatedCustomer is Customer) {
                                    setState(() {
                                      final index = customer.indexWhere(
                                          (c) => c.id == updatedCustomer.id);
                                      if (index != -1) {
                                        customer[index] = updatedCustomer;
                                      }
                                      selectedCustomer = updatedCustomer;
                                    });
                                  }
                                });
                              }
                            },
                            icon: Icon(Icons.update),
                            label: Text("Update"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (selectedCustomer != null) {
                                showDeleteDialog(context, selectedCustomer!);
                              }
                            },
                            icon: Icon(Icons.delete),
                            label: Text("Delete"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    }
  }
}
