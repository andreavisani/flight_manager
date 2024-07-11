import 'package:flight_manager/main.dart';
import 'package:flutter/material.dart';


class FlightsPage extends StatefulWidget {
  @override
  State<FlightsPage> createState() {
    return PersonalInfoState();
  }
}

class PersonalInfoState extends State<FlightsPage> {

  @override
  void initState() {
    super.initState();

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


          ],
        ),
      ),
    );
  }
}
