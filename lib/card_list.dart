import 'package:flutter/material.dart';
import 'package:smart_crc/preferences.dart';
import 'package:smart_crc/single_card_view.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:smart_crc/model/responsibility.dart';
import 'crc_flip_card.dart';
import 'database/CRC_DBWorker.dart';
import 'model/crc_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

class _CardListState extends State<CardList> with Preferences {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNameController = TextEditingController();

  void _onAddCardButtonPressed(BuildContext context) async {
    CRCCard? newCard = await _showClassCreationDialog(context);
    if (newCard != null) {
      newCard.parentStack = widget._stack;
      CRC_DBWorker.db.create(newCard).then((value) => setState(() {}));
    }
  }

  void _onDeleteButtonPressed(CRCCard card) async {
    CRC_DBWorker.db.delete(card.id).then((value) => setState(() {}));
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
            Text('Tape a card to view more details.\n'),
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
                  Center(child: Text('${card.className}', textScaleFactor: 2,)),
                  ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(card, CRCFlipCardType.editable))),
                    title: const Text('Edit'),
                    leading: const Icon(Icons.edit),
                  ),
                  ListTile(
                    onTap: () {},
                    title: const Text('Share'),
                    leading: const Icon(Icons.ios_share),
                  ),
                  ListTile(
                    onTap: () => _onDeleteButtonPressed(card),
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
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(currentCard, CRCFlipCardType.scrollable))),
          onLongPress: () => _showCardSecondaryMenu(context, currentCard),
          child: CRDFlipCard(currentCard, CRCFlipCardType.static)
        );
      }
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
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                icon: Icons.more_horiz,
                label: 'More',
                backgroundColor: Colors.blue,
                onPressed: (context) => _showCardSecondaryMenu(context, currentCard)
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: ListTile(
              title: Text(currentCard.className),
              subtitle: Text('${currentCard.responsibilities.length} responsibilities\n${currentCard.collaborators.length} collaborators'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleCardView(currentCard, CRCFlipCardType.scrollable))),
              onLongPress: () => _showCardSecondaryMenu(context, currentCard),
            ),
          ),
        );

      }
    );
  }

  Widget _buildCardList(CRCCardStack stack) {
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
        future: cardModel.loadDataWithForeign(CRC_DBWorker.db,widget._stack.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if(widget._stack.cards.length != cardModel.entityList.length) {
              widget._stack.cards.clear();
              widget._stack.addAllCards(cardModel.entityList);

              for (CRCCard card in widget._stack.cards) {
                card.addResponsibility(Responsibility.named('Go to class'));
                card.addResponsibility(Responsibility.named('Do homework'));
                card.addResponsibility(Responsibility.named('Graduate with 4.0'));

                card.note = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse vel vehicula arcu. Fusce ut tellus in nisi egestas porttitor. Proin sed justo eleifend metus egestas pulvinar. Integer sit amet tortor egestas, pellentesque nunc eu, semper mi. Morbi elementum dolor vel nulla molestie, eget viverra ipsum tincidunt. Nulla molestie et nisl sit amet efficitur. Donec leo dolor, sollicitudin id mattis iaculis, posuere pretium enim. Mauris eu fringilla orci. Ut molestie pharetra nunc vitae convallis. Vestibulum rhoncus sem magna, at dictum quam aliquet a. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam rhoncus turpis ac felis porttitor feugiat ac vitae lectus. Nam maximus ullamcorper dui porta facilisis. Pellentesque aliquet quam nec dui tincidunt, vitae auctor nibh tincidunt.\n\n' * 5;
              }

              for (CRCCard card in widget._stack.cards) {
                card.parentStack!.cards.where((element) => element != card).forEach((element) {
                  card.addCollaborator(element);
                });
              }
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