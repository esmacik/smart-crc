import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_crc/card_list.dart';
import 'package:smart_crc/crc_stack_list.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'model/crc_card.dart';
import 'model/responsibility.dart';

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
      ..addResponsibility(Responsibility.named("Eat food"))
      ..addResponsibility(Responsibility.named("Wake up"));
    CRCCard instructor = CRCCard('Instructor')
      ..addResponsibility(Responsibility.named("Teach well"))
      ..addResponsibility(Responsibility.named("Grade assignments"));
    CRCCard student = CRCCard('Student')
      ..addResponsibility(Responsibility.named("Go to class"))
      ..addResponsibility(Responsibility.named("Get As"));
    CRCCard classroom = CRCCard('Classroom')
      ..addResponsibility(Responsibility.named('Exist'))
      ..addResponsibility(Responsibility.named('Be a good temperature'));
    CRCCard airConditioner = CRCCard('Air Conditioner')
      ..addResponsibility(Responsibility.named('Make the air cooler'))
      ..addResponsibility(Responsibility.named('Don\'t break'));

    student.addCollaborator(person);
    instructor.addCollaborator(student);
    student.addCollaborator(instructor);
    instructor.addCollaborator(classroom);
    classroom.addCollaborator(airConditioner);

    cardStack.addCard(person);
    cardStack.addCard(instructor);
    cardStack.addCard(student);
    cardStack.addCard(classroom);
    cardStack.addCard(airConditioner);

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
