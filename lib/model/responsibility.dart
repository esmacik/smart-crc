import 'package:smart_crc/model/collaborator.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'base_model.dart';

RespModel respModel = RespModel();

class Responsibility {
  late int id;
  late int parentCardId;
  String name = "";
  final List<Collaborator> collaborators = List.empty(growable: true);

  Responsibility.fromMap(Map<String, dynamic> map):
    name = map['name'],
    parentCardId = map['parentCardId'] {
    for (Map<String, dynamic> collabMap in map['collaborators']) {
      Collaborator collaborator = Collaborator.fromMap(collabMap);
      collaborators.add(collaborator);
    }
  }

  Map<String, dynamic> toMap({required bool includeCollaborators}) => {
    'type': 'responsibility',
    'name': name,
    'parentCardId': parentCardId,
    'collaborators': includeCollaborators ? collaborators.map((element) => element.toMap()).toList() : []
  };

  Responsibility();

  Responsibility.named(CRCCard c, String name){
    name = name;
    parentCardId = c.id;
  }

  int get numCollaborators => collaborators.length;
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
