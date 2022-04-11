import 'package:smart_crc/database/CRC_DBWorker.dart';
import 'package:smart_crc/model/crc_card.dart';

class CRCCardStack {
  int id = -1;
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
