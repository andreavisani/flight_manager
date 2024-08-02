import 'package:flutter/material.dart';
import 'Customer.dart';
import 'CustomerDAO.dart';
import 'Database.dart';
import 'AddCustomer.dart';
import 'AppLocalizations.dart';

/// A widget that displays a list of customers and allows adding, updating, and deleting customers.
class CustomersPage extends StatefulWidget {
  /// A callback function to set the locale for the app.
  final Function(Locale) setLocale;

  /// Creates an instance of [CustomersPage].
  const CustomersPage({super.key, required this.setLocale});

  @override
  State<CustomersPage> createState() {
    return CustomersPageState();
  }
}

/// The state class for [CustomersPage] that manages the customer list and operations.
class CustomersPageState extends State<CustomersPage> {
  var customer = <Customer>[];
  late CustomerDAO customerDAO;
  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();

    // Initialize the database and load customers
    $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build().then((database) {
      customerDAO = database.customerDAO;

      customerDAO.selectEverything().then((listOfItems) {
        setState(() {
          customer.addAll(listOfItems);
        });
      });
    });
  }

  /// Selects a customer from the list.
  ///
  /// [customer] is the customer to be selected.
  void selectCustomer(Customer customer) {
    setState(() {
      selectedCustomer = customer;
    });
  }

  /// Shows a dialog to confirm the deletion of a customer.
  ///
  /// [context] is the build context.
  /// [customer] is the customer to be deleted.
  void showDeleteDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('delete_customer')!),
          content: Text(AppLocalizations.of(context)!.translate('confirm_delete_customer')!),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.translate('no')!),
            ),
            TextButton(
              onPressed: () {
                deleteCustomer(customer);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.translate('yes')!),
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
      customerDAO.selectEverything().then((updatedList) {
        setState(() {
          this.customer = updatedList;
          selectedCustomer = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('customer_deleted')!),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('error_fetching_customer_list')!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('error_deleting_customer')!),
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
          title: Text(AppLocalizations.of(context)!.translate('instructions')!),
          content: Text(AppLocalizations.of(context)!.translate('select_customer_to_view_details')!),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.translate('close')!),
            ),
          ],
        );
      },
    );
  }

  /// Refreshes the customer list by re-fetching all customers from the database.
  void _refreshCustomerList() {
    customerDAO.selectEverything().then((listOfItems) {
      setState(() {
        customer = listOfItems;
        selectedCustomer = null;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('error_refreshing_customer_list')!),
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
        title: Text(AppLocalizations.of(context)!.translate('title_customers')!),
        actions: [
          OutlinedButton(
            onPressed: () {
              widget.setLocale(Locale("ne", "NP"));
            },
            child: Text(AppLocalizations.of(context)!.translate('switch_to_nepali')!),
          ),
          OutlinedButton(
            onPressed: () {
              widget.setLocale(Locale("en", "US"));
            },
            child: Text(AppLocalizations.of(context)!.translate('switch_to_english')!),
          ),
          Row(
            children: [
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
            child: Text(AppLocalizations.of(context)!.translate('go_back')!),
          ),
        ],
      ),
      body: responsiveLayout(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newCustomer = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomer(setLocale: widget.setLocale)),
          );
          if (newCustomer != null && newCustomer is Customer) {
            setState(() {
              customer.add(newCustomer);
            });
          }
        },
        icon: Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.translate('add_customer')!),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Builds a responsive layout for the customer list and details.
  ///
  /// [context] is the build context.
  Widget responsiveLayout(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;

    if (width > 720) {
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
                    AppLocalizations.of(context)!.translate('select_customer_to_view_details')!,
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
                          AppLocalizations.of(context)!.translate('details')!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("ID: ${selectedCustomer!.id}"),
                        SizedBox(height: 4),
                        Text("${AppLocalizations.of(context)!.translate('first_name')}: ${selectedCustomer!.firstName}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("${AppLocalizations.of(context)!.translate('last_name')}: ${selectedCustomer!.lastName}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("${AppLocalizations.of(context)!.translate('address')}: ${selectedCustomer!.address}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("${AppLocalizations.of(context)!.translate('birthday')}: ${selectedCustomer!.birthday.toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (selectedCustomer != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddCustomer(customer: selectedCustomer, setLocale: widget.setLocale),
                                    ),
                                  ).then((updatedCustomer) {
                                    if (updatedCustomer != null && updatedCustomer is Customer) {
                                      setState(() {
                                        final index = customer.indexWhere((c) => c.id == updatedCustomer.id);
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
                              label: Text(AppLocalizations.of(context)!.translate('update')!),
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
                              label: Text(AppLocalizations.of(context)!.translate('delete')!),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              AppLocalizations.of(context)!.translate('select_customer_to_view_details')!,
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
                    AppLocalizations.of(context)!.translate('details')!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${selectedCustomer!.id}"),
                      SizedBox(height: 10),
                      Text("${AppLocalizations.of(context)!.translate('first_name')}: ${selectedCustomer!.firstName}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("${AppLocalizations.of(context)!.translate('last_name')}: ${selectedCustomer!.lastName}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("${AppLocalizations.of(context)!.translate('address')}: ${selectedCustomer!.address}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("${AppLocalizations.of(context)!.translate('birthday')}: ${selectedCustomer!.birthday.toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (selectedCustomer != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCustomer(customer: selectedCustomer, setLocale: widget.setLocale),
                                  ),
                                ).then((updatedCustomer) {
                                  if (updatedCustomer != null && updatedCustomer is Customer) {
                                    setState(() {
                                      final index = customer.indexWhere((c) => c.id == updatedCustomer.id);
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
                            label: Text(AppLocalizations.of(context)!.translate('update')!),
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
                            label: Text(AppLocalizations.of(context)!.translate('delete')!),
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
