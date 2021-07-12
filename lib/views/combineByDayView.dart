import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_convert/objects/dbsqlite.dart';
import 'package:video_convert/objects/fileEntry.dart';

class CombineByDateView extends StatefulWidget {
  CombineByDateView({
    Key key,
    this.date,
    this.db,
  }) : super(key: key);

  String title = "Day View";
  String date = "";
  DbSqlite db;

  @override
  _CombineByDateViewState createState() => _CombineByDateViewState();
}

class _CombineByDateViewState extends State<CombineByDateView> {
  bool loadDataCalled = false;
  List<FileEntry> groupedFiles = [];

  @override
  Widget build(BuildContext context) {
    loadData(widget.date);

    return Scaffold(
      /*drawer: Drawer(
          child: ListView(
        children: _getMenuItems(),
      )),*/
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: groupedFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        '${groupedFiles[index].createDate} ${groupedFiles[index].path}',
                      ),
                      onTap: () {
                        print(
                          "${groupedFiles[index]} was clicked",
                        );
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> loadData(String date) async {
    if (loadDataCalled == false) {
      var temp = await widget.db.groupFilesByDateCreated(date);
      setState(() {
        groupedFiles = temp;
        loadDataCalled = true;
      });
    }
  }
}
