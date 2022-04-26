import 'package:path_provider/path_provider.dart';
import 'dart:io';

mixin FileWriter {
  Future<String> writeFile(String fileName, String contents) async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/$fileName.json');
    await file.writeAsString(contents);
    return file.path;
  }
}