import 'package:flight_manager/Flight.dart';
import 'package:flight_manager/FlightDAO.dart';
import 'package:flight_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'AppLocalizations.dart';

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

  /**
   * Displays an alert dialog with instructions
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
                Text(AppLocalizations.of(context)!.translate('add_flight_instruction1')!),
                Text(AppLocalizations.of(context)!.translate('add_flight_instruction2')!),
                Text(AppLocalizations.of(context)!.translate('add_flight_instruction3')!),
                Text(AppLocalizations.of(context)!.translate('add_flight_instruction4')!),
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
   * Displays and alert dialog that offers the opportunity to switch language
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
              child: Text('Italian'),
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

  @override
  void initState() {
    super.initState();

    ///Controller for departure city
    _controllerDepartureCity = TextEditingController();
    ///Controller for destination city
    _controllerDestinationCity = TextEditingController();
    ///Controller for departure time
    _dateTimeControllerDeparture = TextEditingController();
    ///Controller for arrival time
    _dateTimeControllerArrival = TextEditingController();
    ///EncriptedSharedPreferences
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
        title: Text(AppLocalizations.of(context)!.translate('add_new_flight')!),
        actions: [
          IconButton(onPressed: () {showUsageInfo(context);}, icon: Icon(Icons.info)),
          IconButton(onPressed: () {showLanguageInfo(context);}, icon: Icon(Icons.language)),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.translate('add_new_flight')!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controllerDepartureCity,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate('departure_city')!,
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.translate('departure_city')!,
                prefixIcon: Icon(Icons.flight_takeoff, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controllerDestinationCity,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate('destination_city')!,
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.translate('destination_city')!,
                prefixIcon: Icon(Icons.flight_land, color: Colors.blueAccent),
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
                prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
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
                    child: Text(AppLocalizations.of(context)!.translate('back')!, style: TextStyle(color: Colors.white),),
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
                  child: Text(AppLocalizations.of(context)!.translate('add_flight')!, style: TextStyle(color: Colors.white),),

                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}
