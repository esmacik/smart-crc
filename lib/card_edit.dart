import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:smart_crc/crc_flip_card.dart';
import 'package:smart_crc/model/responsibility.dart';

class CardEdit extends StatefulWidget {
  final CRCCard _crcCard;
  final List<CRCCard> _stack;

  CardEdit(this._stack, int index, {Key? key}):
      _crcCard = _stack[index], super(key: key);

  @override
  State<StatefulWidget> createState() => _CardEditState();
}

class _CardEditState extends State<CardEdit> {
  final _formKey = GlobalKey<FormState>();

  Widget _buildClassNameEntry() {
    return Column(
      children: [
        TextFormField(
          initialValue: widget._crcCard.className,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Class Name',
            prefixIcon: Icon(Icons.title)
          ),
          onChanged: (value) {
            setState(() {
              widget._crcCard.className = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildResponsibilitiesEntries() {
    return Column(
      children: [
        ...widget._crcCard.responsibilities.map((responsibility) {
          return Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  onPressed: (context) {
                    setState(() {
                      int index = widget._crcCard.responsibilities.indexOf(responsibility);
                      widget._crcCard.responsibilities.removeAt(index);
                    });
                  }
                ),
              ],
            ),
            child: TextFormField(
              initialValue: responsibility.name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center)
              ),
              onChanged: (value) {
                setState(() {
                  int index = widget._crcCard.responsibilities.indexOf(responsibility);
                  widget._crcCard.responsibilities[index].name = value;
                });
              },
            ),
          );
        }),
        IconButton(
          color: Colors.blue,
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              widget._crcCard.addResponsibility(Responsibility.named("Test"));
            });
          },
        )
      ]
    );
  }

  Widget _buildCollaboratorsEntries() {
    return Column(
      children: widget._stack.where((card) => card != widget._crcCard).map((collaborator) {
        return Row(
          children: [
            Checkbox(
              value: widget._crcCard.collaborators.contains(collaborator),
              onChanged: (checked) {
                setState(() {
                  if (checked != null) {
                    if (checked) {
                      widget._crcCard.collaborators.add(collaborator);
                    } else {
                      widget._crcCard.collaborators.remove(collaborator);
                    }
                  }
                });
              }
            ),
            Text(collaborator.className)
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNotesEntry() {
    return Column(
      children: [
        TextFormField(
          initialValue: widget._crcCard.note,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Notes',
            prefixIcon: Icon(Icons.note)
          ),
          onChanged: (value) {
            setState(() {
              widget._crcCard.note = value;
            });
          },
        )
      ],
    );
  }

  Widget _buildEntryForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Text('Class Name'),
          ),
          _buildClassNameEntry(),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Text('Responsibilities'),
          ),
          _buildResponsibilitiesEntries(),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Text('Collaborators'),
          ),
          _buildCollaboratorsEntries(),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Text('Notes'),
          ),
          _buildNotesEntry()
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit CRC Card'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CRDFlipCard(widget._crcCard, CRCFlipCardType.static),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntryForm(),
            ),
          ],
        ),
      )
    );
  }
}