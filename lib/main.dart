import 'package:flight_manager/AddFlight.dart';
import 'package:flight_manager/AppLocalizations.dart';
import 'package:flight_manager/ReservationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'AddCustomer.dart';
import 'AppLocalizations.dart';
import 'package:flutter/rendering.dart';
import 'FlightsPage.dart';
import 'ReservationPage.dart';
import 'customerlist.dart';
import 'package:flight_manager/Airplane/AirplaneList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  var locale = Locale("en", "CA");

  void changeLanguage(Locale newLanguage) {
    setState(() {
      locale = newLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale("en", "CA"),
        Locale("it", "IT"),
        Locale('ne', 'NP'),
        Locale("en", "US"),
        Locale('fr', 'FR'),
        Locale('zh', 'TW'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,

      routes: {
        '/homePage': (context) => MyHomePage(title: 'Flight manager home page'),
        '/airplane': (context) => AirplaneListPage(),
        '/flights': (context) => FlightsPage(),
        '/addFlight': (context) => AddFlight(),
        '/customer': (context) => CustomersPage(setLocale: (newLocale) {
          _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
          state?.changeLanguage(newLocale);
        }),
        '/addCustomer': (context) => AddCustomer(setLocale: (newLocale) {
          _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
          state?.changeLanguage(newLocale);
        }),
        '/reservations': (context) => ReservationPage(),
      },
      title: 'Algonquin College Airlines',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Algonquin College Airlines Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // NO BACK ARROW
        backgroundColor: Colors.blue[900],
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            SizedBox(
              width: 200.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/flights');
                },
                child: Text("Flights"),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18.0),
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white, // Explicitly set the text color to white
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.0), //ADD SPACING

            // CUSTOMERS BUTTONS
            SizedBox(
              width: 200.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/customer');
                },
                child: Text("Customers"),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18.0),
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.0),

            // AIRPLANE BUTTON
            SizedBox(
              width: 200.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/airplane');
                },
                child: Text("Airplanes"),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18.0),
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0), // Spacing between buttons

            // RESERVATIONS BUTTON
            SizedBox(
              width: 200.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reservations');
                },
                child: Text("Reservations"),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18.0),
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
