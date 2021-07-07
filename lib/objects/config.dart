import 'dart:convert';
import 'dart:io';

class Config {
  String ffmpegPath;
  String ffmpegOptions;

  Config({this.ffmpegPath, this.ffmpegOptions});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
        ffmpegPath: json['ffmpegpath'], ffmpegOptions: json['ffmpegoptions']);
  }

  Map toJson() => {
        'ffmpegpath': ffmpegPath,
        'ffmpegoptions': ffmpegOptions,
      };

  static Future<Config> loadFromFile(String path) async {
    //String ffmpegPath = "ffmpeg";
    //String ffmpegOptions = "-vf scale=320:-1";

    Config c;

    try {
      File file = File("./$path");

      String jsonData = await file.readAsString();

      Map configMap = jsonDecode(jsonData);

      c = Config.fromJson(configMap);
    } catch (exception) {
      print(exception);
    }

    if (c == null) {
      print("config is null");

      c = new Config(ffmpegPath: "ffmpeg", ffmpegOptions: "-vf scale=320:-1");

      c.saveToFile("./$path");
    } else {
      print("config is not null");
    }

    return c;

    //return true;
  }

  bool saveToFile(String path) {
    File file = File("./" + path);

    var data = this.toJson();

    file.writeAsString(jsonEncode(data));

    return true;
  }
}
