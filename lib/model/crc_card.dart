import 'package:flutter/material.dart';
import 'package:smart_crc/database/STACK_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'base_model.dart';

CardModel cardModel = CardModel();

class CRCCard {
  late int id;
  String className;
  String note = '';
  late CRCCardStack? parentStack;
  final List<Responsibility> _responsibilities = List.empty(growable: true);

  CRCCard(this.className);

  CRCCard.blank(): className = 'New Card';

  CRCCard.fromMap(Map<String, dynamic> map, this.parentStack):
    //id = map['id'],
    className = map['className'],
    note = map['note'] {
    for (Map<String, dynamic> respMap in map['responsibilities']) {
      Responsibility responsibility = Responsibility.fromMap(respMap);
      _responsibilities.add(responsibility);
    }
  }

  Map<String, dynamic> toMap({required bool includeParent}) => {
    'type': 'card',
    //'id': id,
    'parentStack': includeParent ? parentStack!.id : null,
    'className': className,
    'responsibilities': _responsibilities.map((responsibility) {
      print('Number of responsibilities for this card: ${_responsibilities.length}');
      return responsibility.toMap();
    }).toList(),
    'note': note
  };

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