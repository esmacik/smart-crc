import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:smart_crc/model/responsibility.dart';

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
                                    return TextFormField(
                                      initialValue: responsibility.name,
                                    );
                                  }),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        widget._crcCard.addResponsibility(responsibility: Responsibility());
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
                      const VerticalDivider(thickness: 2,),
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
                                    return TextFormField(
                                      initialValue: collaborator.className,
                                    );
                                  }),
                                  IconButton(
                                    onPressed: () {
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
