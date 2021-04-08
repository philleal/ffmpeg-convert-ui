import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_convert/objects/config.dart';
import 'package:video_convert/objects/convertQueueEntry.dart';
import 'package:video_convert/views/queueItemDetailView.dart';
import 'package:video_convert/views/settingsView.dart';

class MainView extends StatefulWidget {
  final String title;
  MainView({Key key, this.title}) : super(key: key);

  void start() {}
  void showAddItemToQueue(ConvertQueueEntry convertQueueEntry) async {
    mainViewState.showAddItemToQueue(convertQueueEntry);
  }

  _MainViewState mainViewState;

  @override
  _MainViewState createState() {
    mainViewState = _MainViewState();
    return mainViewState;
  }
}

class _MainViewState extends State<MainView> {
  ListQueue<ConvertQueueEntry> itemsToConvert = ListQueue<ConvertQueueEntry>();
  String _commandOutput = "This is where the output goes";
  TextEditingController outputTextEditingController =
      TextEditingController(text: "");
  Config _config;

  _MainViewState() {
    Config.loadFromFile("config.json").then((value) {
      _config = value;
      print("loaded the config");
    });
  }

  void showAddItemToQueue(ConvertQueueEntry convertQueueEntry) async {
    print(convertQueueEntry);

    final result = Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QueueItemDetailView(
                  convertQueueEntry: convertQueueEntry,
                )));

    //ConvertQueueEntry asdf = (ConvertQueueEntry)result;
    result.then((value) {
      //print(value.source);

      if (value != null) {
        this.addItemToQueue(value);
      }
    });
  }

  void addItemToQueue(ConvertQueueEntry entry) {
    setState(() {
      this.itemsToConvert.add(entry);
    });
  }

  void callFFMPEG() async {
    if (itemsToConvert.isEmpty) {
      return;
    }

    var convertQueueEntry = itemsToConvert.first;

    if (convertQueueEntry.sourceDir.startsWith("//")) {
      convertQueueEntry.sourceDir =
          convertQueueEntry.sourceDir.replaceAll("//", "/");
    }

    if (convertQueueEntry.target.startsWith("//")) {
      convertQueueEntry.target = convertQueueEntry.target.replaceAll("//", "/");
    }

    setState(() {
      convertQueueEntry.active = true;
    });

    var process = await Process.start(
      "/usr/local/bin/ffmpeg",
      [
        "-i",
        convertQueueEntry.sourceFile,
        "-vf",
        "scale=320:-1",
        convertQueueEntry.target,
      ],
      workingDirectory: convertQueueEntry.sourceDir,
    );

    process.stderr.transform(utf8.decoder).forEach((value) {
      this.outputTextEditingController.text += (value + '\n');
    });

    process.exitCode.then((value) {
      this.outputTextEditingController.text +=
          ("Exit code: " + value.toString() + '\n');
      print("the exit code is: " + value.toString());

      setState(() {
        itemsToConvert.remove(convertQueueEntry);
      });

      if (convertQueueEntry.delete == true) {
        File file = File(
            convertQueueEntry.sourceDir + "/" + convertQueueEntry.sourceFile);
        file.delete();

        this.outputTextEditingController.text += ("\n\n deleted the file: " +
            convertQueueEntry.sourceDir +
            "/" +
            convertQueueEntry.sourceFile +
            '\n\n');
      }

      callFFMPEG();
    });
  }

  List<Widget> _getMenuItems() {
    List<Widget> items = [
      /*DrawerHeader(
        child: Container(),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),*/
      ListTile(
        title: Text("Settings"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsView(config: this._config)));
        },
      )
    ];

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        children: _getMenuItems(),
      )),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Queue"),
            Expanded(
              child: ListView.builder(
                itemCount: this.itemsToConvert.length,
                itemBuilder: (BuildContext context, int index) {
                  ConvertQueueEntry currentEntry =
                      this.itemsToConvert.elementAt(index);

                  return ListTile(
                      tileColor: (currentEntry.active == true)
                          ? Colors.green
                          : Colors.white,
                      title: Text("source: " + currentEntry.sourceFile),
                      subtitle: Text("options: " + currentEntry.options),
                      trailing: IconButton(
                        icon: (currentEntry.active == true)
                            ? Icon(Icons.stop)
                            : Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            itemsToConvert
                                .remove(itemsToConvert.elementAt(index));
                          });
                        },
                      ),
                      onTap: () {
                        this.showAddItemToQueue(currentEntry);
                      });
                },
              ),
            ),
            Text("Output"),
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: this.outputTextEditingController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(5)),
                    enabled: true,
                    maxLines: null,
                    readOnly: true,
                  )),
            ),
            ButtonBar(
              buttonMinWidth: 200,
              alignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                    child: Text("Clear Output"),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        outputTextEditingController.text = "";
                      });
                    }),
                MaterialButton(
                  child: Text("Start"),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    //for (ConvertQueueEntry convertQueueEntry in this.itemsToConvert) {
                    //print(convertQueueEntry.source);
                    callFFMPEG();
                    //print("we are passed the call");
                    //}
                  },
                ),
              ],
            ),
          ],
        ), //Column(
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          this.showAddItemToQueue(null);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
