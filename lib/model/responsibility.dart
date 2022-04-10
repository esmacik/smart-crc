class Responsibility {
  int id = -1;
  String _name = "";

  //Hashmap: Map collaborators to index of responsibility

  Responsibility();

  Responsibility.named( String name){
    this.name = name;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }


}
