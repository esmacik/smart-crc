import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_crc/stack_list.dart';
import 'package:smart_crc/database/CRC_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'model/crc_card.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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
  // List<SharedMediaFile> _sharedFiles;
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

  @override
  void initState() {
    super.initState();

    // _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((value) {
    //   print('Value shared 1: $value');
    // }, onError: (err) {
    //   print('getLinkStream error: $err');
    // });
    //
    // ReceiveSharingIntent.getInitialText().then((value) {
    //   print('Value shared 2: $value');
    // });

    // _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen((event) {
    //   print('Shared files: ${event.length}');
    //   for (SharedMediaFile file in event) {
    //     print('Received file 1: ${file.path} : ${file.type}');
    //   }
    // }, onError: (err) {
    //   print("getIntentDataStream error: $err");
    // });
    //
    // ReceiveSharingIntent.getInitialMedia().then((value) {
    //   print('Shared files: ${value.length}');
    //   for(SharedMediaFile file in value) {
    //     print('Received file 1: ${file.path} : ${file.type}');
    //   }
    // });

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
          setState(() {
            //print("Shared:" + (_sharedFiles?.map((f)=> f.path)?.join(",") ?? ""));
            print('weeee');
          });
        }, onError: (err) {
          print("getIntentDataStream error: $err");
        });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        //_sharedFiles = value;
        print('Shared: $value');
      });
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
