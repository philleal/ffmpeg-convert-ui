import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:io';

//import 'package:file_picker/file_picker.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:video_convert/objects/convertQueueEntry.dart';
import 'package:video_convert/views/queueItemDetailView.dart';

class MainView extends StatefulWidget {
  AppBar _appBar;
  MainView({Key key}) : super(key: key);
  void start() {}
  void showAddItemToQueue(ConvertQueueEntry convertQueueEntry) async {
    mainViewState.showAddItemToQueue(convertQueueEntry);
  }

  _MainViewState mainViewState;

  @override
  //_MainViewState createState() => _MainViewState();
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

  _MainScreenState() {
    /*ConvertQueueEntry convertQueueEntry = ConvertQueueEntry();
    convertQueueEntry.source = "source: testfiletoconvert.mp4";
    convertQueueEntry.options = "options: option 1";
    itemsToConvert.add(convertQueueEntry);*/
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

  //void callFFMPEG(ConvertQueueEntry convertQueueEntry) async {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Queue"),
          Expanded(
            child: ListView.builder(
              //itemCount: _videoConvertQueue.length,
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
      ),
    );
  }
}
