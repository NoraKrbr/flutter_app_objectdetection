import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  Camera(this.cameras, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;

  @override
  Widget build(BuildContext context) {
    print('build()');

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    }

    return FutureBuilder<CameraController>(
      future: _getController(),
      builder: (context, snapshot) {
        final controller = snapshot.data;

        print(controller);

        var tmp = MediaQuery.of(context).size;
        var screenH = math.max(tmp.height, tmp.width);
        var screenW = math.min(tmp.height, tmp.width);
        tmp = controller.value.previewSize;
        var previewH = math.max(tmp.height, tmp.width);
        var previewW = math.min(tmp.height, tmp.width);
        var screenRatio = screenH / screenW;
        var previewRatio = previewH / previewW;

        return OverflowBox(
          maxHeight: screenRatio > previewRatio
              ? screenH
              : screenW / previewW * previewH,
          maxWidth: screenRatio > previewRatio
              ? screenH / previewH * previewW
              : screenW,
          child: CameraPreview(controller),
        );
      },
    );
  }

  @override
  void dispose() {
    print('dispose()');

    controller?.dispose();
    super.dispose();
  }

  Future<CameraController> _getController() async {
    final resolution = await _getResolution();

    controller = CameraController(
      widget.cameras[0],
      resolution,
    );

    await controller.initialize();

    if (!mounted) return null;

    controller.startImageStream((CameraImage img) {
      if (!isDetecting) {
        isDetecting = true;

        int startTime = new DateTime.now().millisecondsSinceEpoch;

        Tflite.detectObjectOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          model: "SSDMobileNet",
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: 127.5,
          imageStd: 127.5,
          numResultsPerClass: 1,
          threshold: 0.4,
        ).then((recognitions) {
          // print(recognitions);

          int endTime = new DateTime.now().millisecondsSinceEpoch;
          print("Detection took ${endTime - startTime} ms");

          widget.setRecognitions(recognitions, img.height, img.width);

          isDetecting = false;
        });
      }
    });

    return controller;
  }

  Future<ResolutionPreset> _getResolution() async {
    final prefs = await SharedPreferences.getInstance();
    int res = prefs.getInt('resolution');
    switch (res) {
      case RES_LOW:
        return ResolutionPreset.low;
      case RES_MED:
        return ResolutionPreset.medium;
      default:
        return ResolutionPreset.high;
    }
  }
}
