import 'package:flutter/material.dart';
import 'package:smart_crc/card_view.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'crd_flip_card_builder.dart';
import 'database/CRC_DBWorker.dart';
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
    cardModel.loadData(CRC_DBWorker.db);
    //print(cardModel.entityList[10].id.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRC Card List'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info)
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
      body: FutureBuilder<void>(
        future: cardModel.loadData(CRC_DBWorker.db),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if(widget._stack.cards.length == 0) {
              widget._stack.cards.addAll(cardModel.entityList);
            }
            print(widget._stack.cards.length);
            return SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
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
                                                widget._stack.removeCard(widget._stack.cards.indexOf(card));
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
            );
          } else {
            return Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
  }
}