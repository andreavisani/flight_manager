import 'package:flight_manager/Flight.dart';
import 'package:flight_manager/FlightDAO.dart';
import 'package:flight_manager/main.dart';
import 'package:flutter/material.dart';

import 'Database.dart';


class FlightsPage extends StatefulWidget {
  @override
  State<FlightsPage> createState() {
    return PersonalInfoState();
  }
}

class PersonalInfoState extends State<FlightsPage> {

  var flights = <Flight>[];

  late FlightDAO flightDAO;

  @override
  void initState() {
    super.initState();

    $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build().then((database) {
      flightDAO = database.flightDAO;
      //now you can query
      flightDAO.selectEverything().then(  (listOfItems){
        setState(() {
          flights.addAll(listOfItems);
        });

      });
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
        title: Text("Flights"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Expanded(
              child: ListView.builder(
                itemCount: flights.length,
                itemBuilder: (BuildContext context, int rowNum) {
                  return GestureDetector(
                    onLongPress: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Remove'),
                          content: const Text('Remove instance?'),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                removeFlight(rowNum);
                              },
                              child: Text("Yes"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Departure: ${flights[rowNum].departureCity}"),
                        Text("Destination: ${flights[rowNum].destinationCity}"),
                      ],
                    ),
                  );
                },
              ),
            ),

            // === ADD BUTTON ===
            ElevatedButton(onPressed: () { Navigator.pushNamed(context, '/addFlight');} , child: Text("Add flight"),),


          ],
        ),
      ),
    );
  }

  void removeFlight(var rowNum){
    setState(() {

      flightDAO.deleteFlight(flights.elementAt(rowNum));

      flights.removeAt(rowNum);
    });

    Navigator.of(context).pop();
  }
}
