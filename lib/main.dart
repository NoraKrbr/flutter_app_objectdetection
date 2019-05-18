import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:testapp/app_state.dart';
import 'package:testapp/bluetooth/bluetooth.dart';
import 'package:testapp/home.dart';

import 'settings.dart';
// import 'bluetooth.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  final appState = AppState();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(
    ScopedModel<AppState>(model: appState, child: App(cameras: cameras)),
  );
}

class App extends StatelessWidget {
  final List<CameraDescription> cameras;

  const App({Key key, @required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Home(cameras: cameras),
      routes: <String, WidgetBuilder>{
        '/settings': (BuildContext context) => Settings(),
        '/bluetooth': (BuildContext context) => Bluetooth(),
      },
    );
  }
}
