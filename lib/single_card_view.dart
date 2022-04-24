import 'package:flutter/material.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'model/crc_card_stack.dart';
import 'package:flutter/services.dart';
import 'package:smart_crc/crc_flip_card.dart';

class SingleCardView extends StatefulWidget {
  final CRCCardStack _stack;
  final CRCFlipCardType _flipCardType;

  int _cardIndex;

  SingleCardView(this._stack, this._cardIndex, this._flipCardType, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleCardViewState();
}

class _SingleCardViewState extends State<SingleCardView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      body: Stack(
        children: [
          Center(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CRDFlipCard(widget._stack.cards.elementAt(widget._cardIndex), widget._flipCardType),
                ),
              ),
            )
          ),
        ],
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