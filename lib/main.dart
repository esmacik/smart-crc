import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_crc/database/RESP_DBWorker.dart';
import 'package:smart_crc/database/STACK_DBWorker.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'package:smart_crc/stack_list.dart';
import 'package:smart_crc/database/CARD_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'model/crc_card.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:convert';

void main() {
  runApp(const SmartCRC());
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
    // cardModel.loadData(CRC_DBWorker.db);
    CARD_DBWorker.db.init();
    return MaterialApp(
      title: 'SmartCRC',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColor: Color(0xFF1DB8DA)
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primaryColorDark: Color(0xFF1DB8DA),
          accentColor: Color(0xFF1DB8DA),
          brightness: Brightness.dark
        )
      ),
      home: _SmartCRCHomePage(),
    );
  }

  Future<void> _insertSharedFilesIntoDatabase(List<SharedMediaFile> files) async {
    ///await stackModel.loadData(STACK_DBWorker.db);
    await cardModel.loadData(CARD_DBWorker.db);
    //await respModel.loadData(RESP_DBWorker.db);

    for (SharedMediaFile file in files) {
      if (file.path.endsWith('.json')) {
        String fileContents = await File(file.path).readAsString();
        Map<String, dynamic> mapFromJson = jsonDecode(fileContents);
        if (mapFromJson['type'] == 'stack') {
          CRCCardStack stack = CRCCardStack.fromMap(mapFromJson);
          stack.id = await STACK_DBWorker.db.create(stack);
          for (CRCCard card in stack.cards) {
            card.parentStack = stack;
            card.id = await CARD_DBWorker.db.create(card);
            for (Responsibility responsibility in card.responsibilities) {
              responsibility.parentCardId = card.id;
              responsibility.id = await RESP_DBWorker.db.create(responsibility);
            }
          }
          print('Stack and children cards added to database: ${stack.name}');
        } else if (mapFromJson['type'] == 'card') {
          // CRCCard card = CRCCard.fromMap(mapFromJson);
          // int id = await CRC_DBWorker.db.create(card);
          // card.id = id;
          //print('Card name: ${card.className}');
          print('Received a card');
        } else if (mapFromJson['type'] == 'responsibility') {
          //Responsibility responsibility = Responsibility.fromMap(mapFromJson);
          //print('Responsibility name: ${responsibility.name}');
        } else {
          print('Invalid json format.');
        }
      } else {
        print('Shared file is not a json file.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
      ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) async {
        print('File received 1!!!: ${files.length}');
        _sharedFiles.addAll(files);
        await _insertSharedFilesIntoDatabase(files);
        //files.clear();
      }, onError: (err) {
        print("getIntentDataStream error: $err");
      });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> files) async {
      print('File received 2!!!: ${files.length}');
      _sharedFiles.addAll(files);
      await _insertSharedFilesIntoDatabase(files);
      //files.clear();
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
    cardModel.loadData(CARD_DBWorker.db);
    return Scaffold(
      appBar: null,
      body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:  Alignment.topCenter,
                end: Alignment.bottomCenter,
                  stops: const [0.1, 0.33, 1],
                  colors: [
                    Colors.white,
                    Colors.white,
                    Theme.of(context).primaryColor
                  ]
              )
            ),
              child: Column(
                children: [
                  Image.asset('assets/images/crc.png',scale: 3),
                  Text("SmartCRC", style: const TextStyle(fontSize: 28, color: Color(0xFF607074), fontWeight: FontWeight.w500),),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)
                      )),
                      fixedSize: MaterialStateProperty.all(Size(175,50))
                    ),
                    child: Text('Begin',style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 16)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => StackList()
                  )
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )
        )
      ),
    );
  }
}
