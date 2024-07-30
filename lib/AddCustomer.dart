import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'Customer.dart';
import 'CustomerDAO.dart';
import 'Database.dart';

class AddCustomer extends StatefulWidget {
  final Customer? customer;

  AddCustomer({this.customer});

  @override
  State<AddCustomer> createState() {
    return AddCustomerState();
  }
}

class AddCustomerState extends State<AddCustomer> {
  late TextEditingController _controllerFirstName;
  late TextEditingController _controllerLastName;
  late TextEditingController _controllerAddress;
  late TextEditingController _dateTimeControllerBirthday;
  late CustomerDAO customerDAO;
  final EncryptedSharedPreferences encryptedSharedPreferences = EncryptedSharedPreferences();

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final DateTime combinedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      String formattedDateTime = DateFormat('yyyy-MM-dd').format(combinedDateTime);
      controller.text = formattedDateTime;
      encryptedSharedPreferences.setString('birthday', formattedDateTime);
    }
  }

  void addCustomer() {
    setState(() {
      // Check if all fields have a value
      if (_controllerFirstName.text.isEmpty ||
          _controllerLastName.text.isEmpty ||
          _controllerAddress.text.isEmpty ||
          _dateTimeControllerBirthday.text.isEmpty) {

        // Show a Snackbar if any field is empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );
        return;
      }

      try {
        final DateTime birthday = DateFormat('yyyy-MM-dd').parse(_dateTimeControllerBirthday.text);

        // Increment the ID and create a new Customer
        var newCustomer = Customer(
          Customer.ID++,
          _controllerFirstName.text,
          _controllerLastName.text,
          _controllerAddress.text,
          birthday,
        );

        // Insert the new customer into the database
        customerDAO.insertCustomer(newCustomer);

        // Show a success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer added successfully'),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );

        // Pass the new customer back to the previous screen
        Navigator.pop(context, newCustomer);
      } catch (e) {
        print("Error adding customer: $e");
      }
    });
  }

  void updateCustomer() {
    setState(() {
      // Check if all fields have a value
      if (_controllerFirstName.text.isEmpty ||
          _controllerLastName.text.isEmpty ||
          _controllerAddress.text.isEmpty ||
          _dateTimeControllerBirthday.text.isEmpty) {

        // Show a Snackbar if any field is empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );
        return;
      }

      try {
        final DateTime birthday = DateFormat('yyyy-MM-dd').parse(_dateTimeControllerBirthday.text);

        // Update the existing Customer
        var updatedCustomer = Customer(
          widget.customer!.id,
          _controllerFirstName.text,
          _controllerLastName.text,
          _controllerAddress.text,
          birthday,
        );

        // Update the customer in the database
        customerDAO.updateCustomer(updatedCustomer);

        // Show a success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer updated successfully'),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );

        // Pass the updated customer back to the previous screen
        Navigator.pop(context, updatedCustomer);
      } catch (e) {
        print("Error updating customer: $e");
      }
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: Text('To add or update a customer, fill in the fields and click the "Save Customer" button.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _refreshPage() {
    setState(() {
      _controllerFirstName.clear();
      _controllerLastName.clear();
      _controllerAddress.clear();
      _dateTimeControllerBirthday.clear();
    });
  }

  @override
  void initState() {
    super.initState();

    _controllerFirstName = TextEditingController();
    _controllerLastName = TextEditingController();
    _controllerAddress = TextEditingController();
    _dateTimeControllerBirthday = TextEditingController();

    if (widget.customer != null) {
      _controllerFirstName.text = widget.customer!.firstName;
      _controllerLastName.text = widget.customer!.lastName;
      _controllerAddress.text = widget.customer!.address;
      _dateTimeControllerBirthday.text = DateFormat('yyyy-MM-dd').format(widget.customer!.birthday);
    } else {
      // Retrieve saved inputs from EncryptedSharedPreferences
      encryptedSharedPreferences.getString('first_name').then((value) {
        if (value != null) {
          _controllerFirstName.text = value;
        }
      });

      encryptedSharedPreferences.getString('last_name').then((value) {
        if (value != null) {
          _controllerLastName.text = value;
        }
      });

      encryptedSharedPreferences.getString('address').then((value) {
        if (value != null) {
          _controllerAddress.text = value;
        }
      });

      encryptedSharedPreferences.getString('birthday').then((value) {
        if (value != null) {
          _dateTimeControllerBirthday.text = value;
        }
      });
    }

    $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build().then((database) {
      setState(() {
        customerDAO = database.customerDAO;
      });
    });
  }

  @override
  void dispose() {
    _controllerFirstName.dispose();
    _controllerLastName.dispose();
    _controllerAddress.dispose();
    _dateTimeControllerBirthday.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.customer == null ? "Add Customer" : "Update Customer"),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _showInstructions,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPage,
          ),
          OutlinedButton(onPressed: () { Navigator.pop(context); }, child: Text("Go Back")),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controllerFirstName,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                encryptedSharedPreferences.setString('first_name', value);
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _controllerLastName,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                encryptedSharedPreferences.setString('last_name', value);
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _controllerAddress,
              decoration: InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                encryptedSharedPreferences.setString('address', value);
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateTimeControllerBirthday,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Select Birthday',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDateTime(context, _dateTimeControllerBirthday),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.customer == null ? addCustomer : updateCustomer,
              child: Text(widget.customer == null ? "Add Customer" : "Update Customer"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
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
