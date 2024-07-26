import 'package:flight_manager/Flight.dart';
import 'package:flight_manager/FlightDAO.dart';
import 'package:flight_manager/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'Database.dart';

class FlightsPage extends StatefulWidget {
  @override
  State<FlightsPage> createState() {
    return PersonalInfoState();
  }
}

class PersonalInfoState extends State<FlightsPage> {
  ///a list of existing flights
  var flights = <Flight>[];
  /// Object for database interactions
  late FlightDAO flightDAO;
  ///The currently selected flight
  Flight? selectedItem = null;

  @override
  void initState() {
    super.initState();

    $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build().then((database) {
      flightDAO = database.GetDao;
      //now you can query
      flightDAO.selectEverything().then((listOfItems) {
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

  /**
   * Creates a widget witg the flight list.
   * @return the flight list page
   */
  Widget FlightList() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Flight List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: flights.length,
              itemBuilder: (BuildContext context, int rowNum) {
                return GestureDetector(
                  onLongPress: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Remove Flight'),
                        content: const Text('Are you sure you want to remove this flight?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              removeFlight(rowNum);
                              //Navigator.pop(context, 'Yes');
                            },
                            child: Text("Yes", style: TextStyle(color: Colors.red)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'No'),
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: () {
                    setState(() {
                      selectedItem = flights[rowNum]; // selectedItem no longer null
                    });
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Departure: ${flights[rowNum].departureCity}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Destination: ${flights[rowNum].destinationCity}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Icon(Icons.airplanemode_active, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/homePage');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // background color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Go Back", style: TextStyle(color: Colors.white),),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addFlight');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // background color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Add Flight", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  /**
   * Creates a widget with the details of a flight
   * @return the details page
   */
  Widget DetailsPage() {
    if (selectedItem == null) {
      return Center(
        child: Text(
          "Select a Flight to see the details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Flight Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID: ${selectedItem!.id}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Departure: ${selectedItem!.departureCity}",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Destination: ${selectedItem!.destinationCity}",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Departure Time: ${selectedItem!.departureTime}",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Arrival Time: ${selectedItem!.arrivalTime}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("Close", style: TextStyle(color: Colors.white),),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    showDeleteConfirmationDialog(context);
                  },
                  child: Text("DELETE", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  /**
   * Displays an alertDialog asking for confirmation
   * @param context the context
   */
  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Flight'),
        content: const Text('Are you sure you want to delete this flight?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              deleteSelectedItem();
              Navigator.pop(context, 'Yes');
            },
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'No'),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  /**
   * Displays usage info as alertDialog
   * @param context the context
   */
  void showUsageInfo(BuildContext contex){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('1. Click a flight to display details.'),
                Text('2. Click a flight for 2 seconds to remove it.'),
                Text('3. Use \'BACK\' button to return to the main page.'),
                Text('4. Use \'ADD FLIGHT\' button to add a new flight.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /**
   * Deletes an item from DB and list
   */
  void deleteSelectedItem() {
    if (selectedItem != null) {
      setState(() {
        flightDAO.deleteFlight(selectedItem!);
        flights.remove(selectedItem);
        selectedItem = null;
      });
    }
  }

  /**
   * Creates a responsive layout when in landscape mode and screen size > 720
   * @return the layout to display
   */
  Widget responsiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) { // if in Landscape mode
      return Row(children: [
        Expanded(flex: 2, child: FlightList()),
        Expanded(flex: 3, child: DetailsPage())
      ]);
    } else { // if Portrait mode
      if (selectedItem == null) {
        return FlightList();
      } else {
        return DetailsPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(onPressed: () {showUsageInfo(context);}, icon: Icon(Icons.info))
        ],
        title: Text("Flights"),
      ),
      body: responsiveLayout(),
    );
  }

  /**
   * removes a flight from db and flight list.
   * @param rowNum the row number used for removing the item from the list.
   */
  void removeFlight(var rowNum) {
    setState(() {
      flightDAO.deleteFlight(flights.elementAt(rowNum));
      flights.removeAt(rowNum);
    });

    Navigator.of(context).pop();
  }
}
