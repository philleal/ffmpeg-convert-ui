import 'package:flutter/material.dart';

enum ConvertType { ffmpeg }

class ConvertQueueEntry {
  String sourceDir;
  String sourceFile;
  String target;
  String options;
  ConvertType convertType;
  bool delete;
  bool active;

  ConvertQueueEntry(
      {this.sourceDir,
      this.sourceFile,
      this.target,
      this.options,
      this.convertType,
      this.delete,
      this.active});
}
