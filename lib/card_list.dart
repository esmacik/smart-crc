import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_crc/card_view.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'crd_flip_card_builder.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';

import 'model/crc_card.dart';

class CardList extends StatefulWidget {

  final CRCCardStack _stack;

  const CardList(this._stack, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CardListState();
}

class _CardListState extends State<CardList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRC Card List'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.info)
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            widget._stack.addCard(CRCCard.blank());
          });
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
            childAspectRatio: 2,
            children: widget._stack.cards.map((card) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CardView(card))
                  );
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: BottomSheet(
                          onClosing: () {},
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      widget._stack.cards.remove(card);
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  title: const Text(
                                    'Delete card',
                                    style: TextStyle(
                                      color: Colors.red
                                    ),
                                  ),
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }
                  );
                },
                child: CRCFlipCard(card, CRCFlipCardType.simple)
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}