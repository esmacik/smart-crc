import 'package:flutter/material.dart';
import 'package:smart_crc/card_list.dart';
import 'package:smart_crc/crc_stack_list.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'model/crc_card.dart';

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
    List<CRCCard> stack = List.empty(growable: true);

    CRCCard person = CRCCard('Person')
      ..addResponsibility(responsibility: 'Eat food')
      ..addResponsibility(responsibility: 'Wake up');
    CRCCard instructor = CRCCard('Instructor')
      ..addResponsibility(responsibility: 'Teach well')
      ..addResponsibility(responsibility: 'Grade assignments');
    CRCCard student = CRCCard('Student')
      ..addResponsibility(responsibility: 'Go to class')
      ..addResponsibility(responsibility: 'Get A\'s');

    student.addCollaborator(person);
    instructor.addCollaborator(student);
    student.addCollaborator(instructor);

    stack.add(person);
    stack.add(instructor);
    stack.add(student);

    CRCCardStack cardStack = CRCCardStack('School System', stack);

    return Scaffold(
      appBar: AppBar(
        title: Text('SmartCRC'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Press me'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => CRCStackList([cardStack])
            )
          ),
        ),
      ),
    );
  }
}
