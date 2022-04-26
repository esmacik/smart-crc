import 'package:smart_crc/model/crc_card.dart';

import 'base_model.dart';


RespModel respModel = RespModel();

class Responsibility {
  var id;
  String _name = "";
  CRCCard? card;

  //Hashmap: Map collaborators to index of responsibility

  Responsibility.fromMap(Map<String, dynamic> map) : id = map['id'], _name = map['name'] {
    card = null;
  }

  Responsibility(CRCCard c) {
    this.card = c;
  }

  Responsibility.named(CRCCard c, String name){
    this.name = name;
    this.card = c;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  Map<String, dynamic> toMap() => {
    'type': 'responsibility',
    'id': id,
    'name': name,
    'card': card?.id
  };
}

  class RespModel extends BaseModel<Responsibility> {
  var _stackIndex = 0;

  int get stackIndex => _stackIndex;

  void set stackIndex(int stackIndex) {
  _stackIndex = stackIndex;
  notifyListeners();
  }

  List<Responsibility> get respList => entityList;

  set noteList(List<Responsibility> value) {
  entityList = value;
  }

  List<Responsibility> entityList = [];

  var _entityBeingEdited;

  void setStackIndex(int stackIndex) {
  this.stackIndex = stackIndex;
  notifyListeners();
  }

  get respBeingEdited => _entityBeingEdited;

  set respBeingEdited(value) {
  _entityBeingEdited = value;
  }

  }
