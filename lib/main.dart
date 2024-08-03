import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Airplane/AirplaneList.dart';
import 'AppLocalizations.dart';


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
    setState(() { locale = newLanguage; });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Translation support
      supportedLocales: [
        Locale("en", "CA"),
        Locale('fr', 'FR')
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      locale: locale,

      // Route definitions
      routes: {
        '/homePage': (context) => MyHomePage(title: 'Flight Manager Home Page'),
        '/airplane': (context) => AirplaneListPage(setLocale: (newLocale) {
          _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
          state?.changeLanguage(newLocale);
        }),
        // '/flights': (context) => FlightsPage(),
        // '/addFlight': (context) => AddFlight(),
        // '/customer': (context) => CustomersPage(setLocale: (newLocale) {
        //   _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
        //   state?.changeLanguage(newLocale);
        // }),
        // '/addCustomer': (context) => AddCustomer(setLocale: (newLocale) {
        //   _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
        //   state?.changeLanguage(newLocale);
        // }),
        // '/reservations': (context) => ReservationPage(),
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
