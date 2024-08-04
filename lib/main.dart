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

class _MyAppState extends State<MyApp>{
  var locale = Locale("en", "CA");

  void changeLanguage(Locale newLanguage) {
    setState(() { locale = newLanguage; });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      //TRANSLATION
      supportedLocales: [
        Locale("en", "CA"),
        Locale("it", "IT"),
        Locale('ne', 'NP'),
        Locale("en", "US"),
        Locale('fr', 'FR')
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      //DEFAULT LANGUAGE OF THE APP (en, CA)
      locale: locale,



      //LIST OF ALL PAGES
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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/flights');
              },
              child: Text("Flights"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/customer');
              },
              child: Text("Customers"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/airplane');
              },
              child: Text("Airplanes"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reservations');
              },
              child: Text("Reservations"),
            ),

          ],
        ),
      ),
    );
  }
}