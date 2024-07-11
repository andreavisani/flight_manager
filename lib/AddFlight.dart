import 'package:flight_manager/main.dart';
import 'package:flutter/material.dart';


class AddFlight extends StatefulWidget {
  @override
  State<AddFlight> createState() {
    return AddFlightState();
  }
}

class AddFlightState extends State<AddFlight> {

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
        title: Text("Add new flight"),
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
