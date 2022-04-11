import 'package:sqflite/sqflite.dart';
import 'package:smart_crc/model/crc_card.dart';

abstract class CRC_DBWorker {

  static final CRC_DBWorker db = _SqfliteNotesDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(CRCCard card);

  /// Update the given note of this database.
  Future<void> update(CRCCard card);

  /// Delete the specified note.
  Future<void> delete(int id);

  /// Return the specified note, or null.
  Future<CRCCard> get(int id);

  /// Return all the notes of this database.
  Future<List<CRCCard>> getAll();
}

class _SqfliteNotesDBWorker implements CRC_DBWorker {

  static const String DB_NAME = 'crc_cards.db';
  static const String TBL_NAME = 'cards';
  static const String KEY_ID = '_id';
  static const String KEY_NAME = 'className';
  static const String KEY_NOTE = 'note';

  var _db;

  _SqfliteNotesDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  @override
  Future<int> create(CRCCard card) async {
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_NAME, $KEY_NOTE) "
            "VALUES (?, ?)",
        [card.className, card.note]
    );
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(CRCCard card) async {
    Database db = await database;
    await db.update(TBL_NAME, _cardToMap(card),
        where: "$KEY_ID = ?", whereArgs: [card.id]);
  }

  @override
  Future<CRCCard> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    if (values.isEmpty) {
      return CRCCard.blank();
    } else {
      return _cardFromMap(values.first);
    }
  }

  @override
  Future<List<CRCCard>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _cardFromMap(m)).toList() : [];
  }

  CRCCard _cardFromMap(Map map) {
    return CRCCard.blank()
      ..className = map[KEY_NAME]
      ..id = map[KEY_ID]
      ..note = map[KEY_NOTE];
  }

  Map<String, dynamic> _cardToMap(CRCCard card) {
    return Map<String, dynamic>()
      ..[KEY_ID] = card.id
      ..[KEY_NAME] = card.className
      ..[KEY_NOTE] = card.note;
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
                  "$KEY_NOTE TEXT,"
                  ");"
          );
        }
    );
  }
}