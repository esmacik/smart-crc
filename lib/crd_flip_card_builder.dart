import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:smart_crc/model/crc_card.dart';

enum CRCFlipCardType {
  normal,
  simple
}

class CRCFlipCard extends StatefulWidget {

  final CRCCard _crcCard;
  final CRCFlipCardType _flipCardType;

  const CRCFlipCard(this._crcCard, this._flipCardType, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CRCFlipCardState();
}

class _CRCFlipCardState extends State<CRCFlipCard> {

  final FlipCardController _flipCardController = FlipCardController();

  void _onCardSwipe(DragUpdateDetails details) {
    if (details.delta.dx.abs() > details.delta.dy.abs()) _flipCardController.toggleCard();
  }

  Widget _collaboratorDropdownMenuBuilder(BuildContext context, {CRCCard? omit}) {
    return PopupMenuButton<CRCCard>(
      icon: const Icon(Icons.arrow_drop_down),
      itemBuilder: (context) => [
        ...widget._crcCard.parentStack!.cards.where((element) => element != omit).map((card) {
          return PopupMenuItem<CRCCard>(
            child: Text(card.className),
            value: card,
          );
        })
      ],
      onSelected: (card) {
        setState(() {
          if (omit != null) widget._crcCard.collaborators.remove(omit);
          widget._crcCard.collaborators.add(card);
        });
      },
    );
  }

  Widget _buildCRCCardWidget() {
    return GestureDetector(
      onPanUpdate: (details) => _onCardSwipe(details),
      child: AspectRatio(
        aspectRatio: 6/3,
        child: FlipCard(
          controller: _flipCardController,
          flipOnTouch: false,
          fill: Fill.fillBack,
          front: Card(
            elevation: 20,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget._crcCard.className),
                ),
                const Divider(thickness: 2,),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
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
                              child: ListView(
                                children: [
                                  ...widget._crcCard.responsibilities.map((responsibility) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                      child: TextFormField(
                                        initialValue: responsibility.name,
                                      ),
                                    );
                                  }),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        widget._crcCard.addResponsibility();
                                      });
                                    },
                                    icon: const Icon(Icons.add)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        thickness: 1,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                      Expanded(
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
                              child: ListView(
                                children: [
                                  ...widget._crcCard.collaborators.map((collaborator) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                      child: ListTile(
                                        horizontalTitleGap: 0,
                                        title: Text(collaborator.className),
                                        trailing: PopupMenuButton<CRCCard>(
                                          icon: const Icon(Icons.arrow_drop_down),
                                          itemBuilder: (context) => widget._crcCard.parentStack!.cards.where((element) => element != collaborator).map((card) {
                                            return PopupMenuItem<CRCCard>(
                                              child: Text(card.className),
                                              value: card,
                                            );
                                            }).toList(),
                                          onSelected: (card) {
                                            setState(() {
                                              widget._crcCard.collaborators.remove(collaborator);
                                              widget._crcCard.collaborators.add(card);
                                            });
                                          },
                                        ),
                                      )
                                    );
                                  }),
                                  PopupMenuButton<CRCCard>(
                                    icon: Icon(Icons.add),
                                    itemBuilder: (context) => widget._crcCard.parentStack!.cards.where((element) => !widget._crcCard.parentStack!.cards.contains(element)).map((card) {
                                      return PopupMenuItem<CRCCard>(
                                        child: Text(card.className),
                                        value: card,
                                      );
                                    }).toList(),
                                    onSelected: (card) {
                                      setState(() {
                                        widget._crcCard.addCollaborator(widget._crcCard);
                                      });
                                    },
                                    icon: const Icon(Icons.add)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          back: Card(
              elevation: 20,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Notes',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline
                      ),
                    ),
                  ),
                  Text(widget._crcCard.note),
                ],
              ),
            )
        ),
      ),
    );
  }

  Widget _buildSimpleCRCCardWidget() {
    return GestureDetector(
      onPanUpdate: (details) => _onCardSwipe(details),
      child: AspectRatio(
        aspectRatio: 6/3,
        child: FlipCard(
          controller: _flipCardController,
          flipOnTouch: false,
          fill: Fill.fillBack,
          front: Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget._crcCard.className, textScaleFactor: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Responsibilities: ${widget._crcCard.responsibilities.length}"),
                      Text("Collaborators: ${widget._crcCard.collaborators.length}")
                    ],
                  )
                ],
              ),
            ),
          ),
          back: Card()
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget._flipCardType == CRCFlipCardType.normal
      ? _buildCRCCardWidget()
      : _buildSimpleCRCCardWidget();
  }
}
