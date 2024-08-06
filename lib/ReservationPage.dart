import 'Database.dart';
import 'ReservationDetail.dart';
import 'Reservation.dart';
import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'LanguageSelectionDialog.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Reservation>? entities;
  bool isChildViewOpen = false;
  Reservation? selectedEntity;
  Locale _locale = Locale('en');

  void loadData() async {
    final db =  await $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build();
    final d = await db.ReservationDao.selectEverything();
    setState(() {
      entities = d;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void selectEntity(Reservation? entity) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 750) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReservationDetail(
            isChildView: false,
            entity: entity,
            onSave: saveReservation,
            onDelete: deleteReservation,
            onClose: ([String? message]) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message ?? AppLocalizations.of(context)?.translate('action_completed') ?? "Action completed")));
            },
          ),
        ),
      );
      return;
    }
    setState(() {
      selectedEntity = entity;
      isChildViewOpen = true;
    });
  }

  void newReservation() {
    final width = MediaQuery.of(context).size.width;
    if (width <= 750) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReservationDetail(
            isChildView: false,
            entity: null,
            onSave: saveReservation,
            onDelete: deleteReservation,
          ),
        ),
      );
      return;
    }
    setState(() {
      selectedEntity = null;
      isChildViewOpen = true;
    });
  }

  Future<void> saveReservation(Reservation entity) async {
    try {
      final db = await $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build();

      if (entity.id == null) {
        final id = await db.ReservationDao.insertReservation(entity);
        setState(() {
          if (entities == null) {
            entities = [];
          }
          entities!.add(entity.setId(id));
        });
      } else {
        await db.ReservationDao.updateReservation(entity);
        setState(() {
          entities = entities!.map((e) => e.id == entity.id ? entity : e).toList();
        });
      }
    } catch (e) {
      // Handle errors, such as database or insertion/update failures
      print("Error saving reservation: $e");
    }
  }

  void deleteReservation(Reservation entity) async {
    final db = await $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build();
    await db.ReservationDao.deleteReservation(entity);
    setState(() {
      entities = entities!.where((e) => e.id != entity.id).toList();
    });
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    AppLocalizations.delegate.load(locale).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _locale,
        child: Builder(
        builder: (BuildContext context) {
            return Row(
              children: [
                Flexible(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(AppLocalizations.of(context)?.translate('reservation_list') ?? 'Reservation List', style: TextStyle(fontWeight: FontWeight.bold),),
                      backgroundColor: Colors.blueAccent,
                      actions: [
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(AppLocalizations.of(context)?.translate('information') ?? 'Information', style: TextStyle(fontWeight: FontWeight.bold),),
                                content: Text(AppLocalizations.of(context)?.translate('use_plus_button') ?? 'Use the "+" button to add a new reservation.', style: TextStyle(fontWeight: FontWeight.bold),),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.language),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => LanguageSelectionDialog(
                                changeLanguage: _changeLanguage,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: newReservation,
                      child: const Icon(Icons.add),
                      backgroundColor: Colors.blueAccent,
                    ),
                    body: (entities?.length ?? 0) == 0
                        ? Center(
                      child: Text(
                        AppLocalizations.of(context)?.translate('no_reservations') ?? "There are no reservations",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: entities?.length ?? 0,
                      itemBuilder: (context, index) => Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            entities![index].reservationName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Date: ${entities![index].reservationDate}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Icon(Icons.flight, color: Colors.blueAccent),
                          onTap: () {
                            selectEntity(entities![index]);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 750 && isChildViewOpen)
                  Flexible(
                    child: ReservationDetail(
                      isChildView: true,
                      entity: selectedEntity,
                      onSave: saveReservation,
                      onDelete: deleteReservation,
                      onClose: ([String? message]) {
                        setState(() {
                          isChildViewOpen = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message ?? AppLocalizations.of(context)?.translate('action_completed') ?? "Action completed")));
                      },
                    ),
                  )
              ],
            );
        },
        ),
    );
  }}
