import 'package:flutter/material.dart';
import 'package:smart_crc/card_list.dart';
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
      body: ListView.builder(
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
    );
  }
}
