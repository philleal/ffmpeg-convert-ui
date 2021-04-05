class Config {
  String ffmpegPath;
  String ffmpegOptions;

  Config({this.ffmpegPath, this.ffmpegOptions});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
        ffmpegPath: json['ffmpegPath'], ffmpegOptions: json['ffmpegOptions']);
  }

  bool loadFromFile(String path) {
    this.ffmpegPath = "ffmpeg";
    this.ffmpegOptions = "-vf scale=320:-1";
    return true;
  }

  bool saveToFile(String path) {}
}
