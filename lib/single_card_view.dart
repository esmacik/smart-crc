import 'package:flutter/material.dart';
import 'package:smart_crc/model/crc_card.dart';
import 'package:flutter/services.dart';
import 'package:smart_crc/crc_flip_card.dart';

class SingleCardView extends StatefulWidget {
  final CRCCard _crcCard;
  final CRCFlipCardType _flipCardType;

  const SingleCardView(this._crcCard, this._flipCardType, {Key? key}) : super(key: key);

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
                  child: CRDFlipCard(widget._crcCard, widget._flipCardType),
                ),
              ),
            )
          ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton.small(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back),
                ),
              ],
            ),
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