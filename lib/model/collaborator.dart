import 'dart:async';

import 'package:smart_crc/database/COLLAB_DBWorker.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'base_model.dart';

CollabModel collabModel = CollabModel();

class Collaborator {
  //hidden collaborator id to avoid duplicates
  late int id;
  //The id of the card the collaborator is from
  late int cardID;
  //Responsibility the collaborator is assigned to
  late int respID;

  // bool operator ==(dynamic other) =>
  //     other != null && other is Collaborator && this.id == other.id;
  //
  // @override
  // int get hashCode => super.hashCode;

  Collaborator.fromMap(Map<String, dynamic> map):
    cardID = map['cardID'],
    respID = map['respID'];


  Collaborator.assigned(CRCCard c, Responsibility r) {
    cardID = c.id;
    respID = r.id;
  }

  Collaborator();

  Map<String, dynamic> toMap() => {
    'type': 'collaborator',
    'cardID': cardID,
    'respID': respID
  };
}

class CollabModel extends BaseModel<Collaborator> {
  var _stackIndex = 0;

  int get stackIndex => _stackIndex;

  void set stackIndex(int stackIndex) {
    _stackIndex = stackIndex;
    notifyListeners();
  }

  List<Collaborator> get collabList => entityList;

  set noteList(List<Collaborator> value) {
    entityList = value;
  }

  List<Collaborator> entityList = [];

  var _entityBeingEdited;

  void setStackIndex(int stackIndex) {
    this.stackIndex = stackIndex;
    notifyListeners();
  }

  get collabBeingEdited => _entityBeingEdited;

  set collabBeingEdited(value) {
    _entityBeingEdited = value;
  }

}
