import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:testapp/camera_stream.dart';
import 'package:testapp/evaluation.dart';
import 'package:testapp/settings.dart';

enum Menu { settings, evaluate }

class Home extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Home({Key key, this.cameras}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _detectModeOn = false;
  double _appBarHeight = AppBar().preferredSize.height;

  // Settings default values
  int _resolution = 2;
  double _framerate = 1.0;
  String _model = 'ssd_mobilenet';

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
                case Menu.evaluate:
                  widget = Evaluation();
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
        _model,
        _detectModeOn,
        _appBarHeight,
      ),
    );
  }
}
