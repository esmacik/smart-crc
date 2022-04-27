import 'package:flutter/material.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'base_model.dart';

CardModel cardModel = CardModel();

class CRCCard {
  late int id;

  late CRCCardStack? parentStack;
  //late int parentStackId;
  String className;
  final List<Responsibility> _responsibilities = List.empty(growable: true);
  //Map<int, List<int>> _collaborators = {}; // Map responsibility to list of collaborators
  String note = '';

  CRCCard(this.className);

  CRCCard.blank(): className = 'New Card';

  CRCCard.fromMap(Map<String, dynamic> map):
    id = map['id'],
    className = map['className'],
    note = map['note'] {
    _responsibilities.addAll((map['responsibilities'] as List<dynamic>).map((e) => Responsibility.fromMap(e)));
  }

  int get numResponsibilities => _responsibilities.length;

  int get numCollaborators {
    int sum = 0;
    for (Responsibility responsibility in _responsibilities) {
      sum = sum + responsibility.numCollaborators;
    }
    return sum;
  }

  List<Responsibility> get responsibilities => _responsibilities;

  void addResponsibility(Responsibility responsibility){
    _responsibilities.add(responsibility);
  }

  Map<String, dynamic> toMap() => {
    'type': 'card',
    'id': id,
    'parentStack': parentStack!.id,
    'className': className,
    'responsibilities': _responsibilities.map((responsibility) => responsibility.toMap()).toList(),
    'note': note
  };
}

class CardModel extends BaseModel<CRCCard> {
  var _stackIndex = 0;

  int get stackIndex => _stackIndex;

  void set stackIndex(int stackIndex) {
    _stackIndex = stackIndex;
    notifyListeners();
  }

  List<CRCCard> get cardList => entityList;

  set noteList(List<CRCCard> value) {
    entityList = value;
  }

  List<CRCCard> entityList = [];

  var _entityBeingEdited;

  void setStackIndex(int stackIndex) {
    this.stackIndex = stackIndex;
    notifyListeners();
  }

  get noteBeingEdited => _entityBeingEdited;

  set noteBeingEdited(value) {
    _entityBeingEdited = value;
  }

}