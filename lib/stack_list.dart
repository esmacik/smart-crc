import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_crc/card_list.dart';
import 'package:smart_crc/database/STACK_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'dart:math';

import 'package:smart_crc/preferences.dart';

enum StackListType {
  full,
  compact
}

class StackList extends StatefulWidget {

  final List<CRCCardStack> _crcCardStacks;

  const StackList(this._crcCardStacks, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StackListState();
}

class _StackListState extends State<StackList> with Preferences {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stackNameController = TextEditingController();

  Widget _buildStackWidget(CRCCardStack stack) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Transform.rotate(
          angle: -pi / 20,
          child: const Card(
            elevation: 20,
            child: AspectRatio(aspectRatio: 2),
          ),
        ),
        Transform.rotate(
          angle: pi / 20,
          child: const Card(
            elevation: 20,
            child: AspectRatio(aspectRatio: 2),
          ),
        ),
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
      ],
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
                    onTap: () => _onRenamePressed(stack),
                    leading: const Icon(Icons.edit),
                    title: const Text('Rename'),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.ios_share),
                    title: const Text('Share'),
                  ),
                  ListTile(
                    onTap: () => _onDeletePressed(stack),
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => CardList(currentStack)
              )
            );
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
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CardList(currStack))),
          onLongPress: () => _showStackSecondaryMenu(context, currStack),
        );
      }
    );
  }

  Widget _buildStackList(Iterable<CRCCardStack> stacks) {
    if (Preferences.stackListType == StackListType.full) {
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
      STACK_DBWorker.db.create(newStack).then((value) => setState(() {}));
    }
  }

  void _onRenamePressed(CRCCardStack stack) async {
    String? newStackName = await _showStackNameDialog();
    if (newStackName != null) {
      stack.name = newStackName;
      STACK_DBWorker.db.update(stack).then((value) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        onPressed: () => _onAddButtonPressed(),
      ),
      body: FutureBuilder<void>(
        future: stackModel.loadData(STACK_DBWorker.db),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if(widget._crcCardStacks.length != stackModel.entityList.length) {
              widget._crcCardStacks.clear();
              widget._crcCardStacks.addAll(stackModel.entityList);
            }
            print("E:"+ stackModel.entityList.toString());
            return SafeArea(
              bottom: false,
              child: _buildStackList(widget._crcCardStacks),
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
