import 'package:flutter/material.dart';
import 'package:smart_crc/stack_list.dart';
import 'package:smart_crc/database/CRC_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'model/crc_card.dart';

void main() {
  runApp(const SmartCRC());
}

class SmartCRC extends StatelessWidget {
  const SmartCRC({Key? key}) : super(key: key);


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
