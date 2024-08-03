import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AirplaneDB.dart';
import 'AirplaneDAO.dart';
import 'Airplane.dart';
import '../AppLocalizations.dart';

class AirplaneListPage extends StatefulWidget {
  final Function(Locale) setLocale;

  AirplaneListPage({required this.setLocale});

  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  AirplaneDatabase? _database;
  late EncryptedSharedPreferences _prefs;
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _passengersController = TextEditingController();
  final _maxSpeedController = TextEditingController();
  final _rangeController = TextEditingController();
  int? _editingIndex;
  Airplane? _selectedAirplane;
  Locale _locale = const Locale('en', 'CA');

  @override
  void initState() {
    super.initState();
    _initDatabase();
    // _initPreferences();
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

  // Future<void> _initPreferences() async {
  //   try {
  //     _prefs = await EncryptedSharedPreferences.getInstance();
  //     await _loadSavedData();
  //   } catch (e) {
  //     print('Error initializing preferences: $e');
  //   }
  // }

  Future<void> _loadSavedData() async {
    _typeController.text = await _prefs.getString('type') ?? '';
    _passengersController.text = await _prefs.getString('passengers') ?? '';
    _maxSpeedController.text = await _prefs.getString('maxSpeed') ?? '';
    _rangeController.text = await _prefs.getString('range') ?? '';
  }

  Future<void> _saveData() async {
    await _prefs.setString('type', _typeController.text);
    await _prefs.setString('passengers', _passengersController.text);
    await _prefs.setString('maxSpeed', _maxSpeedController.text);
    await _prefs.setString('range', _rangeController.text);
  }

  void _addOrUpdateAirplane() async {
    if (_database == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('database_not_initialized')!)),
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
            SnackBar(content: Text(AppLocalizations.of(context)!.translate('airplane_added')!)),
          );
        } else {
          await _database!.airplaneDAO.updateAirplane(airplane);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.translate('airplane_updated')!)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.translate('error')}: $e')),
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

      await _saveData();
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
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('database_not_initialized')!)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('confirm_deletion')!),
          content: Text(AppLocalizations.of(context)!.translate('confirm_deletion_message')!),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('cancel')!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('delete')!),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _database!.airplaneDAO.deleteAirplane(Airplane(id: id, name: '', passengers: 0, speed: 0, distance: 0));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.translate('airplane_deleted')!)),
                  );
                  setState(() {
                    _selectedAirplane = null;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.translate('error')}: $e')),
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
          title: Text(AppLocalizations.of(context)!.translate('instructions')!),
          content: Text(AppLocalizations.of(context)!.translate('instructions_content')!),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('ok')!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    widget.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('airplane_list')!),
        actions: [
          OutlinedButton(
            onPressed: () {
              _changeLanguage(Locale("fr", "FR"));
            },
            child: Text(AppLocalizations.of(context)!.translate('switch_to_french')!),
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInstructions,
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
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('name')!),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.translate('please_enter_name');
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passengersController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('passengers')!),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.translate('please_enter_passengers');
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _maxSpeedController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('max_speed')!),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.translate('please_enter_max_speed');
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _rangeController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('range')!),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.translate('please_enter_range');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addOrUpdateAirplane,
                    child: Text(_editingIndex == null
                        ? AppLocalizations.of(context)!.translate('add_airplane')!
                        : AppLocalizations.of(context)!.translate('update_airplane')!),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Airplane>>(
              stream: _database?.airplaneDAO.findAllAirplanes().asStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(AppLocalizations.of(context)!.translate('error')!));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.translate('no_airplanes')!));
                } else {
                  final airplanes = snapshot.data!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isPhone = constraints.maxWidth < 600;
                      return Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: airplanes.length,
                              itemBuilder: (context, index) {
                                final airplane = airplanes[index];
                                return ListTile(
                                  title: Text(airplane.name),
                                  subtitle: Text(
                                      '${AppLocalizations.of(context)!.translate('passengers')}: ${airplane.passengers}, ${AppLocalizations.of(context)!.translate('speed')}: ${airplane.speed}, ${AppLocalizations.of(context)!.translate('distance')}: ${airplane.distance}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () => _editAirplane(airplane),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _deleteAirplane(airplane.id),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedAirplane = airplane;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          if (!isPhone)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.translate('airplane_details')!,
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                    SizedBox(height: 16),
                                    if (_selectedAirplane != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${AppLocalizations.of(context)!.translate('name')}: ${_selectedAirplane!.name}'),
                                          Text('${AppLocalizations.of(context)!.translate('passengers')}: ${_selectedAirplane!.passengers}'),
                                          Text('${AppLocalizations.of(context)!.translate('max_speed')}: ${_selectedAirplane!.speed}'),
                                          Text('${AppLocalizations.of(context)!.translate('range')}: ${_selectedAirplane!.distance}'),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
