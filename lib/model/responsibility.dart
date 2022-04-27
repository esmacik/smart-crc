import 'package:smart_crc/model/crc_card.dart';
import 'base_model.dart';

RespModel respModel = RespModel();

class Responsibility {
  late int id;
  //late CRCCard card;
  late int parentCardId;
  String name = "";
  final List<CRCCard> collaborators = List.empty(growable: true);

  //Hashmap: Map collaborators to index of responsibility

  Responsibility.fromMap(Map<String, dynamic> map):
    id = map['id'],
    name = map['name'];

  // Responsibility(CRCCard c) {
  //   parentCardId = c.id;
  // }

  Responsibility();

  Responsibility.named(CRCCard c, String name){
    name = name;
    parentCardId = c.id;
  }

  int get numCollaborators => collaborators.length;

  Map<String, dynamic> toMap() => {
    'type': 'responsibility',
    'id': id,
    'name': name,
    'parentCardId': parentCardId
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
