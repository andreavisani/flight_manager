import 'package:flight_manager/Flight.dart';
import 'package:flight_manager/FlightDAO.dart';
import 'package:flight_manager/main.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class AddFlight extends StatefulWidget {
  @override
  State<AddFlight> createState() {
    return AddFlightState();
  }
}

class AddFlightState extends State<AddFlight> {
  /// controller for departure city
  late TextEditingController _controllerDepartureCity;
  /// controller for destination city
  late TextEditingController _controllerDestinationCity;
  /// controller for departure time
  late TextEditingController _dateTimeControllerDeparture;
  /// controller for arrival time
  late TextEditingController _dateTimeControllerArrival;
  /// the fligth objects interacting with the db
  late FlightDAO flightDAO;
  /// shared preferences
  late EncryptedSharedPreferences savedData;
  /// a snackbar
  var snackBar;

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

  /**
   * Checks if departure and destination city have values, if so, displays a snackBar
   */
  void checkFields(){
    // if both are not empty
    if ((_controllerDepartureCity.value.text == "" || _controllerDepartureCity.value.text == null) && (_controllerDestinationCity.value.text == "" || _controllerDestinationCity.value.text == null))  {
      return;
    } else {
      snackBar = SnackBar( content: Text(''), action: SnackBarAction( label:'Clear Saved Data', onPressed: clearLoginData,),duration: Duration(seconds: 5),);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /**
   * Saves fields in encryptedSharedPreferences
   */
  void saveData(){
    var arrivalCity = _controllerDepartureCity.value.text;//
    var destinationCity = _controllerDestinationCity.value.text;//

    //savedData is EncryptedSharedPreferences
    savedData.setString("arrivalCity", arrivalCity);//variable name
    savedData.setString("destinationCity", destinationCity);//variable name
    //Navigator.pop(context);
  }

  /**
   * Clears the fields and removes encryptedSharedPreferences
   */
  void clearLoginData() {
    _controllerDepartureCity.text = "";
    _controllerDepartureCity.text = "";
    _controllerDestinationCity.text = "";
    _controllerDestinationCity.text = "";
    savedData.remove("arrivalCity");
    savedData.remove("destinationCity");
  }

  /**
   * Displays an alert dialog with a custom error message
   * @param context The BuildContext in which the dialogs should be displayed
   * @param message The message to display
   */
  void showErrorMessage(BuildContext context, String message) {
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Fields are empty'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );

    });

  }

  /**
   * Checks if the vields are not empty, and the departure date is before arrival date
   * @return true if fields are valid, false othewrise
   */
  bool fieldsAreValid(){
    bool valid = true;
    bool thereIsDepartureTime = false;
    bool thereIsArrivalTime = false;
    var message = "Some elements are missing or invalid:\n";
    if (_controllerDepartureCity.value.text == "" || _controllerDepartureCity.value.text == null ){
      message += "Departure city\n";
      valid = false;
    }
    if (_controllerDestinationCity.value.text == "" || _controllerDestinationCity.value.text == null ){
      message += "Destination city\n";
      valid = false;
    }
    if (_dateTimeControllerDeparture.value.text == "" || _dateTimeControllerDeparture.value.text == null ){
      message += "Departure time\n";
      thereIsDepartureTime = true;
      valid = false;
    }
    if (_dateTimeControllerArrival.value.text == "" || _dateTimeControllerArrival.value.text == null ){
      message += "Arrival time\n";
      thereIsArrivalTime = true;
      valid = false;
    }

    /*
    if (thereIsArrivalTime && thereIsDepartureTime){
      DateTime departureTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerDeparture.text);
      DateTime arrivalTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerArrival.text);

      if (arrivalTime.isBefore(departureTime)) {
        message += "Arrival time cannot be before departure time\n";
        valid = false;
      }
    }
     */

    showErrorMessage(context, message);
    return valid;
  }


  /**
   * Add a filgth to the list, the database and saves departure and arrival city into EncryptedSharedPreferences
   */
  void addFlight() {
    setState(() {
      final DateTime departureTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerDeparture.text);
      final DateTime arrivalTime = DateFormat('yyyy-MM-dd HH:mm').parse(_dateTimeControllerArrival.text);

      var newFlight = Flight(Flight.ID++, _controllerDepartureCity.value.text, _controllerDestinationCity.value.text, departureTime, arrivalTime);

      flightDAO.insertFlight(newFlight);
      saveData();

      Navigator.pushNamed(context, '/flights');
    });
  }

  void showUsageInfo(BuildContext contex){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('1. Click a field to insert data.'),
                Text('2. Make sure to fill all the fields.'),
                Text('3. Use \'BACK\' button to abort and return to the previous page.'),
                Text('4. Use \'ADD FLIGHT\' button to add a flight and return to the previous page.'),
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

  @override
  void initState() {
    super.initState();

    _controllerDepartureCity = TextEditingController();
    _controllerDestinationCity = TextEditingController();
    _dateTimeControllerDeparture = TextEditingController();
    _dateTimeControllerArrival = TextEditingController();
    savedData = EncryptedSharedPreferences();

    savedData.getString("arrivalCity").then((unencryptedString) {
      if (unencryptedString != null) {
        _controllerDepartureCity.text = unencryptedString;
      }
    });

    savedData.getString("destinationCity").then((unencryptedString) {
      if (unencryptedString != null ) {
        _controllerDestinationCity.text = unencryptedString;
      }
    });

    Future.delayed(Duration(milliseconds: 500), () {
      checkFields();
    });

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
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Add new flight"),
        actions: [
          IconButton(onPressed: () {showUsageInfo(context);}, icon: Icon(Icons.info))
        ],
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
                  // ======= GO BACK BUTTON ========
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
                  //======= ADD FLIGHT BUTTON ========
                  ElevatedButton(
                  onPressed: (){
                    if (fieldsAreValid()){
                      addFlight();
                    }
                  },
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
