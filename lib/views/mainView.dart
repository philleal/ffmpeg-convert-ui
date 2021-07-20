import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_convert/objects/config.dart';
import 'package:video_convert/objects/convertQueueEntry.dart';
import 'package:video_convert/views/queueItemDetailView.dart';
import 'package:video_convert/views/settingsView.dart';
import 'package:video_convert/objects/dbsqlite.dart';
import 'dart:isolate';

class MainView extends StatefulWidget {
  final String title;

  MainView({Key key, this.title}) : super(key: key);

  //void start() {}
  void showAddItemToQueue(ConvertQueueEntry convertQueueEntry) async {
    mainViewState.showAddItemToQueue(convertQueueEntry);
  }

  _MainViewState mainViewState;

  @override
  _MainViewState createState() {
    mainViewState = _MainViewState();

    //widget.db = DbSqlite();
    //widget.db.initDb();

    //db.initDb();

    print("after init");

    return mainViewState;
  }
}

entryPoint(SendPort sendPort) async {
  Config config;
  //bool configReceived = false;
  List<String> allOptions;
  //bool allOptionsReceived = false;
  String sourceDir = "";
  //bool sourceDirReceived = false;
  ConvertQueueEntry convertQueueEntry;
  //bool convertQueueEntryReceived = false;
  SendPort replyTo;

  // Open the ReceivePort to listen for incoming messages (optional)
  var port = new ReceivePort();

  // Send messages to other Isolates
  sendPort.send(port.sendPort);

  // Listen for messages (optional)
  await for (var data in port) {
    // `data` is the message received.
    //print('received $data');

    /*if (data is Config) {
      config = data;
      configReceived = true;
      //print("we got the Config");
    } else if (data is List<String>) {
      allOptions = data;
      allOptionsReceived = true;
      //print("we got the options");
    } else if (data is String) {
      sourceDir = data;
      sourceDirReceived = true;
      //print("we got the sourceDir");
    } else if (data is ConvertQueueEntry) {
      convertQueueEntry = data;
      convertQueueEntryReceived = true;
    }

    if (configReceived &&
        allOptionsReceived &&
        sourceDirReceived &&
        convertQueueEntryReceived) {
      break;
    }*/

    config = data[0];
    allOptions = data[1];
    convertQueueEntry = data[2];
    replyTo = data[3];

    break;
  }

  //for (var i = 0; i < 100; i++) {
  //replyTo.send("the value of i is: $i");
  //print("sent the message $i");
  //}

  var process = await Process.start(
    config.ffmpegPath,
    allOptions,
    workingDirectory: convertQueueEntry.sourceDir,
  );

  process.stderr.transform(utf8.decoder).forEach((value) {
    //this.outputTextEditingController.text += (value + '\n');
    replyTo.send(value);
  });

  process.exitCode.then((value) {
    //this.outputTextEditingController.text +=
    //("Exit code: ${value.toString()}\n");
    //print("the exit code is: " + value.toString());

    /*if (convertQueueEntry.delete == true) {
      File file = File(
          convertQueueEntry.sourceDir + "/" + convertQueueEntry.sourceFile);
      file.delete();

      replyTo.send(
          "deleted the file: ${convertQueueEntry.sourceDir}/${convertQueueEntry.sourceFile}");
    }*/

    replyTo.send("close()");
  });
}

class _MainViewState extends State<MainView> {
  ListQueue<ConvertQueueEntry> itemsToConvert = ListQueue<ConvertQueueEntry>();
  String _commandOutput = "This is where the output goes";
  TextEditingController outputTextEditingController =
      TextEditingController(text: "");
  Config _config;
  DbSqlite db = DbSqlite();
  bool _conversionFailed = false;

  _MainViewState() {
    Config.loadFromFile("config.json").then((value) {
      _config = value;
      print("loaded the config");
    });

    init();
  }

  void init() async {
    await db.initDb();
  }

  void showAddItemToQueue(ConvertQueueEntry convertQueueEntry) async {
    //print(convertQueueEntry);

    final result = Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QueueItemDetailView(
                  convertQueueEntry: convertQueueEntry,
                  db: db,
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

    // reset this value
    _conversionFailed = false;

    var convertQueueEntry = itemsToConvert.first;

    if (convertQueueEntry.sourceDir.startsWith("//")) {
      convertQueueEntry.sourceDir =
          convertQueueEntry.sourceDir.replaceAll("//", "/");
    }

    if (convertQueueEntry.target.startsWith("//")) {
      convertQueueEntry.target = convertQueueEntry.target.replaceAll("//", "/");
    }

    if (Platform.isWindows && convertQueueEntry.sourceDir.startsWith("/")) {
      convertQueueEntry.sourceDir =
          convertQueueEntry.sourceDir.replaceFirst("/", "");
    }

    if (Platform.isWindows && convertQueueEntry.target.startsWith("/")) {
      convertQueueEntry.target = convertQueueEntry.target.replaceFirst("/", "");
    }

    setState(() {
      convertQueueEntry.active = true;
    });

    List<String> options = convertQueueEntry.options.split(" ");

    List<String> allOptions = ["-i", convertQueueEntry.sourceFile];

    for (String option in options) {
      allOptions.add(option);
    }

    allOptions.add(convertQueueEntry.target);

    var receivePort = new ReceivePort();
    var receivedPortOnExit = new ReceivePort();

    await Isolate.spawn(
      entryPoint,
      receivePort.sendPort,
      onExit: receivedPortOnExit.sendPort,
    );

    //print("we are passed it");

    // Receive the SendPort from the Isolate
    SendPort sendPort = await receivePort.first;

    // Send a message to the Isolate
    //sendPort.send(_config);
    //sendPort.send(allOptions);
    //sendPort.send(convertQueueEntry.sourceDir);
    //sendPort.send(convertQueueEntry);
    ReceivePort asdf = ReceivePort();
    sendPort.send([_config, allOptions, convertQueueEntry, asdf.sendPort]);

    receivePort.close();

    //await receivedPortOnExit.single;

    await for (String data in asdf) {
      this.outputTextEditingController.text += (data + '\n');

      if (data.trim().toLowerCase() == "conversion failed!") {
        this._conversionFailed = true;
        print("the conversion failed");
      }

      if (data == "close()") {
        asdf.close();
      }
    }

    await receivedPortOnExit.first;
    print("on exit received");

    if (convertQueueEntry.delete == true && this._conversionFailed == false) {
      File file = File(
          convertQueueEntry.sourceDir + "/" + convertQueueEntry.sourceFile);
      file.delete();

      // Check if we need to delete the file
      this.outputTextEditingController.text += ("\n\n deleted the file: " +
          convertQueueEntry.sourceDir +
          "/" +
          convertQueueEntry.sourceFile +
          '\n\n');
    }

    setState(() {
      itemsToConvert.remove(convertQueueEntry);
    });

    /*var process = await Process.start(
      _config.ffmpegPath,
      allOptions,
      workingDirectory: convertQueueEntry.sourceDir,
    );

    process.stderr.transform(utf8.decoder).forEach((value) {
      this.outputTextEditingController.text += (value + '\n');
    });

    process.exitCode.then((value) {
      this.outputTextEditingController.text +=
          ("Exit code: ${value.toString()}\n");
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
    });*/
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
