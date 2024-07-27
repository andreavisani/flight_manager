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

  FlightDAO? _GetDaoInstance;

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

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  FlightDAO get GetDao {
    return _GetDaoInstance ??= _$FlightDAO(database, changeListener);
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

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
