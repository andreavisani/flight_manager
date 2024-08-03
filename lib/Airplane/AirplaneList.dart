import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'AirplaneDB.dart';
import 'AirplaneDAO.dart';
import 'Airplane.dart';
import '../AppLocalizations.dart';

class AirplaneListPage extends StatefulWidget {
  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  AirplaneDatabase? _database;
  final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _passengersController = TextEditingController();
  final _maxSpeedController = TextEditingController();
  final _rangeController = TextEditingController();
  int? _editingIndex;
  Airplane? _selectedAirplane;
  String _currentLocale = 'en_CA';

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadSavedData();
    _loadLocale();
  }

  Future<void> _initDatabase() async {
    try {
      final database = await $FloorAirplaneDatabase.databaseBuilder('airplane.db').build();
      setState(() {
        _database = database;
      });
    } catch (e) {
      print('Error initializing database: $e');
    }
  }



  Future<void> _loadSavedData() async {
    if (prefs != null) {
      _typeController.text = await prefs!.getString('type') ?? '';
      _passengersController.text = await prefs!.getString('passenger') ?? '';
      _maxSpeedController.text = await prefs!.getString('speed') ?? '';
      _rangeController.text = await prefs!.getString('range') ?? '';
    }
  }
  //
  // Future<void> _saveData() async {
  //   if (prefs != null) {
  //     await prefs!.setString('type', _typeController.text);
  //     await _prefs!.setString('passengers', _passengersController.text);
  //     await _prefs!.setString('maxSpeed', _maxSpeedController.text);
  //     await _prefs!.setString('range', _rangeController.text);
  //   }
  // }

  void _addOrUpdateAirplane() async {
    if (_database == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('db_not_initialized') ?? 'Database is not initialized yet.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final airplane = Airplane(
        id: _editingIndex ?? DateTime.now().millisecondsSinceEpoch,
        name: _typeController.text,
        passengers: int.parse(_passengersController.text),
        speed: double.parse(_maxSpeedController.text),
        distance: double.parse(_rangeController.text),
      );

      try {
        if (_editingIndex == null) {
          await _database!.airplaneDAO.insertAirplane(airplane);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.translate('airplane_added') ?? 'Airplane added successfully.')),
          );
        } else {
          await _database!.airplaneDAO.updateAirplane(airplane);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.translate('airplane_updated') ?? 'Airplane updated successfully.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.translate('error') ?? 'Error: $e')),
        );
      }
      setState(() {
        _typeController.clear();
        _passengersController.clear();
        _maxSpeedController.clear();
        _rangeController.clear();
        _editingIndex = null;
        _selectedAirplane = null;
      });

      // await _saveData();
    }
  }

  void _editAirplane(Airplane airplane) {
    setState(() {
      _typeController.text = airplane.name;
      _passengersController.text = airplane.passengers.toString();
      _maxSpeedController.text = airplane.speed.toString();
      _rangeController.text = airplane.distance.toString();
      _editingIndex = airplane.id;
      _selectedAirplane = airplane;
    });
  }

  void _deleteAirplane(int id) async {
    if (_database == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('db_not_initialized') ?? 'Database is not initialized yet.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('confirm_deletion') ?? 'Confirm Deletion'),
          content: Text(AppLocalizations.of(context)?.translate('delete_confirmation') ?? 'Are you sure you want to delete this airplane?'),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _database!.airplaneDAO.deleteAirplane(Airplane(id: id, name: '', passengers: 0, speed: 0, distance: 0));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.translate('airplane_deleted') ?? 'Airplane deleted successfully.')),
                  );
                  setState(() {
                    _selectedAirplane = null;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.translate('error') ?? 'Error deleting airplane: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('instructions') ?? 'Instructions'),
          content: Text(AppLocalizations.of(context)?.translate('instructions_content') ?? '1. Use the form to add or update airplane details.\n'
              '2. Use the list to view, edit, or delete airplanes.\n'
              '3. The details of the selected airplane will be displayed on the right (on larger screens).'),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(String locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
    MyApp.setLocale(context, Locale(locale.split('_')[0], locale.split('_')[1]));
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocale = prefs.getString('locale') ?? 'en_CA';
    });
    MyApp.setLocale(context, Locale(_currentLocale.split('_')[0], _currentLocale.split('_')[1]));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('airplane_list') ?? 'Airplane List'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'en_CA',
                  child: Text(AppLocalizations.of(context)?.translate('english') ?? 'English'),
                ),
                PopupMenuItem(
                  value: 'fr_FR',
                  child: Text(AppLocalizations.of(context)?.translate('french') ?? 'French'),
                ),
              ];
            },
            icon: Icon(Icons.language),
          ),
        ],
      ),
      body: _database == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('name') ?? 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)?.translate('enter_name') ?? 'Please enter the airplane name';
                      }
                      return null;
                    },onChanged: (value) {
                    prefs.setString('type', value);
                  },
                  ),
                  TextFormField(
                    controller: _passengersController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('passengers') ?? 'Passengers'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)?.translate('enter_passengers') ?? 'Please enter the number of passengers';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      prefs.setString('passenger', value);
                    },
                  ),
                  TextFormField(
                    controller: _maxSpeedController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('max_speed') ?? 'Max Speed'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)?.translate('enter_max_speed') ?? 'Please enter the maximum speed';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      prefs.setString('speed', value);
                    },
                  ),
                  TextFormField(
                    controller: _rangeController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('range') ?? 'Range'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)?.translate('enter_range') ?? 'Please enter the range';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      prefs.setString('range', value);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addOrUpdateAirplane,
                    child: Text(AppLocalizations.of(context)?.translate(_editingIndex == null ? 'Save' : 'Update') ?? (_editingIndex == null ? 'Save' : 'Update')),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Airplane>>(
              future: _database!.airplaneDAO.findAllAirplanes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(AppLocalizations.of(context)?.translate('error_loading_data') ?? 'Error loading data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)?.translate('no_airplanes') ?? 'No airplanes available'));
                } else {
                  final airplanes = snapshot.data!;
                  return ListView.builder(
                    itemCount: airplanes.length,
                    itemBuilder: (context, index) {
                      final airplane = airplanes[index];
                      return ListTile(
                        title: Text(airplane.name),
                        subtitle: Text('${airplane.passengers} ${AppLocalizations.of(context)?.translate('passengers') ?? 'Passengers'}'),
                        onTap: () => _editAirplane(airplane),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteAirplane(airplane.id),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInstructions,
        child: Icon(Icons.help_outline),
      ),
    );
  }
}
