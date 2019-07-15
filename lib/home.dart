import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:testapp/bluetooth/bluetooth.dart';
import 'package:testapp/camera_stream.dart';
import 'package:testapp/evaluate.dart';
import 'package:testapp/lndw/recognition_heuristic.dart';
import 'package:testapp/settings.dart';

enum Menu { settings, bluetooth, evaluate }

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

  // Settings
  int _resolution = 2;
  double _framerate = 1.0;

  setBluetooth(device, recognitionThreshold, landscapeCutOff) {
    setState(() {
      _device = device;
      _recognitionThreshold = recognitionThreshold;
      _landscapeCutOff = landscapeCutOff;
    });
  }

  setSettings(resolution, framerate) {
    setState(() {
      _resolution = resolution;
      _framerate = framerate;
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
            onSelected: (Menu result) {
              Widget widget;

              switch (result) {
                case Menu.settings:
                  widget = Settings(setSettings, _resolution, _framerate);
                  break;
                case Menu.bluetooth:
                  widget = Bluetooth(setBluetooth);
                  break;
                case Menu.evaluate:
                  widget = Evaluate();
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
                    value: Menu.evaluate,
                    child: Text('Evaluate'),
                  ),
                ],
          )
        ],
      ),
      body: CameraStream(
        widget.cameras,
        _resolution,
        _framerate,
        setRecognitions,
        _detectModeOn,
        _appBarHeight,
      ),
    );
  }
}
