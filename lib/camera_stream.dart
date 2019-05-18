import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bounding_box.dart';

class CameraStream extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraStream(this.cameras);

  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  bool _detectModeOn = false;

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String res = await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
    print(res);
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    // TODO: fix bounding box position
    final double appBarHeight = AppBar().preferredSize.height;
    loadModel();
    return Scaffold(
      body: Stack(
        children: [
          Camera(widget.cameras, setRecognitions, _detectModeOn),
          BoundingBox(
            getRecognitions(),
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
          ),
          Switch(
              value: _detectModeOn,
              onChanged: (value) => setState(() => _detectModeOn = value)
          ),
        ],
      ),
    );
  }

  List<dynamic> getRecognitions() {
    return _recognitions == null ? [] : _detectModeOn ? _recognitions : [];
  }
}
