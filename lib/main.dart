import 'package:flutter/material.dart';
import 'views/mainView.dart';
import 'views/settingsView.dart';
import 'objects/config.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainView(title: 'Video Converter'),
    );
  }
}
