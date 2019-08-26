import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:testapp/home.dart';

List<CameraDescription> cameras;

/* main function is from
* https://github.com/shaqian/flutter_realtime_detection/blob/master/lib/main.dart */
Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(App(cameras: cameras));
}

class App extends StatelessWidget {
  final List<CameraDescription> cameras;

  const App({Key key, @required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    return MaterialApp(
        theme: ThemeData.dark(),
        home: Home(cameras: cameras),
        debugShowCheckedModeBanner: false);
  }
}
