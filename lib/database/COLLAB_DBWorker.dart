import 'package:smart_crc/model/collaborator.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:sqflite/sqflite.dart';

abstract class COLLAB_DBWorker {

  static final COLLAB_DBWorker db = _SqfliteNotesDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(Collaborator c);

  /// Update the given note of this database.
  Future<void> update(Collaborator c);

  /// Delete the specified note.
  Future<void> delete(int id);

    /// Return the specified note, or null.
  Future<Collaborator> get(int id);

  /// Return all the notes of this database.
  Future<List<Collaborator>> getAll();
}

class _SqfliteNotesDBWorker implements COLLAB_DBWorker {

  static const String DB_NAME = 'crc_cards.db';
  static const String TBL_NAME = 'collaborators';

  static const String KEY_ID = '_id';
  static const String KEY_RESP = "respID";
  static const String KEY_COLLAB = "cardID";


  var _db;

  _SqfliteNotesDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  @override
  Future<int> create(Collaborator c) async {
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_RESP, $KEY_COLLAB) "
            "VALUES (?,?)",
        [c.respID, c.cardID]
    );
    print('Created collaborator' + id.toString());
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(Collaborator c) async {
    Database db = await database;
    await db.update(TBL_NAME, _collabToMap(c),
        where: "$KEY_ID = ?", whereArgs: [c.id]);
  }


  @override
  Future<Collaborator> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    if (values.isEmpty) {
      return Collaborator();
    } else {
      return _collabFromMap(values.first);
    }
  }

  @override
  Future<List<Collaborator>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _collabFromMap(m)).toList() : [];
  }

  Collaborator _collabFromMap(Map map) {
    return Collaborator()
      ..cardID = map[KEY_COLLAB]
      ..respID = map[KEY_RESP]
      ..id = map[KEY_ID];
  }

  Map<String, dynamic> _collabToMap(Collaborator c) {
    return Map<String, dynamic>()
      ..[KEY_ID] = c.id
      ..[KEY_COLLAB] = c.cardID
      ..[KEY_RESP] = c.respID;
  }

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
                  "$KEY_ID INTEGER PRIMARY KEY,"
                  "$KEY_COLLAB INTEGER,"
                  "$KEY_RESP INTEGER,"
                  "FOREIGN KEY($KEY_COLLAB) REFERENCES cards(_id) ON DELETE CASCADE ON UPDATE CASCADE,"
                  "FOREIGN KEY($KEY_RESP) REFERENCES responsibilities(_id) ON DELETE CASCADE ON UPDATE CASCADE"
                  ");"
          );
        }
    );
  }
}