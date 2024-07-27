import 'package:flutter/material.dart';
import 'AddAirplane.dart';
import 'Airplane.dart'; // Import the AddAirplane widget

class AirplanesList extends StatefulWidget {
  @override
  _AirplanesListState createState() => _AirplanesListState();
}

class _AirplanesListState extends State<AirplanesList> {
  List<Airplane> airplanes = [];

  void _addAirplane(Airplane airplane) {
    setState(() {
      airplanes.add(airplane);
    });
  }

  void _updateAirplane(int index, Airplane airplane) {
    setState(() {
      airplanes[index] = airplane;
    });
  }

  void _deleteAirplane(int index) {
    setState(() {
      airplanes.removeAt(index);
    });
  }

  void _navigateToAddAirplanePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAirplane()),
    );

    if (result != null && result is Airplane) {
      _addAirplane(result);
    }
  }

  void _navigateToUpdateAirplanePage(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAirplane(airplane: airplanes[index])),
    );

    if (result != null && result is Airplane) {
      _updateAirplane(index, result);
    }
  }

  void _viewAirplaneDetails(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Airplane Details'),
        content: Text(
          'Type: ${airplanes[index].type}\n'
              'Passengers: ${airplanes[index].passengers}\n'
              'Max Speed: ${airplanes[index].maxSpeed}\n'
              'Range: ${airplanes[index].range}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Airplane List')),
      body: ListView.builder(
        itemCount: airplanes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(airplanes[index].type),
            onTap: () => _viewAirplaneDetails(index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _navigateToUpdateAirplanePage(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAirplane(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAirplanePage,
        child: Icon(Icons.add),
      ),
    );
  }
}
