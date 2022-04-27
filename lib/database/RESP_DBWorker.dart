import 'package:smart_crc/model/crc_card.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_crc/model/responsibility.dart';

abstract class RESP_DBWorker {

  static final RESP_DBWorker db = _SqfliteNotesDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(Responsibility r){return db.create(r);}

  /// Update the given note of this database.
  Future<void> update(Responsibility r);

  /// Delete the specified note.
  Future<void> delete(int id){return db.delete(id);}

  /// Return the specified note, or null.
  Future<Responsibility> get(int id){return db.get(id);}

  /// Return all the notes of this database.
  Future<List<Responsibility>> getAll();

  Future<List<Responsibility>> getAllForCard(int cardID);

  }

class _SqfliteNotesDBWorker implements RESP_DBWorker {

  static const String DB_NAME = 'crc_cards.db';
  static const String TBL_NAME = 'responsibilities';

  static const String KEY_ID = '_id';
  static const String KEY_NAME = 'responsibility';
  static const String KEY_PARENT_CARD_ID = "cardID";

  var _db;

  _SqfliteNotesDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  @override
  Future<int> create(Responsibility r) async {
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_NAME, $KEY_PARENT_CARD_ID) "
            "VALUES (?, ?)",
        [r.name, r.parentCardId]
    );
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(Responsibility r) async {
    Database db = await database;
    await db.update(TBL_NAME, _respToMap(r),
        where: "$KEY_ID = ?", whereArgs: [r.id]);
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
  Future<List<Responsibility>> getAllForCard(int cardID) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_PARENT_CARD_ID = ?", whereArgs: [cardID]);
    return values.isNotEmpty ? values.map((m) => _respFromMap(m)).toList() : [];
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
      ..id = map[KEY_ID]
      ..parentCardId = map[KEY_PARENT_CARD_ID];
  }

  Map<String, dynamic> _respToMap(Responsibility r) {
    return Map<String, dynamic>()
      ..[KEY_ID] = r.id
      ..[KEY_NAME] = r.name
      ..[KEY_PARENT_CARD_ID] = r.parentCardId;
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
                  "$KEY_PARENT_CARD_ID INTEGER,"
                  "FOREIGN KEY($KEY_PARENT_CARD_ID) REFERENCES cards(_id) ON DELETE CASCADE"
                  ");"
          );
        }
    );
  }
}