//
// import 'package:flight_manager/Customer.dart';
// import 'package:flight_manager/CustomerDAO.dart';
// import 'package:flight_manager/Flight.dart';
// import 'package:flight_manager/FlightDAO.dart';
// import 'package:flight_manager/Reservation.dart';
// import 'package:flight_manager/ReservationDAO.dart';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter/material.dart';
//
// import 'Database.dart';
//
//
// class ReservationPage extends StatefulWidget {
//   @override
//   State<ReservationPage> createState() => _ReservationPageState();
// }
//
//
// class _ReservationPageState extends State<ReservationPage> {
//   final TextEditingController reservationNameController = TextEditingController();
//   var customers = <Customer>[];
//   var flights = <Flight>[];
//   var reservations = <Reservation>[];
//
//   late CustomerDAO customerDAO;
//   Customer? selectedCustomerItem = null;
//
//   late FlightDAO flightDAO;
//   Flight? selectedFlightItem = null;
//
//   late ReservationDAO reservationDAO;
//   Reservation? selectedReservationItem = null;
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     $FloorFlightManagerDatabase.databaseBuilder('app_database.db').build().then((database) {
//       customerDAO = database.customerDAO;
//       flightDAO = database.GetDao;
//       reservationDAO = database.reservationDao;
//       //now you can query
//       customerDAO.selectEverything().then(  (listOfItems){
//         setState(() {
//           customers.addAll(listOfItems);
//         });
//
//       });
//       flightDAO.selectEverything().then(  (listOfItems){
//         setState(() {
//           flights.addAll(listOfItems);
//         });
//
//       });
//       reservationDAO.selectEverything().then(  (listOfItems){
//         setState(() {
//           reservations.addAll(listOfItems);
//         });
//
//       });
//     });
//
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text("Reservations"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 controller: reservationNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Reservation Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             DropdownButton<Customer>(
//               value: selectedCustomerItem,
//               onChanged: (Customer? newValue) {
//                 setState(() {
//                   selectedCustomerItem = newValue;
//                 });
//               },
//               items: customers.map<DropdownMenuItem<Customer>>((Customer customer) {
//                 return DropdownMenuItem<Customer>(
//                   value: customer,
//                   child: Text(customer.firstName),
//                 );
//               }).toList(),
//             ),
//             DropdownButton<Flight>(
//               value: selectedFlightItem,
//               onChanged: (Flight? newValue) {
//                 setState(() {
//                   selectedFlightItem = newValue;
//                 });
//               },
//               items: flights.map<DropdownMenuItem<Flight>>((Flight flight) {
//                 return DropdownMenuItem<Flight>(
//                   value: flight,
//                   child: Text("${flight.departureCity} to ${flight.destinationCity} at ${flight.departureTime}"),
//                 );
//               }).toList(),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final newReservation = Reservation(
//                   Reservation.ID++,
//                   reservationNameController.text,
//                   selectedCustomerItem!.id,
//                   selectedFlightItem!.id,
//                 );
//                 reservationDAO.insertReservation(newReservation).then((_) {
//                   setState(() {
//                     reservations.add(newReservation);
//                   });
//                   reservationNameController.clear();
//                 });
//               },
//               child: Text('Add Reservation'),
//             ),
//             SizedBox(
//               height: 300,
//               child: ListView.builder(
//                 itemCount: reservations.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(reservations[index].reservationName),
//                     subtitle: Text("${customers.firstWhere((c) => c.id == reservations[index].customerId).firstName} - ${flights.firstWhere((f) => f.id == reservations[index].flightId).departureCity} to ${flights.firstWhere((f) => f.id == reservations[index].flightId).destinationCity}"),
//                     onTap: () {
//                       showDialog(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: Text(reservations[index].reservationName),
//                           content: Text("Customer: ${customers.firstWhere((c) => c.id == reservations[index].customerId).firstName}\nFlight: ${flights.firstWhere((f) => f.id == reservations[index].flightId).departureCity} to ${flights.firstWhere((f) => f.id == reservations[index].flightId).destinationCity}"),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'Database.dart';
import 'ReservationDetail.dart';
import 'Reservation.dart';
import 'package:flutter/material.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Reservation>? entities;
  bool isChildViewOpen = false;
  Reservation? selectedEntity;

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
                  SnackBar(content: Text(message ?? "Action completed")));
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Reservation List Page'),
              actions: [
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('How to use'),
                        content: Text('Tap on a reservation to view details. Use the "+" button to add a new reservation.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: newReservation,
              child: const Icon(Icons.add),
            ),
            body: (entities?.length ?? 0) == 0
                ? const Center(
              child: Text("There are no reservations"),
            )
                : ListView.builder(
              itemCount: entities?.length ?? 0,
              itemBuilder: (context, index) => ListTile(
                title: Text(entities![index].reservationName),
                subtitle: Text('Date: ${entities![index].reservationDate}'),
                onTap: () {
                  selectEntity(entities![index]);
                },
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
                    SnackBar(content: Text(message ?? "Action completed")));
              },
            ),
          )
      ],
    );
  }
}
