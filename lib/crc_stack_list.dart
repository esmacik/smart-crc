import 'package:flutter/material.dart';
import 'package:smart_crc/card_list.dart';
import 'package:smart_crc/database/STACK_DBWorker.dart';
import 'package:smart_crc/model/crc_card_stack.dart';

class CRCStackList extends StatefulWidget {

  final List<CRCCardStack> _crcCardStacks;

  const CRCStackList(this._crcCardStacks, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CRCStackListState();
}

class _CRCStackListState extends State<CRCStackList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stack List')
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
            // print("EL:"+ cardModel.entityList.length.toString());
            // print('WL:'+widget._stack.cards.length.toString());
            return SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                child: ListView.builder(
                    itemCount: widget._crcCardStacks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(widget._crcCardStacks.elementAt(index).name),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => CardList(widget._crcCardStacks.elementAt(index))
                          )
                        ),
                      );
                    }
                  ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator(),);
          }
        },
      ),
      // ),
      // body: ListView.builder(
      //   itemCount: widget._crcCardStacks.length,
      //   itemBuilder: (context, index) {
      //     return ListTile(
      //       title: Text(widget._crcCardStacks.elementAt(index).name),
      //       onTap: () => Navigator.of(context).push(
      //         MaterialPageRoute(
      //           builder: (BuildContext context) => CardList(widget._crcCardStacks.elementAt(index))
      //         )
      //       ),
      //     );
      //   }
      // ),
    );
  }
}
