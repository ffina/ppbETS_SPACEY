import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/entry_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spacey.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id            TEXT PRIMARY KEY,
        userId        TEXT NOT NULL,
        title         TEXT NOT NULL,
        note          TEXT,
        category      TEXT,
        mood          TEXT,
        latitude      REAL,
        longitude     REAL,
        locationName  TEXT,
        localImagePath TEXT,
        remoteImageUrl TEXT,
        createdAt     TEXT NOT NULL,
        isSynced      INTEGER DEFAULT 0
      )
    ''');
  }

  // CREATE
  Future<void> insertEntry(EntryModel entry) async {
    final db = await database;
    await db.insert('entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // READ ALL (by user)
  Future<List<EntryModel>> getEntriesByUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => EntryModel.fromMap(m)).toList();
  }

  // READ ONE
  Future<EntryModel?> getEntryById(String id) async {
    final db = await database;
    final maps = await db.query('entries', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return EntryModel.fromMap(maps.first);
  }

  // UPDATE
  Future<void> updateEntry(EntryModel entry) async {
    final db = await database;
    await db.update('entries', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  // DELETE
  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  // GET UNSYNCED
  Future<List<EntryModel>> getUnsyncedEntries() async {
    final db = await database;
    final maps = await db.query('entries', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((m) => EntryModel.fromMap(m)).toList();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}