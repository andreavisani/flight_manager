import 'package:flight_manager/Flight.dart';
import 'package:flight_manager/FlightDAO.dart';
import 'package:flight_manager/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'AppLocalizations.dart';
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
  /// controller for departure city when editing
  late TextEditingController _controllerDepartureCity;
  /// controller for destination city when editing
  late TextEditingController _controllerDestinationCity;
  /// controller for departure time when editing
  late TextEditingController _dateTimeControllerDeparture;
  /// controller for arrival time when editing
  late TextEditingController _dateTimeControllerArrival;

  @override
  void initState() {
    super.initState();

    _controllerDepartureCity = TextEditingController();
    _controllerDestinationCity = TextEditingController();
    _dateTimeControllerDeparture = TextEditingController();
    _dateTimeControllerArrival = TextEditingController();

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

  /**
   * Opens a date and time picker dialog for the user to select a date and time.
   * Then formats and formatted and set TextEditingController.
   *
   * @param context The BuildContext in which the dialogs should be displayed
   * @param controller The TextEditingController to store the selected date and time.
   * @return A Future that completes once the user has finished selecting the date and time.
   */
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

  @override
  void dispose() {
    super.dispose();
    _controllerDepartureCity.dispose();
    _controllerDestinationCity.dispose();
    _dateTimeControllerDeparture.dispose();
    _dateTimeControllerArrival.dispose();
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
            AppLocalizations.of(context)!.translate('flights_list')!,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
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
                        title: Text(AppLocalizations.of(context)!.translate('remove_flight')!),
                        content: Text(AppLocalizations.of(context)!.translate('remove_flight_conf')!),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              removeFlight(rowNum);
                              //Navigator.pop(context, 'Yes');
                            },
                            child: Text(AppLocalizations.of(context)!.translate('yes')!, style: TextStyle(color: Colors.red)),
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
                              Text( AppLocalizations.of(context)!.translate('departure')!+ " ${flights[rowNum].departureCity}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(AppLocalizations.of(context)!.translate('destination')!+ " ${flights[rowNum].destinationCity}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Icon(Icons.airplanemode_active, color: Colors.blue[900]),
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
              ///Resets the language to english, to avoid crashes with other languages
              ElevatedButton(
                onPressed: () {
                  MyApp.setLocale(context, new Locale("en", "CA"));
                  Navigator.pushNamed(context, '/homePage');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900], // background color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(AppLocalizations.of(context)!.translate('back')!, style: TextStyle(color: Colors.white),),
              ),
              // ADD FLIGHT BUTTON
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addFlight');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900], // background color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(AppLocalizations.of(context)!.translate('add_flight')!, style: TextStyle(color: Colors.white),),
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
          AppLocalizations.of(context)!.translate('select_details')!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            AppLocalizations.of(context)!.translate('flights_details')!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
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
                    Text(AppLocalizations.of(context)!.translate('departure_city')! + " ${selectedItem!.departureCity}",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(AppLocalizations.of(context)!.translate('destination_city')! + " ${selectedItem!.destinationCity}",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(AppLocalizations.of(context)!.translate('departure_time')! + " ${selectedItem!.departureTime}",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(AppLocalizations.of(context)!.translate('arrival_time')! + " ${selectedItem!.arrivalTime}",
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
                //CLOSE BUTTON
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text(AppLocalizations.of(context)!.translate('close')!, style: TextStyle(color: Colors.white),),
                ),

                //EDIT BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    if (selectedItem != null) {
                      showEditConfirmationDialog(context, selectedItem);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No flight selected for editing')),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.translate('edit')!, style: TextStyle(color: Colors.white)),
                ),


                //DELETE BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    showDeleteConfirmationDialog(context);
                  },
                  child: Text(AppLocalizations.of(context)!.translate('delete')!, style: TextStyle(color: Colors.white)),
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
        title: Text(AppLocalizations.of(context)!.translate('delete_flight')!),
        content: Text(AppLocalizations.of(context)!.translate('delete_flight_conf')!),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              deleteSelectedItem();
              Navigator.pop(context, 'Yes');
            },
            child: Text(AppLocalizations.of(context)!.translate('yes')!, style: TextStyle(color: Colors.red)),
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
   * Opens a dialog window that enables the user to edit a flight
   * @param context The context
   * @param selectedItem The flight to be modified
   */
  void showEditConfirmationDialog(BuildContext context, Flight? selectedItem) {
    if (selectedItem == null) {
      // Optionally handle the case where selectedItem is null
      return;
    }

    _controllerDestinationCity.text = selectedItem.destinationCity;
    _controllerDepartureCity.text = selectedItem.departureCity;
    _dateTimeControllerDeparture.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedItem.departureTime);
    _dateTimeControllerArrival.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedItem.arrivalTime);

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('edit_flight')!),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('edit_flight')!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controllerDepartureCity,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.translate('departure_city')!,
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.translate('departure_city')!,
                  prefixIcon: Icon(Icons.flight_takeoff, color: Colors.blue[900]),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controllerDestinationCity,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.translate('destination_city')!,
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.translate('destination_city')!,
                  prefixIcon: Icon(Icons.flight_land, color: Colors.blue[900]),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dateTimeControllerDeparture,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.translate('departure_time')!,
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.translate('departure_time')!,
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[900]),
                ),
                onTap: () => _selectDateTime(context, _dateTimeControllerDeparture),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dateTimeControllerArrival,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.translate('arrival_time')!,
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.translate('arrival_time')!,
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[900]),
                ),
                onTap: () => _selectDateTime(context, _dateTimeControllerArrival),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              saveEditedFlight(selectedItem);
              Navigator.pop(context, 'Save');
            },
            child: Text(AppLocalizations.of(context)!.translate('save')!, style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: Text(AppLocalizations.of(context)!.translate('cancel')!),
          ),
        ],
      ),
    );
  }


  /**
   * Saved the edited flight in the db
   * @param selectedItem the flight to save
   */
  void saveEditedFlight(Flight? selectedItem) {
    if (selectedItem != null) {
      setState(() {
        selectedItem.departureCity = _controllerDepartureCity.text;
        selectedItem.destinationCity = _controllerDestinationCity.text;
        selectedItem.departureTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerDeparture.text);
        selectedItem.arrivalTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerArrival.text);
        flightDAO.updateFlight(selectedItem); // Assuming updateFlight is a method in your DAO
      });
    }
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
          title: Text(AppLocalizations.of(context)!.translate('instructions')!),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.translate('flights_list_instruction1')!),
                Text(AppLocalizations.of(context)!.translate('flights_list_instruction2')!),
                Text(AppLocalizations.of(context)!.translate('flights_list_instruction3')!),
                Text(AppLocalizations.of(context)!.translate('flights_list_instruction4')!),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('close')!),
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
   * Displays an AlertDialog with options to change language
   * @param contex the context
   */
  void showLanguageInfo(BuildContext contex){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Choose the language'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Italiano'),
              onPressed: () {
                MyApp.setLocale(context, new Locale("it", "IT"));
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('English'),
              onPressed: () {
                MyApp.setLocale(context, new Locale("en", "CA"));
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
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(onPressed: () {showUsageInfo(context);}, icon: Icon(Icons.info, color: Colors.white,)),
          IconButton(onPressed: () {showLanguageInfo(context);}, icon: Icon(Icons.language, color: Colors.white,)),
        ],
        title: Text(AppLocalizations.of(context)!.translate('flights')!,
          style: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,),
      ),
        centerTitle: true,
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
