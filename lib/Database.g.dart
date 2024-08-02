// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $FlightManagerDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $FlightManagerDatabaseBuilderContract addMigrations(
      List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $FlightManagerDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<FlightManagerDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorFlightManagerDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $FlightManagerDatabaseBuilderContract databaseBuilder(String name) =>
      _$FlightManagerDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $FlightManagerDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$FlightManagerDatabaseBuilder(null);
}

class _$FlightManagerDatabaseBuilder
    implements $FlightManagerDatabaseBuilderContract {
  _$FlightManagerDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $FlightManagerDatabaseBuilderContract addMigrations(
      List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $FlightManagerDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<FlightManagerDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$FlightManagerDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlightManagerDatabase extends FlightManagerDatabase {
  _$FlightManagerDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CustomerDAO? _customerDAOInstance;

  FlightDAO? _GetDaoInstance;

  ReservationDAO? _ReservationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Flight` (`id` INTEGER NOT NULL, `departureTime` INTEGER NOT NULL, `arrivalTime` INTEGER NOT NULL, `departureCity` TEXT NOT NULL, `destinationCity` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`id` INTEGER NOT NULL, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `birthday` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Reservation` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` INTEGER NOT NULL, `flightId` INTEGER NOT NULL, `reservationDate` TEXT NOT NULL, `reservationName` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CustomerDAO get customerDAO {
    return _customerDAOInstance ??= _$CustomerDAO(database, changeListener);
  }

  @override
  FlightDAO get GetDao {
    return _GetDaoInstance ??= _$FlightDAO(database, changeListener);
  }

  @override
  ReservationDAO get ReservationDao {
    return _ReservationDaoInstance ??=
        _$ReservationDAO(database, changeListener);
  }
}

class _$CustomerDAO extends CustomerDAO {
  _$CustomerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': _dateTimeConverter.encode(item.birthday)
                }),
        _customerUpdateAdapter = UpdateAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': _dateTimeConverter.encode(item.birthday)
                }),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': _dateTimeConverter.encode(item.birthday)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final UpdateAdapter<Customer> _customerUpdateAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> selectEverything() async {
    return _queryAdapter.queryList('SELECT * FROM Customer',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int,
            row['firstName'] as String,
            row['lastName'] as String,
            row['address'] as String,
            _dateTimeConverter.decode(row['birthday'] as int)));
  }

  @override
  Future<int> insertCustomer(Customer customer) {
    return _customerInsertionAdapter.insertAndReturnId(
        customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _customerUpdateAdapter.update(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(Customer customer) async {
    await _customerDeletionAdapter.delete(customer);
  }
}

class _$FlightDAO extends FlightDAO {
  _$FlightDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _flightInsertionAdapter = InsertionAdapter(
            database,
            'Flight',
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureTime':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrivalTime': _dateTimeConverter.encode(item.arrivalTime),
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity
                }),
        _flightUpdateAdapter = UpdateAdapter(
            database,
            'Flight',
            ['id'],
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureTime':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrivalTime': _dateTimeConverter.encode(item.arrivalTime),
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity
                }),
        _flightDeletionAdapter = DeletionAdapter(
            database,
            'Flight',
            ['id'],
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureTime':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrivalTime': _dateTimeConverter.encode(item.arrivalTime),
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Flight> _flightInsertionAdapter;

  final UpdateAdapter<Flight> _flightUpdateAdapter;

  final DeletionAdapter<Flight> _flightDeletionAdapter;

  @override
  Future<List<Flight>> selectEverything() async {
    return _queryAdapter.queryList('SELECT * FROM Flight',
        mapper: (Map<String, Object?> row) => Flight(
            row['id'] as int,
            row['departureCity'] as String,
            row['destinationCity'] as String,
            _dateTimeConverter.decode(row['departureTime'] as int),
            _dateTimeConverter.decode(row['arrivalTime'] as int)));
  }

  @override
  Future<void> insertFlight(Flight flight) async {
    await _flightInsertionAdapter.insert(flight, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlight(Flight flight) async {
    await _flightUpdateAdapter.update(flight, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteFlight(Flight flight) {
    return _flightDeletionAdapter.deleteAndReturnChangedRows(flight);
  }
}

class _$ReservationDAO extends ReservationDAO {
  _$ReservationDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'Reservation',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate': item.reservationDate,
                  'reservationName': item.reservationName
                }),
        _reservationUpdateAdapter = UpdateAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate': item.reservationDate,
                  'reservationName': item.reservationName
                }),
        _reservationDeletionAdapter = DeletionAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate': item.reservationDate,
                  'reservationName': item.reservationName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final UpdateAdapter<Reservation> _reservationUpdateAdapter;

  final DeletionAdapter<Reservation> _reservationDeletionAdapter;

  @override
  Future<List<Reservation>> selectEverything() async {
    return _queryAdapter.queryList('SELECT * FROM Reservation',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            reservationDate: row['reservationDate'] as String,
            reservationName: row['reservationName'] as String));
  }

  @override
  Future<Reservation?> getReservationById(int id) async {
    return _queryAdapter.query('SELECT * FROM Reservation WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            reservationDate: row['reservationDate'] as String,
            reservationName: row['reservationName'] as String),
        arguments: [id]);
  }

  @override
  Future<int> insertReservation(Reservation reservation) {
    return _reservationInsertionAdapter.insertAndReturnId(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    await _reservationUpdateAdapter.update(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteReservation(Reservation reservation) async {
    await _reservationDeletionAdapter.delete(reservation);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
