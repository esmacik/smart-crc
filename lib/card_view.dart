import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:smart_crc/crc_card.dart';

class CardView extends StatelessWidget {

  final CRCCard _crcCard;

  const CardView(this._crcCard, {Key? key}) : super(key: key);

  static Widget buildCrcFlipCard(CRCCard crcCard) {
    return AspectRatio(
      aspectRatio: 5/3,
      child: FlipCard(
        fill: Fill.fillBack,
        front: Card(
          elevation: 20,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(crcCard.className),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    'Responsibilities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
                    ),
                  ),
                  Text(
                    'Collaborators',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ...crcCard.responsibilities.map((responsibility) {
                        return Text(responsibility);
                      })
                    ]
                  ),
                  Column(
                    children: [
                      ...crcCard.collaborators.map((collaborator) {
                        return Text(collaborator.className);
                      })
                    ],
                  )
                ],
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
              Text(crcCard.note),
            ],
          ),
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildCrcFlipCard(_crcCard),
          )
        ),
      ),
    );
  }
}