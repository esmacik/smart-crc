import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:smart_crc/model/responsibility.dart';

enum CRCFlipCardType {
  editable,
  static,
  scrollable
}

class CRDFlipCard extends StatefulWidget {

  final CRCCard _crcCard;
  final CRCFlipCardType _flipCardType;


  CRDFlipCard(this._crcCard, this._flipCardType, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CRDFlipCardState();
}

class _CRDFlipCardState extends State<CRDFlipCard> {

  final FlipCardController _flipCardController = FlipCardController();

  void _onCardSwipe(DragUpdateDetails details) {
    if (details.delta.dx.abs() > details.delta.dy.abs()) _flipCardController.toggleCard();
  }
  
  Widget _buildClassNameView({required bool editable}) {
    if (editable) {
      return TextFormField(
        textAlign: TextAlign.center,
        initialValue: widget._crcCard.className,
        onChanged: (value) => widget._crcCard.className = value,
      );
    }
    return Text(widget._crcCard.className, textScaleFactor: 1.5);
  }

  Widget _buildResponsibilitiesView([bool editable = false, bool scrollable = false]) {
    List<Widget> responsibilitiesElements = List.empty(growable: true);

    if (editable) {
      for (var responsibility in widget._crcCard.responsibilities) {
        responsibilitiesElements.add(
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Text('${widget._crcCard.responsibilities.indexOf(responsibility) + 1}.'),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: responsibility.name,
                  onChanged: (value) => responsibility.name = value,
                ),
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outlined, color: Colors.red)
              )
            ],
          )
        );
      }
      responsibilitiesElements.add(
        IconButton(
          onPressed: () {
            setState(() {
              widget._crcCard.addResponsibility(Responsibility());
            });
          },
          icon: const Icon(Icons.add)
        ),
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
    List<Widget> collaboratorsEntries = List.empty(growable: true);

    if (editable) {
      for (CRCCard collaborator in widget._crcCard.collaborators) {
        collaboratorsEntries.add(
          Row(
            children: [
              Expanded(
                child: DropdownButton<CRCCard>(
                  isExpanded: true,
                  value: collaborator,
                  items: widget._crcCard.parentStack!.cards.where((element) => element != widget._crcCard).map((card) {
                    return DropdownMenuItem<CRCCard>(
                      child: Text(card.className),
                      value: card,
                    );
                  }).toList()..add(
                    DropdownMenuItem(
                      child: Text('New...'),
                      value: null
                    )
                  ),
                  onChanged: (card) {
                    setState(() {
                      widget._crcCard.collaborators.remove(collaborator);
                      widget._crcCard.collaborators.add(card!);
                    });
                  },
                ),
              ),
              const Text(' Responsibility: '),
              DropdownButton<int>(
                value: 0,
                items: List.generate(widget._crcCard.responsibilities.length, (index) {
                  return DropdownMenuItem<int>(
                    child: Text("${index+1}"),
                    value: index,
                  );
                })..add(
                  DropdownMenuItem<int>(
                    child: Text('New...'),
                    value: widget._crcCard.responsibilities.length + 1,
                  )
                ),
                onChanged: (index) {
                  if (index != null && index >= widget._crcCard.responsibilities.length) {
                    setState(() {
                      widget._crcCard.responsibilities.add(Responsibility());
                    });
                  }
                }
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outlined, color: Colors.red,)
              )
            ],
          )
        );
      }

      if (widget._crcCard.responsibilities.isNotEmpty) {
        collaboratorsEntries.add(
          PopupMenuButton<CRCCard>(
            icon: const Icon(Icons.add),
            itemBuilder: (context) => widget._crcCard.parentStack!.cards.where((element) => element != widget._crcCard).map((card) {
              return PopupMenuItem<CRCCard>(
                child: Text(card.className),
                value: card,
              );
            }).toList(),
            onSelected: (card) {
              setState(() {
                widget._crcCard.collaborators.add(card);
              });
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
      for (CRCCard collaborator in widget._crcCard.collaborators) {
        collaboratorsEntries.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget._crcCard.collaborators.indexOf(collaborator) + 1}. '),
              Expanded(child: Text('${collaborator.className} helps fulfill responsibility n.')),
            ],
          )
        );
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
    return GestureDetector(
      onPanUpdate: (details) => _onCardSwipe(details),
      child: AspectRatio(
        aspectRatio: 6/3,
        child: FlipCard(
          controller: _flipCardController,
          flipOnTouch: false,
          fill: Fill.fillBack,
          front: _buildCRCCardFront(editable, scrollable),
          back: _buildCRCCardBack(editable, scrollable)
        ),
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