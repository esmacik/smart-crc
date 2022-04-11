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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRC Card List'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('How-to'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Tape a card to view more details and edit.\n'),
                      Text('Swipe a card to the left or right to flip to the back of the card.\n'),
                      Text('Long-press a card to delete and share a card.')
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK')
                    )
                  ],
                )
              );
            },
            icon: const Icon(Icons.info)
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          CRCCard? newCard = await showDialog<CRCCard>(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Class name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter a unique class name.'),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _cardNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty || widget._stack.cards.where((element) => element.className.toLowerCase() == value.toLowerCase()).isNotEmpty) {
                          return 'New class name must be unique.'
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _cardNameController.clear();
                    Navigator.of(context).pop(null);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.red),)
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      CRCCard newCard = CRCCard(_cardNameController.text);
                      _cardNameController.clear();
                      Navigator.of(context).pop(newCard);
                    }
                  },
                  child: Text('Accept')
                ),
              ],
            )
          );

          if (newCard != null) {
            setState(() {
              widget._stack.addCard(newCard);
            });
          }
        },
      ),
      body: FutureBuilder<void>(
        future: cardModel.loadDataWithForeign(CRC_DBWorker.db,widget._stack.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if(widget._stack.cards.length != cardModel.entityList.length) {
              widget._stack.cards.clear();
              widget._stack.addAllCards(cardModel.entityList);
            }
            print("E:"+ cardModel.entityList.toString());
            // print("EL:"+ cardModel.entityList.length.toString());
            // print('WL:'+widget._stack.cards.length.toString());
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