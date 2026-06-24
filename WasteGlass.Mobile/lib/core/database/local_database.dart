import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/models/collection_record_model.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'waste_glass.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trip_cache (
        tripId INTEGER PRIMARY KEY,
        tripDate TEXT NOT NULL,
        totalRouteDistanceKm REAL NOT NULL,
        remainingStops INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE local_trip_stops (
        stopId INTEGER PRIMARY KEY,
        tripId INTEGER NOT NULL,
        stopOrder INTEGER NOT NULL,
        supplierId INTEGER NOT NULL,
        supplierCode TEXT NOT NULL,
        supplierName TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        expectedKg REAL NOT NULL,
        status TEXT NOT NULL,
        distanceFromPreviousKm REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE local_collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER,
        supplierCode TEXT,
        clearGlassKg REAL,
        colouredGlassKg REAL,
        totalKg REAL,
        condition TEXT,
        collectedAt TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS trip_cache (
          tripId INTEGER PRIMARY KEY,
          tripDate TEXT NOT NULL,
          totalRouteDistanceKm REAL NOT NULL,
          remainingStops INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS local_trip_stops (
          stopId INTEGER PRIMARY KEY,
          tripId INTEGER NOT NULL,
          stopOrder INTEGER NOT NULL,
          supplierId INTEGER NOT NULL,
          supplierCode TEXT NOT NULL,
          supplierName TEXT NOT NULL,
          address TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          expectedKg REAL NOT NULL,
          status TEXT NOT NULL,
          distanceFromPreviousKm REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS local_collections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tripId INTEGER,
          supplierCode TEXT,
          clearGlassKg REAL,
          colouredGlassKg REAL,
          totalKg REAL,
          condition TEXT,
          collectedAt TEXT,
          isSynced INTEGER DEFAULT 0
        )
      ''');
    }
  }

  Future<void> replaceTrip(
    Map<String, dynamic> trip,
    List<Map<String, dynamic>> stops,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('trip_cache');
      await txn.delete('local_trip_stops');
      await txn.insert('trip_cache', trip);
      for (final stop in stops) {
        await txn.insert('local_trip_stops', stop);
      }
    });
  }

  Future<Map<String, dynamic>?> getCachedTrip() async {
    final db = await database;
    final rows = await db.query('trip_cache', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getCachedStops() async {
    final db = await database;
    return db.query('local_trip_stops', orderBy: 'stopOrder ASC');
  }

  Future<int> insertCollection(CollectionRecordModel record) async {
    final db = await database;
    return db.insert('local_collections', record.toDb());
  }

  Future<List<CollectionRecordModel>> getUnsyncedCollections() async {
    final db = await database;
    final rows = await db.query(
      'local_collections',
      where: 'isSynced = 0',
      orderBy: 'collectedAt ASC',
    );
    return rows.map(CollectionRecordModel.fromDb).toList();
  }

  Future<List<CollectionRecordModel>> getAllCollections() async {
    final db = await database;
    final rows = await db.query(
      'local_collections',
      orderBy: 'collectedAt ASC',
    );
    return rows.map(CollectionRecordModel.fromDb).toList();
  }

  Future<void> markAsSyncedBySupplierCode(
    String supplierCode,
    int tripId,
  ) async {
    final db = await database;
    await db.update(
      'local_collections',
      {'isSynced': 1},
      where: 'supplierCode = ? AND tripId = ?',
      whereArgs: [supplierCode, tripId],
    );
  }

  Future<void> markAllSynced() async {
    final db = await database;
    await db.update(
      'local_collections',
      {'isSynced': 1},
      where: 'isSynced = 0',
    );
  }

  Future<void> clearSyncedRecords() async {
    final db = await database;
    await db.delete(
      'local_collections',
      where: 'isSynced = 1',
    );
  }

  Future<bool> hasLocalRecordForSupplier(
    String supplierCode,
    int tripId,
  ) async {
    final db = await database;
    final rows = await db.query(
      'local_collections',
      columns: ['id'],
      where: 'supplierCode = ? AND tripId = ?',
      whereArgs: [supplierCode, tripId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> updateStopStatus(String supplierCode, String status) async {
    final db = await database;
    await db.update(
      'local_trip_stops',
      {'status': status},
      where: 'supplierCode = ?',
      whereArgs: [supplierCode],
    );
  }

  Future<void> markStopCollectedAndAdvance(String supplierCode) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'local_trip_stops',
        {'status': 'Collected'},
        where: 'supplierCode = ?',
        whereArgs: [supplierCode],
      );

      final nextRows = await txn.query(
        'local_trip_stops',
        where: 'status = ?',
        whereArgs: ['Pending'],
        orderBy: 'stopOrder ASC',
        limit: 1,
      );

      if (nextRows.isNotEmpty) {
        await txn.update(
          'local_trip_stops',
          {'status': 'Next'},
          where: 'stopId = ?',
          whereArgs: [nextRows.first['stopId']],
        );
      }
    });
  }
}
