import 'package:flight_manager/Flight.dart';
import 'package:flight_manager/FlightDAO.dart';
import 'package:flight_manager/main.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'Database.dart';


class AddFlight extends StatefulWidget {
  @override
  State<AddFlight> createState() {
    return AddCustomerState();
  }
}

class AddCustomerState extends State<AddFlight> {

  late TextEditingController _controllerDepartureCity;
  late TextEditingController _controllerDestinationCity;
  late TextEditingController _dateTimeControllerDeparture;
  late TextEditingController _dateTimeControllerArrival;
  late FlightDAO flightDAO;


  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);
        controller.text = formattedDateTime;
      }
    }
  }

  void addFlight(){
    setState(() {
      final DateTime departureTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerDeparture.text);
      final DateTime arrivalTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerArrival.text);

      // putting ID++, make sure the id is increased every time
      var newFlight = Flight(Flight.ID++, _controllerDepartureCity.value.text, _controllerDestinationCity.value.text, departureTime, arrivalTime);

      //add to db
      flightDAO.insertFlight(newFlight);


    });
  }





  @override
  void initState() {
    super.initState();

    _controllerDepartureCity = TextEditingController();
    _controllerDestinationCity = TextEditingController();
    _dateTimeControllerDeparture = TextEditingController();
    _dateTimeControllerArrival = TextEditingController();

    $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build().then((database) {
      flightDAO = database.GetDao;

    });

  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Add new flight"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // === DEPARTURE CITY ===
            TextField(
              controller: _controllerDepartureCity,
              decoration: InputDecoration(
                hintText: "Departure City",
                border: OutlineInputBorder(),
                labelText: "Departure City",
              ),
            ),

            // === DESTINATION CITY ===
            TextField(
              controller: _controllerDestinationCity,
              decoration: InputDecoration(
                hintText: "Destination City",
                border: OutlineInputBorder(),
                labelText: "Destination City",
              ),
            ),

            // === DEPARTURE TIME ===
            TextField(
              controller: _dateTimeControllerDeparture,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Select Date and Time',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDateTime(context, _dateTimeControllerDeparture),
            ),

            // === ARRIVAL TIME ===
            TextField(
              controller: _dateTimeControllerArrival,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Select Date and Time',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDateTime(context, _dateTimeControllerArrival),
            ),

            ElevatedButton(onPressed: addFlight, child: Text("ADD")),




          ],
        ),
      ),
    );
  }


}
