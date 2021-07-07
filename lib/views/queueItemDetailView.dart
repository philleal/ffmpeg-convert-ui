import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:video_convert/objects/convertQueueEntry.dart';
import 'dart:io';

import 'package:video_convert/objects/dbsqlite.dart';

class QueueItemDetailView extends StatefulWidget {
  ConvertQueueEntry convertQueueEntry;
  DbSqlite db;
  QueueItemDetailView({Key key, this.convertQueueEntry, this.db})
      : super(key: key);

  @override
  _QueueItemDetailViewState createState() =>
      _QueueItemDetailViewState(this.convertQueueEntry);
}

class _QueueItemDetailViewState extends State<QueueItemDetailView> {
  TextEditingController sourcePathController = TextEditingController(text: "");
  TextEditingController targetPathController = TextEditingController(text: "");
  TextEditingController optionsPathController =
      TextEditingController(text: "-vf scale=320:-1");
  FilePickerCross sourceFile;
  bool deleteFile = false;

  _QueueItemDetailViewState(ConvertQueueEntry convertQueueEntry) {
    if (convertQueueEntry == null) {
      print("it is null");
    } else {
      print("it is not null");

      sourcePathController.text = convertQueueEntry.sourceFile;
      targetPathController.text = convertQueueEntry.sourceFile;
      optionsPathController.text = convertQueueEntry.options;
      deleteFile = convertQueueEntry.delete;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: Text('Queue Item Detail'),
              bottom: TabBar(tabs: [
                Tab(text: "Convert"),
                Tab(text: "Combine"),
              ])),
          body: TabBarView(children: [
            Container(
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    child: Text("Select Source"),
                    minWidth: 200,
                    onPressed: () async {
                      FilePickerCross myFile =
                          await FilePickerCross.importFromStorage(
                              type: FileTypeCross
                                  .video, // Available: `any`, `audio`, `image`, `video`, `custom`. Note: not available using FDE
                              fileExtension:
                                  //'txt, md' // Only if FileTypeCross.custom . May be any file extension like `dot`, `ppt,pptx,odp`
                                  'mp4');

                      print(myFile.directory);
                      print(myFile.fileName);

                      this.sourceFile = myFile;

                      sourcePathController.text =
                          myFile.directory + "/" + myFile.fileName;

                      targetPathController.text =
                          myFile.directory + "/" + "new_" + myFile.fileName;
                    },
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 20, bottom: 20, right: 20, left: 20),
                          child: TextField(
                            controller: this.sourcePathController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: "Source"),
                            enabled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 20, bottom: 20, right: 20, left: 20),
                          child: TextField(
                            controller: this.targetPathController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "target",
                            ),
                            enabled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        width: 100,
                        child: Text(
                          "Options: ",
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 20, bottom: 20, right: 20),
                          child: TextField(
                            controller: this.optionsPathController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            enabled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("Delete after convert")),
                      Switch(
                          value: this.deleteFile,
                          onChanged: (value) {
                            setState(() {
                              this.deleteFile = value;
                            });
                          })
                    ],
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        child: Text("Add"),
                        minWidth: 200,
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.pop(
                              context,
                              ConvertQueueEntry(
                                sourceDir: this.sourceFile.directory,
                                sourceFile: this.sourceFile.fileName,
                                target: targetPathController.text,
                                options: optionsPathController.text,
                                delete: this.deleteFile,
                              ));
                        },
                      ),
                      MaterialButton(
                        child: Text("Cancel"),
                        minWidth: 200,
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: MaterialButton(
                child: Text("press it"),
                minWidth: 200,
                onPressed: () async {
                  var myDir = Directory('D:/Development/JDK/untitled folder');
                  List<FileSystemEntity> files = myDir.listSync();
                  for (File file in files) {
                    //print(file.path);
                    //print(file.lastModifiedSync());

                    if (widget.db != null) {
                      widget.db.insert(file.path);
                    }
                  }
                },
                color: Colors.blue,
                textColor: Colors.white,
              ),
            ),
          ]),
        ));

    ;
  }
}
