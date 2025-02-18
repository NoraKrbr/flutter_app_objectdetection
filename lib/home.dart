import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:testapp/bluetooth/bluetooth.dart';
import 'package:testapp/camera_stream.dart';
import 'package:testapp/annotation.dart';
import 'package:testapp/lndw/recognition_heuristic.dart';
import 'package:testapp/settings.dart';

enum Menu { settings, bluetooth, annotate }

class Home extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Home({Key key, this.cameras}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> _recognitions;
  bool _detectModeOn = false;

  double _appBarHeight = AppBar().preferredSize.height;

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      // _imageHeight = imageHeight;
      // _imageWidth = imageWidth;
    });
    if (_device != null)
      RecognitionHeuristic().sendRequestBasedOnRecognitions(
          _recognitions, _device, _recognitionThreshold, _landscapeCutOff);
  }

  // Bluetooth State
  FlutterBluetoothSerial _device;
  double _recognitionThreshold;
  double _landscapeCutOff;

  // Settings and default values
  int _resolution = 2;
  double _framerate = 1.0;
  String _model = 'ssd_mobilenet';

  setBluetooth(device, recognitionThreshold, landscapeCutOff) {
    setState(() {
      _device = device;
      _recognitionThreshold = recognitionThreshold;
      _landscapeCutOff = landscapeCutOff;
    });
  }

  setSettings(resolution, framerate, model) {
    setState(() {
      _resolution = resolution;
      _framerate = framerate;
      _model = model;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
        actions: <Widget>[
          Switch(
              value: _detectModeOn,
              onChanged: (value) => setState(() => _detectModeOn = value)),
          PopupMenuButton<Menu>(
            onSelected: (Menu chosen) {
              Widget widget;

              switch (chosen) {
                case Menu.settings:
                  widget =
                      Settings(setSettings, _resolution, _framerate, _model);
                  break;
                case Menu.bluetooth:
                  widget = Bluetooth(setBluetooth);
                  break;
                case Menu.annotate:
                  widget = Annotation();
                  break;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widget),
              );
            },
            itemBuilder: (context) => <PopupMenuEntry<Menu>>[
                  PopupMenuItem(
                    value: Menu.settings,
                    child: Text('Settings'),
                  ),
                  PopupMenuItem(
                    value: Menu.bluetooth,
                    child: Text('Bluetooth'),
                  ),
                  PopupMenuItem(
                    value: Menu.annotate,
                    child: Text('Annotate'),
                  ),
                ],
          )
        ],
      ),
      body: CameraStream(
        widget.cameras,
        _resolution,
        _framerate,
        _model,
        setRecognitions,
        _detectModeOn,
        _appBarHeight,
      ),
    );
  }
}
