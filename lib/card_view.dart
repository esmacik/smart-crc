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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.navigate_before),
        onPressed: () => Navigator.of(context).pop(),
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