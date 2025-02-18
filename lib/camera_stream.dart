import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bounding_box.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class CameraStream extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int resolution;
  final double framerate;
  final String model;
  final Callback setRecognitions;
  final bool detectModeOn;
  final double appBarHeight;

  CameraStream(this.cameras, this.resolution, this.framerate, this.model, this.setRecognitions, this.detectModeOn, this.appBarHeight);

  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  bool _detectModeOn = false;
  int _resolution;
  int _framerate;
  String _model;

  @override
  void initState() {
    _resolution = widget.resolution;
    _framerate = widget.framerate.floor();
    _model = widget.model;
    super.initState();
  }

  loadModel(_model) async {
    await Tflite.loadModel(
        model: "assets/$_model.tflite",
        labels: "assets/coco_20_labels.txt");
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
    // pass recognitions to parent widget
    widget.setRecognitions(_recognitions, _imageHeight, _imageWidth);
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    loadModel(_model);
    return Scaffold(
      body: Stack(
        children: [
          Camera(widget.cameras, setRecognitions, _detectModeOn, _resolution, _framerate, "SSDMobileNet"),
          BoundingBox(
              getRecognitions(),
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
              widget.appBarHeight
            ),
        ],
      ),
    );
  }

  List<dynamic> getRecognitions() {
    return _recognitions == null ? [] :
      _detectModeOn ? _recognitions : [];
  }

  @override
  void didUpdateWidget(CameraStream oldWidget) {
    setState(() {
      _resolution = widget.resolution;
      _framerate = widget.framerate.floor();
      _detectModeOn = widget.detectModeOn;
      _model = widget.model;
    });
    super.didUpdateWidget(oldWidget);
  }
}
