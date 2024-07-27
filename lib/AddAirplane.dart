import 'package:flutter/material.dart';
import 'Airplane.dart'; // Import the Airplane class

class AddAirplane extends StatefulWidget {
  final Airplane? airplane;

  AddAirplane({this.airplane});

  @override
  _AddAirplaneState createState() => _AddAirplaneState();
}

class _AddAirplaneState extends State<AddAirplane> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _passengersController;
  late TextEditingController _maxSpeedController;
  late TextEditingController _rangeController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.airplane?.type ?? '');
    _passengersController = TextEditingController(text: widget.airplane?.passengers.toString() ?? '');
    _maxSpeedController = TextEditingController(text: widget.airplane?.maxSpeed.toString() ?? '');
    _rangeController = TextEditingController(text: widget.airplane?.range.toString() ?? '');
  }

  @override
  void dispose() {
    _typeController.dispose();
    _passengersController.dispose();
    _maxSpeedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newAirplane = Airplane(
        id: widget.airplane?.id ?? DateTime.now().millisecondsSinceEpoch, // Generate a new id if not present
        type: _typeController.text,
        passengers: int.parse(_passengersController.text),
        maxSpeed: double.parse(_maxSpeedController.text),
        range: double.parse(_rangeController.text),
      );
      Navigator.pop(context, newAirplane);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.airplane == null ? 'Add Airplane' : 'Update Airplane')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Airplane Type'),
                validator: (value) => value!.isEmpty ? 'Please enter airplane type' : null,
              ),
              TextFormField(
                controller: _passengersController,
                decoration: InputDecoration(labelText: 'Number of Passengers'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter number of passengers' : null,
              ),
              TextFormField(
                controller: _maxSpeedController,
                decoration: InputDecoration(labelText: 'Max Speed'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter max speed' : null,
              ),
              TextFormField(
                controller: _rangeController,
                decoration: InputDecoration(labelText: 'Range'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter range' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.airplane == null ? 'Add Airplane' : 'Update Airplane'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
