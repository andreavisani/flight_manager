import 'dart:async';
import 'Reservation.dart';
import 'Customer.dart';
import 'Flight.dart';
import 'Database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppLocalizations.dart';

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
  TextEditingController _customerController = TextEditingController();
  TextEditingController _flightController = TextEditingController();
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

      if (widget.entity != null) {
        Customer? customer;
        for (var c in customers) {
          if (c.id == widget.entity!.customerId) {
            customer = c;
            break;
          }
        }

        Flight? flight;
        for (var f in flights) {
          if (f.id == widget.entity!.flightId) {
            flight = f;
            break;
          }
        }

        if (customer != null) {
          _customerController.text = '${customer.firstName} ${customer.lastName}';
          _selectedCustomer = customer;
        }

        if (flight != null) {
          _flightController.text = '${flight.departureCity} to ${flight.destinationCity}';
          _selectedFlight = flight;
        }
      }


    });
  }

  void _loadLastUsedName() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUsedName = prefs.getString('lastUsedReservationName');
    final lastUsedDate = prefs.getString('lastUsedReservationDate');
    final lastUsedCustomer = prefs.getString('lastUsedCustomer');
    final lastUsedFlight = prefs.getString('lastUsedFlight');
    if (lastUsedName != null && widget.entity == null) {
      setState(() {
        _nameController.text = lastUsedName;
      });
    }
    if (lastUsedDate != null && widget.entity == null) {
      setState(() {
        _selectedDate = DateTime.parse(lastUsedDate);
      });
    }
    if (lastUsedCustomer != null && widget.entity == null) {
      setState(() {
        _customerController.text = lastUsedCustomer;
      });
    }
    if (lastUsedFlight != null && widget.entity == null) {
      setState(() {
        _flightController.text = lastUsedFlight;
      });
    }

  }

  void _saveLastUsedName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastUsedReservationName', _nameController.text);
    if (_selectedDate != null) {
      await prefs.setString('lastUsedReservationDate', _selectedDate!.toIso8601String());
    }
    await prefs.setString('lastUsedCustomer', _customerController.text);
    await prefs.setString('lastUsedFlight', _flightController.text);

  }

  bool get isValid =>
      _nameController.text.isNotEmpty &&
          _selectedDate != null &&
          _customerController.text.isNotEmpty &&
          _flightController.text.isNotEmpty;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entity == null
              ? AppLocalizations.of(context)?.translate('new_reservation') ?? 'New Reservation'
              : AppLocalizations.of(context)?.translate('edit_reservation') ?? 'Edit Reservation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: !widget.isChildView,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.translate('reservation_name') ?? 'Reservation Name',
                labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<Customer>(
              value: _selectedCustomer,
              items: _customers.map((customer) {
                return DropdownMenuItem(
                  value: customer,
                  child: Text('${customer.firstName} ${customer.lastName}', style: TextStyle(color: Colors.black),),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomer = value;
                  _customerController.text = '${value?.firstName} ${value?.lastName}';
                });
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.translate('select_customer') ?? 'Select Customer',
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<Flight>(
              value: _selectedFlight,
              items: _flights.map((flight) {
                return DropdownMenuItem(
                  value: flight,
                  child: Text('${flight.departureCity} ${AppLocalizations.of(context)?.translate('to') ?? 'to'} ${flight.destinationCity}', style: TextStyle(color: Colors.black),),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFlight = value;
                  _flightController.text = '${value?.departureCity} ${AppLocalizations.of(context)?.translate('to') ?? 'to'} ${value?.destinationCity}';
                });
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.translate('select_flight') ?? 'Select Flight',
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
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
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                _selectedDate == null
                    ? AppLocalizations.of(context)?.translate('select_date') ?? 'Select Date'
                    : '${AppLocalizations.of(context)?.translate('date') ?? 'Date'}: ${_selectedDate!.toIso8601String().split('T')[0]}',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 60),
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
                    _saveLastUsedName();
                    if (!widget.isChildView) {
                      Navigator.pop(context);
                    } else {
                      widget.onClose?.call(AppLocalizations.of(context)?.translate('reservation_saved') ?? 'Reservation saved');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    widget.entity == null
                        ? AppLocalizations.of(context)?.translate('create') ?? 'Create'
                        : AppLocalizations.of(context)?.translate('save') ?? 'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (widget.entity != null)
                  ElevatedButton(
                    onPressed: () async {
                      await widget.onDelete?.call(widget.entity!);
                      if (!widget.isChildView) {
                        Navigator.pop(context);
                      } else {
                        widget.onClose?.call(AppLocalizations.of(context)?.translate('reservation_deleted') ?? 'Reservation deleted');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('delete') ?? 'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.entity == null ? 'New Reservation' : 'Edit Reservation', style: TextStyle(fontWeight: FontWeight.bold),),
//         automaticallyImplyLeading: !widget.isChildView,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Reservation Name',
//                 labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<Customer>(
//               value: _selectedCustomer,
//               items: _customers.map((customer) {
//                 return DropdownMenuItem(
//                   value: customer,
//                   child: Text('${customer.firstName} ${customer.lastName}', style: TextStyle(color: Colors.black),),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCustomer = value;
//                   _customerController.text = '${value?.firstName} ${value?.lastName}';
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'Select Customer',
//                 labelStyle: TextStyle(fontSize: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               style: TextStyle(fontSize: 16, color: Colors.black),
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<Flight>(
//               value: _selectedFlight,
//               items: _flights.map((flight) {
//                 return DropdownMenuItem(
//                   value: flight,
//                   child: Text('${flight.departureCity} to ${flight.destinationCity}', style: TextStyle(color: Colors.black),),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedFlight = value;
//                   _flightController.text = '${value?.departureCity} to ${value?.destinationCity}';
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'Select Flight',
//                 labelStyle: TextStyle(fontSize: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               style: TextStyle(fontSize: 16, color: Colors.black),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 final date = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate ?? DateTime.now(),
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime.now().add(Duration(days: 365)),
//                 );
//                 if (date != null) {
//                   setState(() {
//                     _selectedDate = date;
//                   });
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                 textStyle: TextStyle(fontSize: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 backgroundColor: Colors.blue,
//               ),
//               child: Text(
//                 _selectedDate == null ? 'Select Date' : 'Date: ${_selectedDate!.toIso8601String().split('T')[0]}',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             SizedBox(height: 60),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: !isValid
//                       ? null
//                       : () async {
//                     final reservation = Reservation(
//                       id: widget.entity?.id,
//                       customerId: _selectedCustomer!.id,
//                       flightId: _selectedFlight!.id,
//                       reservationDate: _selectedDate!.toIso8601String(),
//                       reservationName: _nameController.text,
//                     );
//                     await widget.onSave?.call(reservation);
//                     _saveLastUsedName();
//                     if (!widget.isChildView) {
//                       Navigator.pop(context);
//                     } else {
//                       widget.onClose?.call('Reservation saved');
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                     textStyle: TextStyle(fontSize: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     backgroundColor: Colors.blue,
//                   ),
//                   child: Text(widget.entity == null ? 'Create' : 'Save',  style: TextStyle(color: Colors.white),),
//                 ),
//                 if (widget.entity != null)
//                   ElevatedButton(
//                     onPressed: () async {
//                       await widget.onDelete?.call(widget.entity!);
//                       if (!widget.isChildView) {
//                         Navigator.pop(context);
//                       } else {
//                         widget.onClose?.call('Reservation deleted');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                       textStyle: TextStyle(fontSize: 16),
//                       shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                       backgroundColor: Colors.red,
//                     ),
//                     child: Text(
//                       'Delete',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//               ],
//             ),
//             SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }