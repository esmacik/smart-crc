class CRCCard {
  String className;
  final List<String> _responsibilities = List.empty(growable: true);
  final List<CRCCard> _collaborators = List.empty(growable: true);
  String note = '';

  CRCCard(this.className);

  int get numResponsibilities => _responsibilities.length;
  int get numCollaborators => _collaborators.length;

  List<String> get responsibilities => _responsibilities;
  List<CRCCard> get collaborators => _collaborators;

  void addCollaborator(CRCCard crcCard) {
    _collaborators.add(crcCard);
  }

  void addResponsibility({String responsibility = 'New responsibility'}) {
    _responsibilities.add(responsibility);
  }
}
