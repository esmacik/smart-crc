import 'package:flutter/material.dart';
import 'package:smart_crc/card_entry.dart';
import 'package:smart_crc/card_list.dart';

void main() {
  runApp(const SmartCRC());
}

class SmartCRC extends StatelessWidget {
  const SmartCRC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartCRC'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Press me'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => CardList()
            )
          ),
        ),
      ),
    );
  }
}
