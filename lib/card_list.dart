import 'package:flutter/material.dart';
import 'package:smart_crc/database/COLLAB_DBWorker.dart';
import 'package:smart_crc/database/RESP_DBWorker.dart';
import 'package:smart_crc/file_writer.dart';
import 'package:smart_crc/model/collaborator.dart';
import 'package:smart_crc/preferences.dart';
import 'package:smart_crc/single_card_view.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'crc_flip_card.dart';
import 'database/CARD_DBWorker.dart';
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


  @override
  void initState() {
    super.initState();
  }

  void _onAddCardButtonPressed(BuildContext context) async {
    CRCCard? newCard = await _showClassCreationDialog(context);
    if (newCard != null) {
      newCard.parentStack = widget._stack;
      int cardId = await CARD_DBWorker.db.create(newCard);
      setState(() {
        newCard.id = cardId;
        widget._stack.addCard(newCard);
        print(widget._stack.numCards);
      });
    }
  }


  void _onDeleteButtonPressed(CRCCard card) async {
    for (Responsibility responsibility in card.responsibilities) {
      for (Collaborator collaborator in responsibility.collaborators) {
        COLLAB_DBWorker.db.delete(collaborator.id);
      }
      responsibility.collaborators.clear();
      RESP_DBWorker.db.delete(responsibility.id);
    }
    card.responsibilities.clear();
    widget._stack.cards.remove(card);
    await CARD_DBWorker.db.delete(card.id).then((value) => setState(() {}));
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
            Text('Tap the flip button to '),
            Text('Tap a card view the card up close.\n'),
            Text('Slide a card to the left or long-press to edit, share, or delete the card.\n'),
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
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(widget._stack, widget._stack.cards.indexOf(card), CRCFlipCardType.editable)));
                      setState(() {});
                    },
                    title: const Text('Edit'),
                    leading: const Icon(Icons.edit),
                  ),
                  ListTile(
                    onTap: () async {
                      await showMoveDialog(context, card).then((value) => setState((){}));
                    },
                    title: const Text('Move'),
                    leading: const Icon(Icons.redo),
                  ),
                  ListTile(
                    onTap: () async {
                      String contents = jsonEncode(card.toMap(includeParent: false, includeCollaborators: false));
                      String writtenFilePath = await writeFile('${card.className.replaceAll(' ', '_')}_card', contents);
                      print('Card json: $contents');
                      await Share.shareFiles([writtenFilePath]);
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
    final AlertDialog dialog = AlertDialog(
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
            child: const Text('Cancel', style: TextStyle(color: Colors.red),)
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
    );

    return await showDialog<CRCCard>(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: dialog,
        ),
      )
    );
  }

  Widget _buildFullCardList(CRCCardStack stack) {
    if (stack.cards.isNotEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        itemCount: stack.cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2
        ),
        itemBuilder: (context, index) {
          CRCCard currentCard = stack.getCard(index);
          return Slidable(
            endActionPane: _buildCardEndActionPane(context, currentCard),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(stack, stack.cards.indexOf(currentCard), CRCFlipCardType.scrollable))),
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
        CRCCard currentCard = stack.getCard(index);
        return Slidable(
          endActionPane: _buildCardEndActionPane(context, currentCard),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: ListTile(
              title: Text(currentCard.className),
              subtitle: Text('${currentCard.responsibilities.length} responsibilities\n${currentCard.numCollaborators} collaborators'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(stack, stack.cards.indexOf(currentCard), CRCFlipCardType.scrollable))),
              onLongPress: () => _showCardSecondaryMenu(context, currentCard),
            ),
          ),
        );
      }
    );
  }

  Widget _buildCardList(CRCCardStack stack) {
    print(stack.id);
    if (stack.cards.isEmpty && stack.id != -1) {
      return const Center(
        child: Text('Create your first CRC Card with the add button below.'),
      );
    }
    if (stack.cards.isEmpty && stack.id == -1) {
      return const Center(
        child: Text('Imported cards will appear here.'),
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
    if (widget._stack.id! >= 0) {
      return Scaffold(
        endDrawer: Drawer(
          child: ListView(
            children: [
              SwitchListTile(
                  title: const Text("Use compact card view"),
                  value: Preferences.cardListType == CardListType.compact
                      ? true
                      : false,
                  onChanged: (switchOn) {
                    setState(() =>
                    Preferences.cardListType =
                    switchOn ? CardListType.compact : CardListType.full);
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
              builder: (context) =>
                  IconButton(
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
        floatingActionButton:
        FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _onAddCardButtonPressed(context)
          ,
        ),
        body: FutureBuilder<void>(
          // future: Future.wait([
          //   cardModel.loadDataWithForeign(CRC_DBWorker.db, widget._stack.id),
          //   respModel.loadData(RESP_DBWorker.db),
          //   collabModel.loadData(COLLAB_DBWorker.db)
          // ]),
          future: cardModel.loadDataWithForeign(
              CARD_DBWorker.db, widget._stack.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              for (CRCCard card in cardModel.entityList) {
                if (widget._stack.cards
                    .where((element) => element.id == card.id)
                    .isEmpty) {
                  card.parentStack = widget._stack;
                  widget._stack.cards.add(card);
                }
              }
              print("E:" + cardModel.entityList.toString());
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
    else {
      return Scaffold(
        endDrawer: Drawer(
          child: ListView(
            children: [
              SwitchListTile(
                  title: const Text("Use compact card view"),
                  value: Preferences.cardListType == CardListType.compact
                      ? true
                      : false,
                  onChanged: (switchOn) {
                    setState(() =>
                    Preferences.cardListType =
                    switchOn ? CardListType.compact : CardListType.full);
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
              builder: (context) =>
                  IconButton(
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
        body: FutureBuilder<void>(
          // future: Future.wait([
          //   cardModel.loadDataWithForeign(CRC_DBWorker.db, widget._stack.id),
          //   respModel.loadData(RESP_DBWorker.db),
          //   collabModel.loadData(COLLAB_DBWorker.db)
          // ]),
          future: cardModel.loadDataWithForeign(
              CARD_DBWorker.db, widget._stack.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              for (CRCCard card in cardModel.entityList) {
                if (widget._stack.cards
                    .where((element) => element.id == card.id)
                    .isEmpty) {
                  card.parentStack = widget._stack;
                  widget._stack.cards.add(card);
                }
              }
              print("E:" + cardModel.entityList.toString());
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



  Future<void> showMoveDialog(BuildContext context, CRCCard card) async {
    var newStack = null;
    return await showDialog(
        context: context,
        builder: (BuildContext context){
              return AlertDialog(
                content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState){
                 return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select a stack to move this card to:'),
                      DropdownButton<CRCCardStack?>(
                          isExpanded: true,
                          value: newStack,
                          items: stackModel.entityList.toSet().where((element) => element.cards.where((element) => element.className == card.className).isEmpty).map((stack) {
                            return DropdownMenuItem<CRCCardStack?>(
                              child: Text(stack.name),
                              value: stack,
                            );
                          }).toList()..add(
                              const DropdownMenuItem<CRCCardStack?>(
                                  child: Text('New...'),
                                  value: null
                              )
                          ),
                          onChanged: (selectedStack) {
                            if(selectedStack != null){
                              setState(() {
                                newStack = selectedStack;
                              });
                              print('Selected ${selectedStack.name}');
                            }
                          }
                      )
                ]);}),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      child: const Text('Cancel', style: const TextStyle(color: Colors.red),)
                  ),
                  TextButton(
                      onPressed: () async {
                        card.parentStack = newStack;
                        await CARD_DBWorker.db.update(card);
                        widget._stack.cards.remove(card);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        setState(() {

                        });
                      },
                      child: const Text('Accept')
                  ),

                ],
              );
            },
          );
  }
}

