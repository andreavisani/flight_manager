import 'dart:async';
import 'Reservation.dart';
import 'Customer.dart';
import 'Flight.dart';
import 'Database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationDetail extends StatefulWidget {
  final bool isChildView;
  final Reservation? entity;
  final FutureOr<void> Function(Reservation entity)? onSave;
  final FutureOr<void> Function(Reservation entity)? onDelete;
  final void Function([String? message])? onClose;

  const ReservationDetail({
    Key? key,
    required this.isChildView,
    this.entity,
    this.onSave,
    this.onDelete,
    this.onClose,
  }) : super(key: key);

  @override
  State<ReservationDetail> createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  Customer? _selectedCustomer;
  Flight? _selectedFlight;
  List<Customer> _customers = [];
  List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    if (widget.entity != null) {
      _nameController.text = widget.entity!.reservationName;
      _selectedDate = DateTime.parse(widget.entity!.reservationDate);
    }
    _loadCustomersAndFlights();
    _loadLastUsedName();
  }

  void _loadCustomersAndFlights() async {
    final db = await $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build();
    final customers = await db.customerDAO.selectEverything();
    final flights = await db.GetDao.selectEverything();
    setState(() {
      _customers = customers;
      _flights = flights;
    });
  }

  void _loadLastUsedName() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUsedName = prefs.getString('lastUsedReservationName');
    if (lastUsedName != null && widget.entity == null) {
      setState(() {
        _nameController.text = lastUsedName;
      });
    }
  }

  void _saveLastUsedName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastUsedReservationName', name);
  }

  bool get isValid =>
      _nameController.text.isNotEmpty &&
          _selectedDate != null &&
          _selectedCustomer != null &&
          _selectedFlight != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entity == null ? 'New Reservation' : 'Edit Reservation'),
        automaticallyImplyLeading: !widget.isChildView,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Reservation Name'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<Customer>(
              value: _selectedCustomer,
              items: _customers.map((customer) {
                return DropdownMenuItem(
                  value: customer,
                  child: Text('${customer.firstName} ${customer.lastName}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomer = value;
                });
              },
              decoration: InputDecoration(labelText: 'Select Customer'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<Flight>(
              value: _selectedFlight,
              items: _flights.map((flight) {
                return DropdownMenuItem(
                  value: flight,
                  child: Text('${flight.departureCity} to ${flight.destinationCity}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFlight = value;
                });
              },
              decoration: InputDecoration(labelText: 'Select Flight'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : 'Date: ${_selectedDate!.toIso8601String().split('T')[0]}'),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: !isValid
                      ? null
                      : () async {
                    final reservation = Reservation(
                      id: widget.entity?.id,
                      customerId: _selectedCustomer!.id,
                      flightId: _selectedFlight!.id,
                      reservationDate: _selectedDate!.toIso8601String(),
                      reservationName: _nameController.text,
                    );
                    await widget.onSave?.call(reservation);
                    _saveLastUsedName(_nameController.text);
                    if (!widget.isChildView) {
                      Navigator.pop(context);
                    } else {
                      widget.onClose?.call('Reservation saved');
                    }
                  },
                  child: Text(widget.entity == null ? 'Create' : 'Save'),
                ),
                if (widget.entity != null)
                  ElevatedButton(
                    onPressed: () async {
                      await widget.onDelete?.call(widget.entity!);
                      if (!widget.isChildView) {
                        Navigator.pop(context);
                      } else {
                        widget.onClose?.call('Reservation deleted');
                      }
                    },
                    child: Text('Delete'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}