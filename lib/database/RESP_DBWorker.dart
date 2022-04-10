import 'package:sqflite/sqflite.dart';
import 'package:smart_crc/model/responsibility.dart';

abstract class RESP_DBWorker {

  static final RESP_DBWorker db = _SqfliteNotesDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(Responsibility r);

  /// Update the given note of this database.
  Future<void> update(Responsibility r);

  /// Delete the specified note.
  Future<void> delete(int id);

  /// Return the specified note, or null.
  Future<Responsibility> get(int id);

  /// Return all the notes of this database.
  Future<List<Responsibility>> getAll();
}

class _SqfliteNotesDBWorker implements RESP_DBWorker {

  static const String DB_NAME = 'crc_cards.db';
  static const String TBL_NAME = 'responsibilities';

  static const String KEY_ID = '_id';
  static const String KEY_NAME = 'responsibility';
  static const String KEY_CARD = "cardID";

  var _db;

  _SqfliteNotesDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  @override
  Future<int> create(Responsibility r) async {
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_NAME) "
            "VALUES (?)",
        [r.name]
    );
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(Responsibility card) async {
    Database db = await database;
    await db.update(TBL_NAME, _respToMap(card),
        where: "$KEY_ID = ?", whereArgs: [card.id]);
  }

  @override
  Future<Responsibility> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    if (values.isEmpty) {
      return Responsibility();
    } else {
      return _respFromMap(values.first);
    }
  }

  @override
  Future<List<Responsibility>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _respFromMap(m)).toList() : [];
  }

  Responsibility _respFromMap(Map map) {
    return Responsibility()
      ..name = map[KEY_NAME]
      ..id = map[KEY_ID];
  }

  Map<String, dynamic> _respToMap(Responsibility r) {
    return Map<String, dynamic>()
      ..[KEY_ID] = r.id
      ..[KEY_NAME] = r.name;
  }

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
                  "$KEY_ID INTEGER PRIMARY KEY,"
                  "$KEY_NAME TEXT,"
                  "$KEY_CARD INTEGER,"
                  "FOREIGN KEY($KEY_CARD) REFERENCES cards(_id) ON DELETE CASCADE"
                  ");"
          );
        }
    );
  }
}