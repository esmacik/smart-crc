import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'base_model.dart';

CardModel cardModel = CardModel();

class CRCCard {
  var id;

  CRCCardStack? parentStack;
  String className;
  final List<Responsibility> _responsibilities = List.empty(growable: true);
  final List<CRCCard> _collaborators = List.empty(growable: true);
  String note = '';

  CRCCard(this.className);

  CRCCard.blank(): className = 'New Card';

  CRCCard.fromMap(Map<String, dynamic> map):
    id = map['id'],
    parentStack = null,
    className = map['className'],
    note = map['note'] {
    _responsibilities.addAll((map['responsibilities'] as List<dynamic>).map((e) => Responsibility.fromMap(e)));
  }


  int get numResponsibilities => _responsibilities.length;
  int get numCollaborators => _collaborators.length;

  List<Responsibility> get responsibilities => _responsibilities;
  List<CRCCard> get collaborators => _collaborators;

  void addCollaborator(CRCCard crcCard) {
    _collaborators.add(crcCard);
  }

  void addResponsibility(Responsibility responsibility){
    _responsibilities.add(responsibility);
  }

  Map<String, dynamic> toMap() => {
    'type': 'card',
    'id': id,
    'parentStack': parentStack?.id,
    'className': className,
    'responsibilities': _responsibilities.map((responsibility) => responsibility.toMap()).toList(),
    'collaborators': _collaborators.map((collaborator) => collaborator.id).toList(),
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