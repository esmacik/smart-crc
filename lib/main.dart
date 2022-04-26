import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'package:smart_crc/stack_list.dart';
import 'package:smart_crc/database/CRC_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'model/crc_card.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:convert';

void main() {
  runApp(SmartCRC());
}

class SmartCRC extends StatefulWidget {
  const SmartCRC({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SmartCRCSate();
}

class _SmartCRCSate extends State<SmartCRC> {

  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles = List.empty(growable: true);
  // String _sharedText;

  @override
  Widget build(BuildContext context) {
    cardModel.loadData(CRC_DBWorker.db);
    return MaterialApp(
      title: 'SmartCRC',
      themeMode: ThemeMode.system,
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              primaryColorDark: Colors.blue,
              accentColor: Colors.blue,
              brightness: Brightness.dark
          )
      ),
      home: _SmartCRCHomePage(),
    );
  }

  Future<void> _insertSharedFilesIntoDatabase(List<SharedMediaFile> files) async {
    for (SharedMediaFile file in files) {
      if (file.path.endsWith('.json')) {
        String fileContents = await File(file.path).readAsString();
        Map<String, dynamic> mapFromJson = jsonDecode(fileContents);
        if (mapFromJson['type'] == 'stack') {
          CRCCardStack stack = CRCCardStack.fromMap(mapFromJson);
          print('Stack name: ${stack.name}');
        } else if (mapFromJson['type'] == 'card') {
          CRCCard card = CRCCard.fromMap(mapFromJson);
          print('Card name: ${card.className}');
        } else if (mapFromJson['type'] == 'responsibility') {
          Responsibility responsibility = Responsibility.fromMap(mapFromJson);
          print('Responsibility name: ${responsibility.name}');
        } else {
          print('Invalid json format.');
        }
      } else {
        print('Shared file is not a json file.');
      }
    }

    _sharedFiles.clear();
  }

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
          _sharedFiles.addAll(files);
          _insertSharedFilesIntoDatabase(files);
        }, onError: (err) {
          print("getIntentDataStream error: $err");
        });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> files) {
      _sharedFiles.addAll(files);
      _insertSharedFilesIntoDatabase(files);
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
          print('Shared: $value');
        }, onError: (err) {
          print("getLinkStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((value) {
      print('Shared: $value');
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}

class _SmartCRCHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    cardModel.loadData(CRC_DBWorker.db);

    return Scaffold(
      appBar: AppBar(
        title: Text('SmartCRC'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            )),
            fixedSize: MaterialStateProperty.all(Size(175,50))
          ),
          child: Text('Begin'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => StackList([])
            )
          ),
        ),
      ),
    );
  }
}
