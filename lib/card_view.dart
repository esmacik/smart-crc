import 'package:flutter/material.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:flutter/services.dart';
import 'package:smart_crc/crd_flip_card_builder.dart';

class CardView extends StatefulWidget {
  final CRCCard _crcCard;

  const CardView(this._crcCard, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CardViewState();
}

class CardViewState extends State<CardView> {

  bool _editingCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(_editingCard ? Icons.cancel : Icons.edit),
        backgroundColor: _editingCard ? Colors.red : null,
        onPressed: () {
          setState(() {
            _editingCard = !_editingCard;
          });
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CRCFlipCard(widget._crcCard, CRCFlipCardType.normal),
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.dispose();
  }
}