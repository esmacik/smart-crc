import 'package:smart_crc/database/CRC_DBWorker.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'base_model.dart';

StackModel stackModel = StackModel();


class CRCCardStack {
  var id;
  String name;
  final List<CRCCard> _cards = List.empty(growable: true);

  CRCCardStack.empty(this.name);

  CRCCardStack(this.name, Iterable<CRCCard> cards) {
    _cards.addAll(cards);
  }

  CRCCard getCard(int index) => _cards.elementAt(index);

  get numCards => _cards.length;

  List<CRCCard> get cards => _cards;

  void addCard(CRCCard card) {
    CRC_DBWorker.db.create(card);
    card.parentStack = this;
  }

  void addAllCards(Iterable<CRCCard> cards) {
    for (CRCCard card in cards) {
      _cards.add(card);
      card.parentStack = this;
    }
  }

  void removeCard(int index) {
    CRC_DBWorker.db.delete(_cards.elementAt(index).id);
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