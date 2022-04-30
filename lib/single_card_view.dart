import 'package:flutter/material.dart';
import 'crc_flip_card.dart';
import 'model/crc_card_stack.dart';
import 'package:flutter/services.dart';
import 'package:smart_crc/crc_flip_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    PageController pageController = PageController(initialPage: widget._cardIndex);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            physics: widget._flipCardType == CRCFlipCardType.editable ? const NeverScrollableScrollPhysics() : null,
            controller: pageController,
            children: widget._stack.cards.map((card) {
              print('----${card.className}');
              return SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CRCFlipCard(card, widget._flipCardType),
                )
              );
            }).toList(),
          ),
          if (widget._flipCardType != CRCFlipCardType.editable) SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: SmoothPageIndicator(
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.blue,
                    dotHeight: 8,
                    dotWidth: 8
                  ),
                  controller: pageController,
                  count: widget._stack.cards.length,
                  onDotClicked: (page) => pageController.animateToPage(page, duration: Duration(milliseconds: 500), curve: Curves.ease),
                ),
              ),
            )
          )
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