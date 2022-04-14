import 'package:flutter/material.dart';
import 'package:smart_crc/card_list.dart';
import 'package:smart_crc/database/STACK_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';
import 'dart:math';

class CRCStackList extends StatefulWidget {

  final List<CRCCardStack> _crcCardStacks;

  const CRCStackList(this._crcCardStacks, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CRCStackListState();
}

class _CRCStackListState extends State<CRCStackList> {

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
            child: Center(child: Text(stack.name, textScaleFactor: 2)),
          ),
        )
      ],
    );
  }

  void _showStackLongPressMenu(BuildContext context, CRCCardStack stack) {
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
                  Center(child: Text('${stack.name}', textScaleFactor: 2,)),
                  ListTile(
                    onTap: () {},
                    leading: Icon(Icons.edit),
                    title: Text('Rename'),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.ios_share),
                    title: const Text('Share'),
                  ),
                  ListTile(
                    onTap: () {},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stack List'),
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
            CRCCardStack stack = CRCCardStack.empty("Stack");
            widget._crcCardStacks.add(stack);
            STACK_DBWorker.db.create(stack);
            // STACK_DBWorker.db.getAllTableNames();
          });
        },
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
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(8, 32, 8, 8),
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
                    onLongPress: () => _showStackLongPressMenu(context, currentStack),
                  );
                }
              ),
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
