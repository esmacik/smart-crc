import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_crc/database/COLLAB_DBWorker.dart';
import 'package:smart_crc/database/CRC_DBWorker.dart';
import 'package:smart_crc/database/RESP_DBWorker.dart';
import 'package:smart_crc/model/collaborator.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:smart_crc/model/responsibility.dart';

enum CRCFlipCardType {
  editable,
  static,
  scrollable
}

class CRCFlipCard extends StatefulWidget {

  final CRCCard _crcCard;
  final CRCFlipCardType _flipCardType;


  CRCFlipCard(this._crcCard, this._flipCardType, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CRCFlipCardState();
}

class _CRCFlipCardState extends State<CRCFlipCard> {

  final FlipCardController _flipCardController = FlipCardController();
  
  Widget _buildClassNameView({required bool editable}) {
    if (editable) {
      return TextFormField(
        textAlign: TextAlign.center,
        initialValue: widget._crcCard.className,
        onChanged: (value) {
          widget._crcCard.className = value;
          CRC_DBWorker.db.update(widget._crcCard);
        }
      );
    }
    return Text(widget._crcCard.className, textScaleFactor: 1.5);
  }

  Widget _buildResponsibilitiesView([bool editable = false, bool scrollable = false]) {
    List<Widget> responsibilitiesElements = List.empty(growable: true);

    if (editable) {
      for (var responsibility in widget._crcCard.responsibilities) {
        responsibilitiesElements.add(
          Slidable(
            endActionPane: _buildResponsibilityActionPane(responsibility),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Text('${widget._crcCard.responsibilities.indexOf(responsibility) + 1}.'),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: responsibility.name,
                    onChanged: (value) async {
                      responsibility.name = value;
                      print('PLS:' + responsibility.name);
                      await RESP_DBWorker.db.update(responsibility);
                      var r = await RESP_DBWorker.db.get(responsibility.id);
                      print('EH?:'+ r.id.toString());
                    }
                  ),
                ),
              ],
            ),
          )
        );
      }
      responsibilitiesElements.add(
        IconButton(
          onPressed: () async {
            Responsibility r = Responsibility();
            r.name = 'New responsibility';
            r.parentCardId = widget._crcCard.id;
            int rID = await RESP_DBWorker.db.create(r);
            r.id = rID;
            print(rID);
            setState(() {
              widget._crcCard.addResponsibility(r);
            });
          },
          icon: const Icon(Icons.add)
        ),
      );
    } else {
      if (widget._crcCard.responsibilities.isEmpty) {
        responsibilitiesElements.add(
          const Center(
            child: Text('No Responsibilities.'),
          )
        );
      } else {
        for (var responsibility in widget._crcCard.responsibilities) {
          responsibilitiesElements.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget._crcCard.responsibilities.indexOf(responsibility) + 1}. '),
                Flexible(
                  child: Text(
                    responsibility.name,
                  )
                ),
              ],
            )
          );
        }
      }
    }

    return Expanded(
      child: Column(
        children: [
          const Center(
            child: Text(
              'Responsibilities',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: responsibilitiesElements.length,
              itemBuilder: (context, index) => responsibilitiesElements.elementAt(index),
              separatorBuilder: (context, index) => const SizedBox(height: 8,),
              physics: scrollable ? null : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsView([bool editable = false, bool scrollable = false]) {
    Set<Widget> collaboratorsEntries = {};

    if (editable) {
      for (Responsibility responsibility in widget._crcCard.responsibilities) {
        for (Collaborator collaborator in responsibility.collaborators) {
          //print(responsibility.collaborators.length);
          print('---' + collaborator.id.toString());
          collaboratorsEntries.add(
            Slidable(
                endActionPane: _buildCollaboratorActionPane(responsibility, collaborator),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<CRCCard>(
                        isExpanded: true,
                        //value: collaborator,
                        value: widget._crcCard.parentStack!.cards.firstWhere((card) => card.id == collaborator.cardID),
                        items: widget._crcCard.parentStack!.cards.where((card) => card != widget._crcCard).map((card) {
                          // print(widget._crcCard.parentStack!.cards.where((element) => element.id != widget._crcCard.id));
                          // print('AAA' + card.className);
                          return DropdownMenuItem<CRCCard>(
                            child: Text(card.className),
                            //value: Collaborator.assigned(card,responsibility)
                            value: card
                          );
                        }).toSet().toList()..add(
                          const DropdownMenuItem(
                            child: Text('New...'),
                            value: null
                          )
                        ),
                        onChanged: (newCollab) async {
                          print('You selected:' + newCollab.toString());
                          if (newCollab != null) {
                            collaborator.cardID = newCollab.id;
                            await COLLAB_DBWorker.db.update(collaborator).then((value) => setState(() {}));
                          } else {

                          }
                        },
                      ),
                    ),
                    const Text(' Responsibility: '),
                    DropdownButton<int>(
                      value: widget._crcCard.responsibilities.indexOf(responsibility),
                      items: List.generate(widget._crcCard.responsibilities.length, (index) {
                        return DropdownMenuItem<int>(
                          child: Text('${index+1}'),
                          value: index,
                        );
                      })..add(
                        DropdownMenuItem<int>(
                          child: const Text('New...'),
                          value: widget._crcCard.responsibilities.length + 1,
                        )
                      ),
                      onChanged: (index) async {
                        if (index != null && index >= widget._crcCard.responsibilities.length) {
                          Responsibility responsibility = Responsibility();
                          responsibility.name = 'New responsibility';
                          responsibility.parentCardId = widget._crcCard.id;
                          widget._crcCard.responsibilities.add(responsibility);
                        } else if (index != null) {
                          responsibility.collaborators.remove(collaborator);
                          widget._crcCard.responsibilities.elementAt(index).collaborators.add(collaborator);
                          collaborator.respID = widget._crcCard.responsibilities.elementAt(index).id;
                        }
                        await COLLAB_DBWorker.db.update(collaborator);
                        await RESP_DBWorker.db.update(responsibility).then((value) => setState(() {}));
                      }
                    ),
                  ],
                ),
              )
          );
        }
      }

      if (widget._crcCard.responsibilities.isNotEmpty) {
        collaboratorsEntries.add(
          PopupMenuButton<CRCCard>(
            icon: const Icon(Icons.add),
            itemBuilder: (context) => widget._crcCard.parentStack!.cards.where((card) => card != widget._crcCard).map((card) {
              return PopupMenuItem<CRCCard>(
                child: Text(card.className),
                value: card,
              );
            }).toList(),
            onSelected: (card) async {
              Collaborator collab = Collaborator.assigned(card, this.widget._crcCard.responsibilities.first);
              var id = await COLLAB_DBWorker.db.create(collab);
              collab.id = id;
              widget._crcCard.responsibilities.first.collaborators.add(collab);
              setState(() {
              });
              //await RESP_DBWorker.db.update(widget._crcCard.responsibilities.first).then((value) => setState(() {}));
            },
          )
        );
      } else {
        collaboratorsEntries.add(
            const Center(
              child: Text('To add a collaborator, add at least one responsibility.')
            )
        );
      }
    } else {
      if (widget._crcCard.numCollaborators == 0) {
        collaboratorsEntries.add(
            const Center(
              child: Text('No collaborators.'),
            )
        );
      } else {
        for (Responsibility responsibility in widget._crcCard.responsibilities) {
          for (Collaborator collaborator in responsibility.collaborators) {
            collaboratorsEntries.add(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text('Responsibility ${widget._crcCard.responsibilities.indexOf(responsibility)+ 1} collaborates with ${cardModel.entityList.firstWhere((element) =>
                    element.id == collaborator.cardID).className}.'))
                ],
              )
            );
          }
        }
      }
    }
    return Expanded(
      child: Column(
        children: [
          const Center(
            child: Text(
              'Collaborators',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: collaboratorsEntries.length,
              itemBuilder: (context, index) =>collaboratorsEntries.elementAt(index),
              separatorBuilder: (context, index) => const SizedBox(height: 10,),
              physics: scrollable ? null : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
            )
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      )
    );
  }

  ActionPane _buildResponsibilityActionPane(Responsibility responsibility) {
    return ActionPane(
      extentRatio: 1/4,
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          label: 'Delete',
          icon: Icons.delete,
          backgroundColor: Colors.red,
          onPressed: (context) => setState(() {
            widget._crcCard.responsibilities.remove(responsibility);
            RESP_DBWorker.db.delete(responsibility.id);
          })
        )
      ]
    );
  }

  ActionPane _buildCollaboratorActionPane(Responsibility responsibility, Collaborator collaborator) {
    return ActionPane(
      extentRatio: 1/4,
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          label: 'Delete',
          icon: Icons.delete,
          backgroundColor: Colors.red,
          onPressed: (context) {
            setState(() {
              responsibility.collaborators.remove(collaborator);
              COLLAB_DBWorker.db.delete(collaborator.id);
            });
          }
        )
      ]
    );
  }

  Widget _buildCRCCardFront([bool editable = false, bool scrollable = false]) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 20,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: _buildClassNameView(editable: editable)
            ),
          ),
          Divider(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey
          ),
          Expanded(
            child: Row(
              children: [
                _buildResponsibilitiesView(editable, scrollable),
                VerticalDivider(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey,
                ),
                _buildCollaboratorsView(editable, scrollable)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCRCCardBack([bool editable = false, bool scrollable = false]) {

    Widget _selectNoteView(bool editable) {
      if (editable) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: TextFormField(
            decoration: const InputDecoration(
                hintText: 'Enter a note for this class, such as:\n - Required attributes\n - Implementation notes\n - Future changes\n - Superclasses\n - Subclasses'
            ),
            initialValue: widget._crcCard.note,
            minLines: 10,
            maxLines: 10,
            onChanged: (value) {},
          )
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(widget._crcCard.note.trim().isEmpty ? 'Card notes will be shown here.' :widget._crcCard.note),
        );
      }
    }

    return Card(
      elevation: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Text(
              'Notes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: scrollable ? null : const NeverScrollableScrollPhysics(),
              child: _selectNoteView(editable)
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCRCCard([bool editable = false, bool scrollable = true]) {
    return AspectRatio(
      aspectRatio: 6/3,
      child: Stack(
        children: [
          FlipCard(
            controller: _flipCardController,
            flipOnTouch: false,
            fill: Fill.fillBack,
            front: _buildCRCCardFront(editable, scrollable),
            back: _buildCRCCardBack(editable, scrollable)
          ),
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              child: Icon(Icons.flip),
              onPressed: () => _flipCardController.toggleCard(),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const CircleBorder())
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget._flipCardType == CRCFlipCardType.editable) {
      return _buildCRCCard(true);
    } else if (widget._flipCardType == CRCFlipCardType.static) {
      return _buildCRCCard(false, false);
    } else if (widget._flipCardType == CRCFlipCardType.scrollable) {
      return _buildCRCCard(false, true);
    }
    return const Center (child: Text('Unsupported CRCFlipCardType.'));
  }
}
