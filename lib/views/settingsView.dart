import 'package:flutter/material.dart';
import 'package:video_convert/objects/config.dart';

class SettingsView extends StatefulWidget {
  Config config;
  SettingsView({Key key, this.config}) : super(key: key);

  @override
  _nameState createState() => _nameState(this.config);
}

class _nameState extends State<SettingsView> {
  Config _config;
  TextEditingController _ffmpegPathTextController = TextEditingController();
  TextEditingController _ffmpegOptionsTextController = TextEditingController();

  _nameState(Config config) {
    this._config = config;
    this._ffmpegPathTextController.text = _config.ffmpegPath;
    this._ffmpegOptionsTextController.text = _config.ffmpegOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Container(
                  width: 200,
                  child: Text(
                    "FFMPEG path: ",
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 20, bottom: 20, right: 20),
                    child: TextField(
                      controller: this._ffmpegPathTextController,
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
                Container(
                  width: 200,
                  child: Text(
                    "FFMPEG options: ",
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 20, bottom: 20, right: 20),
                    child: TextField(
                      controller: this._ffmpegOptionsTextController,
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
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  child: Text("Save"),
                  minWidth: 200,
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pop(context);
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
    );
  }
}
