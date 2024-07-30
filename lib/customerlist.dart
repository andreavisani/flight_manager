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

      // Fetch the customer list from the database
      customerDAO.selectEverything().then((listOfItems) {
        setState(() {
          customer.addAll(listOfItems);
        });
      });
    });
  }

  void selectCustomer(Customer customer) {
    setState(() {
      selectedCustomer = customer;
    });
  }

  void _showDeleteDialog(BuildContext context, Customer customer) {
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
                _deleteCustomer(customer);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCustomer(Customer customer) {
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

  void _showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: Text('Here are the instructions for using the interface.'),
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
                  _showInstructionsDialog(context);
                },
              ),
            ],
          ),
          OutlinedButton(onPressed: () { Navigator.pop(context); }, child: Text("Go Back")),
        ],
      ),
      body: responsiveLayout(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/addCustomer');
        },
        icon: Icon(Icons.add),
        label: Text('Add a new Customer'),
        backgroundColor: Colors.blue,
      ),
    );
  }

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
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("ID: ${selectedCustomer!.id}"),
                        SizedBox(height: 4),
                        Text("First Name: ${selectedCustomer!.firstName}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Last Name: ${selectedCustomer!.lastName}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Address: ${selectedCustomer!.address}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Birthday: ${selectedCustomer!.birthday.toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showDeleteDialog(context, selectedCustomer!);
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      Text("First Name: ${selectedCustomer!.firstName}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Last Name: ${selectedCustomer!.lastName}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Address: ${selectedCustomer!.address}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Birthday: ${selectedCustomer!.birthday.toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showDeleteDialog(context, selectedCustomer!);
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
        ],
      );
    }
  }
}
