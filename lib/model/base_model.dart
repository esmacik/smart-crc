import 'package:scoped_model/scoped_model.dart';

/// The base model type for all scoped models in this application.
class BaseModel<T> extends Model {

  /// The index of the screen we should display.
  int stackIndex = 0;

  /// The list of entities that this model will display.
  List<T> entityList = [];

  /// The entity that will be edited.
  late T entityBeingEdited;

  /// Change the index of the screen that should be displayed.
  void setStackIndex(int stackIndex) {
    this.stackIndex = stackIndex;
    notifyListeners();
  }

  /// Load all the data from the available database.
  Future<void> loadData(database) async {
    entityList.clear();
    entityList.addAll(await database.getAll());
    notifyListeners();
  }

  Future<void> loadDataWithForeign(database, id) async {
    entityList.clear();
    entityList.addAll(await database.getAllForStack(id));
    notifyListeners();
  }
}