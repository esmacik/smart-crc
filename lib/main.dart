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
    CRCCardStack cardStack = CRCCardStack.empty('School System');

    CRCCard person = CRCCard('Person')
      ..addResponsibility(responsibility: Responsibility.named("Eat food"))
      ..addResponsibility(responsibility: Responsibility.named("Wake up"));
    CRCCard instructor = CRCCard('Instructor')
      ..addResponsibility(responsibility: Responsibility.named("Teach well"))
      ..addResponsibility(responsibility: Responsibility.named("Grade assignments"));
    CRCCard student = CRCCard('Student')
      ..addResponsibility(responsibility: Responsibility.named("Go to class"))
      ..addResponsibility(responsibility: Responsibility.named("Get As"));
    CRCCard classroom = CRCCard('Classroom')
      ..addResponsibility(responsibility: 'Exist')
      ..addResponsibility(responsibility: 'Be a good temperature');
    CRCCard airConditioner = CRCCard('Air Conditioner')
      ..addResponsibility(responsibility: 'Make the air cooler')
      ..addResponsibility(responsibility: 'Don\'t break');

    student.addCollaborator(person);
    instructor.addCollaborator(student);
    student.addCollaborator(instructor);

    cardStack.addCard(person);
    cardStack.addCard(instructor);
    cardStack.addCard(student);

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
