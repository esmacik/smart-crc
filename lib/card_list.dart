import 'package:flutter/material.dart';
import 'package:smart_crc/database/RESP_DBWorker.dart';
import 'package:smart_crc/file_writer.dart';
import 'package:smart_crc/preferences.dart';
import 'package:smart_crc/single_card_view.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'crc_flip_card.dart';
import 'database/CRC_DBWorker.dart';
import 'model/crc_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

enum CardListType {
  full,
  compact
}

class CardList extends StatefulWidget {

  final CRCCardStack _stack;

  const CardList(this._stack, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CardListState();
}

class _CardListState extends State<CardList> with Preferences, FileWriter {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNameController = TextEditingController();

  void _onAddCardButtonPressed(BuildContext context) async {
    CRCCard? newCard = await _showClassCreationDialog(context);
    if (newCard != null) {
      newCard.parentStack = widget._stack;
      int cardId = await CRC_DBWorker.db.create(newCard);
      setState(() {
        newCard.id = cardId;
      });
    }
  }

  void _onDeleteButtonPressed(CRCCard card) async {
    await CRC_DBWorker.db.delete(card.id).then((value) => setState(() {}));
  }

  void _showHowToDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How-to'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Divider(thickness: 1 ,color: Colors.white),
            Text('Tap a card to view more details.\n'),
            Text('Swipe a card to the left or right to flip the card.\n'),
            Text('Long-press a card to edit, share, and delete.')
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK')
          )
        ],
      )
    );
  }

  void _showCardSecondaryMenu(BuildContext context, CRCCard card) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: BottomSheet(
            onClosing: () {},
            builder: (context) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                shrinkWrap: true,
                children: [
                  Center(child: Text(card.className, textScaleFactor: 2,)),
                  ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(widget._stack, widget._stack.cards.indexOf(card), CRCFlipCardType.editable))),
                    title: const Text('Edit'),
                    leading: const Icon(Icons.edit),
                  ),
                  ListTile(
                    onTap: () async {
                      String contents = jsonEncode(card.toMap());
                      String writtenFilePath = await writeFile('${card.className.replaceAll(' ', '_')}_card', contents);
                      Share.shareFiles([writtenFilePath]);
                    },
                    title: const Text('Share'),
                    leading: const Icon(Icons.ios_share),
                  ),
                  ListTile(
                    onTap: () {
                      _onDeleteButtonPressed(card);
                      Navigator.of(context).pop();
                    },
                    title: Text('Delete ${card.className} class',
                      style: const TextStyle(
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
  }

  Future<CRCCard?> _showClassCreationDialog(BuildContext context) async {
    return await showDialog<CRCCard>(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Class name'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter a unique class name.'),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _cardNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a class name.';
                      } else if (widget._stack.cards.where((element) => element.className.toLowerCase() == value.toLowerCase()).isNotEmpty) {
                        return 'New class name must be unique.';
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
                child: const Text('Cancel', style: const TextStyle(color: Colors.red),)
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    CRCCard newCard = CRCCard(_cardNameController.text);
                    _cardNameController.clear();
                    Navigator.of(context).pop(newCard);
                  }
                },
                child: const Text('Accept')
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildFullCardList(CRCCardStack stack) {
    if (stack.cards.isNotEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        itemCount: widget._stack.cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2
        ),
        itemBuilder: (context, index) {
          CRCCard currentCard = widget._stack.getCard(index);
          return Slidable(
            endActionPane: _buildCardEndActionPane(context, currentCard),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(widget._stack, widget._stack.cards.indexOf(currentCard), CRCFlipCardType.scrollable))),
              onLongPress: () => _showCardSecondaryMenu(context, currentCard),
              child: CRCFlipCard(currentCard, CRCFlipCardType.static)
            ),
          );
        }
      );
    } else {
      return Container();
    }
  }

  ActionPane _buildCardEndActionPane(BuildContext context, CRCCard card) {
    return ActionPane(
      extentRatio: 1/4,
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          icon: Icons.more_horiz,
          label: 'More',
          backgroundColor: Colors.blue,
          onPressed: (context) => _showCardSecondaryMenu(context, card)
        )
      ]
    );
  }

  Widget _buildCompactCardList(CRCCardStack stack) {
    return ListView.separated(
      itemCount: stack.numCards,
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemBuilder: (context, index) {
        CRCCard currentCard = widget._stack.getCard(index);
        return Slidable(
          endActionPane: _buildCardEndActionPane(context, currentCard),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: ListTile(
              title: Text(currentCard.className),
              subtitle: Text('${currentCard.responsibilities.length} responsibilities\n${currentCard.numCollaborators} collaborators'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(widget._stack, widget._stack.cards.indexOf(currentCard), CRCFlipCardType.scrollable))),
              onLongPress: () => _showCardSecondaryMenu(context, currentCard),
            ),
          ),
        );
      }
    );
  }

  Widget _buildCardList(CRCCardStack stack) {
    if (stack.cards.isEmpty) {
      return const Center(
        child: Text('Create your first CRC Card with the add button below.'),
      );
    }
    if (Preferences.cardListType == CardListType.full) {
      return _buildFullCardList(stack);
    } else {
      return _buildCompactCardList(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text("Use compact card view"),
              value: Preferences.cardListType == CardListType.compact ? true : false,
              onChanged: (switchOn) {
                setState(() => Preferences.cardListType = switchOn ? CardListType.compact: CardListType.full);
              }
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('CRC Card List'),
        actions: [
          IconButton(
            onPressed: () => _showHowToDialog(context),
            icon: const Icon(Icons.info)
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu)
            ),
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async => _onAddCardButtonPressed(context),
      ),
      body: FutureBuilder<void>(
        future: Future.wait([cardModel.loadDataWithForeign(CRC_DBWorker.db, widget._stack.id), respModel.loadData(RESP_DBWorker.db)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if(widget._stack.cards.length != cardModel.entityList.length) {
              widget._stack.cards.clear();
              widget._stack.addAllCards(cardModel.entityList);

              for (CRCCard card in widget._stack.cards) {
                for(Responsibility r in respModel.entityList){
                  print('R:'+r.name + ', Rid:' + r.id.toString());
                  print('C:'+card.id.toString());
                  if(r.parentCardId == card.id){
                    card.addResponsibility(r);
                  }
                }
                // card.addResponsibility(Responsibility.named(card,'Go to class'));
                // card.addResponsibility(Responsibility.named(card,'Do homework'));
                // card.addResponsibility(Responsibility.named(card,'Graduate with 4.0'));

                // card.note = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse vel vehicula arcu. Fusce ut tellus in nisi egestas porttitor. Proin sed justo eleifend metus egestas pulvinar. Integer sit amet tortor egestas, pellentesque nunc eu, semper mi. Morbi elementum dolor vel nulla molestie, eget viverra ipsum tincidunt. Nulla molestie et nisl sit amet efficitur. Donec leo dolor, sollicitudin id mattis iaculis, posuere pretium enim. Mauris eu fringilla orci. Ut molestie pharetra nunc vitae convallis. Vestibulum rhoncus sem magna, at dictum quam aliquet a. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam rhoncus turpis ac felis porttitor feugiat ac vitae lectus. Nam maximus ullamcorper dui porta facilisis. Pellentesque aliquet quam nec dui tincidunt, vitae auctor nibh tincidunt.\n\n' * 5;
              }

              // for (CRCCard card in widget._stack.cards) {
              //   card.parentStack!.cards.where((element) => element != card).forEach((element) {
              //     card.addCollaborator(element);
              //   });
              // }
            }
            print("E:"+ cardModel.entityList.toString());
            return SafeArea(
              bottom: false,
              child: _buildCardList(widget._stack),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}