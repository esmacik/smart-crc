import 'package:smart_crc/model/responsibility.dart';

class CRCCard {
  int id = -1;
  String className;
  final List<Responsibility> _responsibilities = List.empty(growable: true);
  final List<CRCCard> _collaborators = List.empty(growable: true);
  String note = '';

  CRCCard(this.className);

  CRCCard.blank(): className = 'New Card';

  int get numResponsibilities => _responsibilities.length;
  int get numCollaborators => _collaborators.length;

  List<Responsibility> get responsibilities => _responsibilities;
  List<CRCCard> get collaborators => _collaborators;

  void addCollaborator(CRCCard crcCard) {
    _collaborators.add(crcCard);
  }

  void addResponsibility({required Responsibility responsibility}) {
    _responsibilities.add(responsibility);
  }
}
