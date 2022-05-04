import 'package:smart_crc/model/crc_card.dart';
import 'base_model.dart';

StackModel stackModel = StackModel();


class CRCCardStack {
  late int id;
  String name;
  final List<CRCCard> _cards = List.empty(growable: true);

  CRCCardStack.empty(this.name);

  CRCCardStack.fromMap(Map<String, dynamic> map):
    name = map['name'],
    id = map['id'] {
    _cards.addAll((map['cards'] as List<Map<String, dynamic>>).map((cardMap) => CRCCard.fromMap(cardMap)));
  }

  Map<String, dynamic> toMap() => {
    'type': 'stack',
    'id': id,
    'name': name,
    'cards': _cards.map((card) => card.toMap()).toList()
  };

  CRCCardStack(this.name, Iterable<CRCCard> cards) {
    _cards.addAll(cards);
  }

  CRCCard getCard(int index) => _cards.elementAt(index);

  int get numCards => _cards.length;

  List<CRCCard> get cards => _cards;

  void addCard(CRCCard card) {
    card.parentStack = this;
    cards.add(card);
  }

  void addAllCards(Iterable<CRCCard> cards) {
    for (CRCCard card in cards) {
      _cards.add(card);
      card.parentStack = this;
    }
  }

  void removeCard(int index) {
    //CRC_DBWorker.db.delete(_cards.elementAt(index).id);
    _cards.removeAt(index);
  }

}

class StackModel extends BaseModel<CRCCardStack> {
  var _stackIndex = 0;

  int get stackIndex => _stackIndex;

  void set stackIndex(int stackIndex) {
    _stackIndex = stackIndex;
    notifyListeners();
  }

  List<CRCCardStack> get cardList => entityList;

  set stackList(List<CRCCardStack> value) {
    entityList = value;
  }

  List<CRCCardStack> entityList = [];

  var _entityBeingEdited;

  void setStackIndex(int stackIndex) {
    this.stackIndex = stackIndex;
    notifyListeners();
  }

  get stackBeingEdited => _entityBeingEdited;

  set stackBeingEdited(value) {
    _entityBeingEdited = value;
  }

}