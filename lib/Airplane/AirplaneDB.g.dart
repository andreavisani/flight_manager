// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AirplaneDB.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AirplaneDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AirplaneDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AirplaneDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AirplaneDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAirplaneDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AirplaneDatabaseBuilderContract databaseBuilder(String name) =>
      _$AirplaneDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AirplaneDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AirplaneDatabaseBuilder(null);
}

class _$AirplaneDatabaseBuilder implements $AirplaneDatabaseBuilderContract {
  _$AirplaneDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AirplaneDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AirplaneDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AirplaneDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AirplaneDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AirplaneDatabase extends AirplaneDatabase {
  _$AirplaneDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AirplaneDAO? _airplaneDAOInstance;

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
            'CREATE TABLE IF NOT EXISTS `Airplane` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `passengers` INTEGER NOT NULL, `speed` REAL NOT NULL, `distance` REAL NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AirplaneDAO get airplaneDAO {
    return _airplaneDAOInstance ??= _$AirplaneDAO(database, changeListener);
  }
}

class _$AirplaneDAO extends AirplaneDAO {
  _$AirplaneDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _airplaneInsertionAdapter = InsertionAdapter(
            database,
            'Airplane',
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'passengers': item.passengers,
                  'speed': item.speed,
                  'distance': item.distance
                },
            changeListener),
        _airplaneUpdateAdapter = UpdateAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'passengers': item.passengers,
                  'speed': item.speed,
                  'distance': item.distance
                },
            changeListener),
        _airplaneDeletionAdapter = DeletionAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'passengers': item.passengers,
                  'speed': item.speed,
                  'distance': item.distance
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Airplane> _airplaneInsertionAdapter;

  final UpdateAdapter<Airplane> _airplaneUpdateAdapter;

  final DeletionAdapter<Airplane> _airplaneDeletionAdapter;

  @override
  Future<List<Airplane>> findAllAirplanes() async {
    return _queryAdapter.queryList('SELECT * FROM Airplane',
        mapper: (Map<String, Object?> row) => Airplane(
            id: row['id'] as int,
            name: row['name'] as String,
            passengers: row['passengers'] as int,
            speed: row['speed'] as double,
            distance: row['distance'] as double));
  }

  @override
  Stream<Airplane?> findAirplane(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Airplane WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Airplane(
            id: row['id'] as int,
            name: row['name'] as String,
            passengers: row['passengers'] as int,
            speed: row['speed'] as double,
            distance: row['distance'] as double),
        arguments: [id],
        queryableName: 'Airplane',
        isView: false);
  }

  @override
  Future<void> insertAirplane(Airplane a) async {
    await _airplaneInsertionAdapter.insert(a, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAirplane(Airplane a) async {
    await _airplaneUpdateAdapter.update(a, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAirplane(Airplane a) async {
    await _airplaneDeletionAdapter.delete(a);
  }
}
