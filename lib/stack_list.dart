import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_crc/card_list.dart';
import 'package:smart_crc/database/CRC_DBWorker.dart';
import 'package:smart_crc/database/STACK_DBWorker.dart';
import 'package:smart_crc/file_writer.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

import 'package:smart_crc/preferences.dart';

import 'model/crc_card.dart';

enum StackListType {
  full,
  compact
}

class StackList extends StatefulWidget {

  final List<CRCCardStack> _crcCardStacks = List.empty(growable: true);

  StackList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StackListState();
}

class _StackListState extends State<StackList> with Preferences, FileWriter {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stackNameController = TextEditingController();

  Widget _buildStackWidget(CRCCardStack stack) {
    print('Length: ${stack.cards.length}');
    return Stack(
      fit: StackFit.loose,
      children: stack.cards.map((card) {
        return Transform.rotate(
          //angle: pi/((stack.cards.indexOf(card)+1) * pi),
          angle: (stack.cards.length - stack.cards.indexOf(card)) * pi / 45,
          child: Card(
            elevation: 20,
            child: AspectRatio(aspectRatio: 2,),
          ),
        ) as Widget;
      }).toList().take(5).toList()..add(
        AspectRatio(
          aspectRatio: 2/1,
          child: Card(
            elevation: 20,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      stack.name,
                      textScaleFactor: 2
                  ),
                  Text('${stack.numCards} cards')
                ]
            ),
          ),
        )
      )
    );
  }

  void _showStackSecondaryMenu(BuildContext context, CRCCardStack stack) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: BottomSheet(
            onClosing: () {},
            builder: (context) {
              return ListView(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                shrinkWrap: true,
                children: [
                  Center(child: Text(stack.name, textScaleFactor: 2,)),
                  ListTile(
                    onTap: () async {
                      await _onRenamePressed(stack);
                      Navigator.of(context).pop();
                    },
                    leading: const Icon(Icons.edit),
                    title: const Text('Rename'),
                  ),
                  ListTile(
                    onTap: () async {
                      String contents = jsonEncode(stack.toMap());
                      String writtenFilePath = await writeFile('${stack.name.replaceAll(' ', '_')}_stack', contents);
                      Share.shareFiles([writtenFilePath]);
                    },
                    leading: const Icon(Icons.ios_share),
                    title: const Text('Share'),
                  ),
                  ListTile(
                    onTap: () {
                      _onDeletePressed(stack);
                      Navigator.of(context).pop();
                    },
                    leading: const Icon(Icons.delete, color: Colors.red,),
                    title: Text('Delete ${stack.name}',
                      style: const TextStyle(
                        color: Colors.red
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        );
      }
    );
  }

  void _onDeletePressed(CRCCardStack stack) {
    STACK_DBWorker.db.delete(stack.id).then((value) => setState(() {}));
  }

  Widget _buildFullStackList(Iterable<CRCCardStack> stacks) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 32, 8, 8),
      itemCount: widget._crcCardStacks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 40,
        childAspectRatio: 1.75
      ),
      itemBuilder: (context, index) {
        CRCCardStack currentStack = widget._crcCardStacks.elementAt(index);
        return GestureDetector(
          child: _buildStackWidget(currentStack),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => CardList(currentStack)
              )
            );
            setState(() {});
          },
          onLongPress: () => _showStackSecondaryMenu(context, currentStack),
        );
      }
    );
  }

  Widget _buildCompactStackList(Iterable<CRCCardStack> stacks) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      itemCount: stacks.length,
      itemBuilder: (context, index) {
        CRCCardStack currStack = stacks.elementAt(index);
        return ListTile(
          title: Text(currStack.name),
          subtitle: Text('${currStack.numCards} cards'),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CardList(currStack)));
            setState(() {});
          },
          onLongPress: () => _showStackSecondaryMenu(context, currStack),
        );
      }
    );
  }

  Widget _buildStackList(Iterable<CRCCardStack> stacks) {
    if (stacks.isEmpty) {
      return const Center(
        child: Text('Create your first CRC Card Stack with the add button below.',
          textAlign: TextAlign.center),
      );
    } else if (Preferences.stackListType == StackListType.full) {
      return _buildFullStackList(stacks);
    } else {
      return _buildCompactStackList(stacks);
    }
  }

  Future<String?> _showStackNameDialog() {
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            title: Text('Stack name'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter a unique stack name.'),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _stackNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a stack name.';
                      } else if (widget._crcCardStacks.where((element) => element.name.toLowerCase() == value.toLowerCase()).isNotEmpty) {
                        return 'New stack name must be unique';
                      }
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _stackNameController.clear();
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel', style: const TextStyle(color: Colors.red),)
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String stackName = _stackNameController.text;
                    _stackNameController.clear();
                    Navigator.of(context).pop(stackName);
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

  void _onAddButtonPressed() async {
    String? newStackName = await _showStackNameDialog();
    if (newStackName != null) {
      CRCCardStack newStack = CRCCardStack.empty(newStackName);
      int stackId = await STACK_DBWorker.db.create(newStack);
      setState(() {
        newStack.id = stackId;
      });
    }
  }

  Future<void> _onRenamePressed(CRCCardStack stack) async {
    String? newStackName = await _showStackNameDialog();
    if (newStackName != null) {
      stack.name = newStackName;
      await STACK_DBWorker.db.update(stack).then((value) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Stack List'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info)
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: Icon(Icons.menu)
            )
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            SwitchListTile(
              title: Text('Use compact stack view'),
              value: Preferences.stackListType == StackListType.compact ? true : false,
              onChanged: (switchOn) {
                setState(() => Preferences.stackListType = switchOn ? StackListType.compact : StackListType.full);
              }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _onAddButtonPressed(),
      ),
      body: FutureBuilder<void>(
        future: Future.wait([stackModel.loadData(STACK_DBWorker.db)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //if(widget._crcCardStacks.length != stackModel.entityList.length) {
              widget._crcCardStacks.clear();
              widget._crcCardStacks.addAll(stackModel.entityList);
            //}
            print("E:"+ stackModel.entityList.toString());
            return SafeArea(
              bottom: false,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin:  Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [
                          0.1,
                          0.40,
                          1
                        ],
                        colors: [
                          Color(0xFF65777B),
                          Color(0xFF4A5659),
                          Color(0xFF2F3739)
                        ]
                    )
                ),
                child: _buildStackList(widget._crcCardStacks),
              )
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
