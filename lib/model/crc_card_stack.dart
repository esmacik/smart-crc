import 'package:smart_crc/model/crc_card.dart';

class CRCCardStack {
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
    _cards.add(card);
  }

  void removeCard(int index) {
    _cards.removeAt(index);
  }
}
