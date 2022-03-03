import 'package:flutter/material.dart';
import 'package:smart_crc/card_entry.dart';
import 'package:smart_crc/card_view.dart';
import 'package:smart_crc/crc_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardList extends StatelessWidget {

  final List<CRCCard> _stack = List.empty(growable: true);

  CardList({Key? key}) : super(key: key);
  
  Widget _cardToTile(BuildContext context, CRCCard card) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (context) {}
          ),
          SlidableAction(
            icon: Icons.edit,
            backgroundColor: Colors.blue,
            onPressed: (context) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) =>CardEntry(_stack, _stack.indexOf(card)))
              );
            }
          )
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return CardView(card);
          })
        ),
        title: Text(card.className),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    _stack.add(person);
    _stack.add(instructor);
    _stack.add(student);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              _stack.add(CRCCard('Here is a brand new CRC Card'));
              return CardEntry(_stack, _stack.length - 1);
            })
          )
        },
      ),
      appBar: AppBar(
        title: const Text('CRC Card List'),
      ),
      body: ListView.separated(
        itemCount: _stack.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return _cardToTile(context, _stack[index]);
        },
      ),
    );
  }
}