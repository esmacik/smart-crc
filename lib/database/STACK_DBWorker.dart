import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_crc/model/crc_card.dart';

abstract class STACK_DBWorker {

  static final STACK_DBWorker db = _SqfliteNotesDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(CRCCardStack stack){return db.create(stack);}

  /// Update the given note of this database.
  Future<void> update(CRCCardStack stack);

  /// Delete the specified note.
  Future<void> delete(int id){return db.delete(id);}

  /// Return the specified note, or null.
  Future<CRCCardStack> get(int id){return db.get(id);}

  /// Return all the notes of this database.
  Future<List<CRCCardStack>> getAll();

  //Future<List<String>> getAllTableNames();

}

class _SqfliteNotesDBWorker implements STACK_DBWorker {

  static const String DB_NAME = 'crc_cards.db';
  static const String TBL_NAME = 'stacks';
  static const String KEY_ID = '_id';
  static const String KEY_NAME = 'name';
  var _db;

  _SqfliteNotesDBWorker._();

  Future<Database> get database async => _db ??= await _init();

//   Future<List<String>> getAllTableNames() async {
// // you can use your initial name for dbClient
//     List<Map> maps =
//     await _db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');
//
//     List<String> tableNameList = [];
//     if (maps.length > 0) {
//       for (int i = 0; i < maps.length; i++) {
//         try {
//           print(maps[i]['name'].toString());
//         } catch (e) {
//         }
//       }
//     }return tableNameList;}

  @override
  Future<int> create(CRCCardStack stack) async {
    Database db = await database;
    int id = await db.rawInsert(
      "INSERT INTO $TBL_NAME ($KEY_NAME) "
        "VALUES (?)",
      [stack.name]
    );
    print("Added: $stack, num: $id");
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(CRCCardStack stack) async {
    Database db = await database;
    await db.update(TBL_NAME, _stackToMap(stack),
        where: "$KEY_ID = ?", whereArgs: [stack.id]);
  }

  @override
  Future<CRCCardStack> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    if (values.isEmpty) {
      return CRCCardStack.empty('Stack');
    } else {
      return _stackFromMap(values.first);
    }
  }

  @override
  Future<List<CRCCardStack>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _stackFromMap(m)).toList() : [];
  }

  CRCCardStack _stackFromMap(Map map) {
    return CRCCardStack.empty(map[KEY_NAME])
      ..id = map[KEY_ID];
  }

  Map<String, dynamic> _stackToMap(CRCCardStack stack) {
    return Map<String, dynamic>()
      ..[KEY_ID] = stack.id
      ..[KEY_NAME] = stack.name;
  }

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
      version: 1,
      onOpen: (db) {print('Stack DB opened.');},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
            "$KEY_ID INTEGER PRIMARY KEY,"
            "$KEY_NAME TEXT,"
            ");"
        );
      }
    );
  }
}