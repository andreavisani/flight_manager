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
    return AddFlightState();
  }
}

class AddFlightState extends State<AddFlight> {
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

  void addFlight() {
    setState(() {
      final DateTime departureTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerDeparture.text);
      final DateTime arrivalTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerArrival.text);

      var newFlight = Flight(Flight.ID++, _controllerDepartureCity.value.text, _controllerDestinationCity.value.text, departureTime, arrivalTime);

      flightDAO.insertFlight(newFlight);

      Navigator.pushNamed(context, '/flights');
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
    _controllerDepartureCity.dispose();
    _controllerDestinationCity.dispose();
    _dateTimeControllerDeparture.dispose();
    _dateTimeControllerArrival.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Add new flight"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add New Flight",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controllerDepartureCity,
              decoration: InputDecoration(
                hintText: "Departure City",
                border: OutlineInputBorder(),
                labelText: "Departure City",
                prefixIcon: Icon(Icons.flight_takeoff, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controllerDestinationCity,
              decoration: InputDecoration(
                hintText: "Destination City",
                border: OutlineInputBorder(),
                labelText: "Destination City",
                prefixIcon: Icon(Icons.flight_land, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dateTimeControllerDeparture,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Select Departure Date and Time',
                border: OutlineInputBorder(),
                labelText: "Departure Time",
                prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
              ),
              onTap: () => _selectDateTime(context, _dateTimeControllerDeparture),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dateTimeControllerArrival,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Select Arrival Date and Time',
                border: OutlineInputBorder(),
                labelText: "Arrival Time",
                prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
              ),
              onTap: () => _selectDateTime(context, _dateTimeControllerArrival),
            ),
            SizedBox(height: 24),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/flights');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // background color
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text("Go Back", style: TextStyle(color: Colors.white),),
                  ),
                  ElevatedButton(
                  onPressed: addFlight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // background color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("ADD FLIGHT", style: TextStyle(color: Colors.white),),

                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}
