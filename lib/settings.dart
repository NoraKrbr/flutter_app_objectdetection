import 'package:flutter/material.dart';

const RES_LOW = 0;
const RES_MED = 1;
const RES_HIGH = 2;

typedef void Callback(int resolution, double framerate, String settings);

class Settings extends StatefulWidget {
  final Callback setSettings;
  final int resolution;
  final double framerate;
  final String model;

  Settings(this.setSettings, this.resolution, this.framerate, this.model);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _resolution;
  double _framerate;
  String _model;

  @override
  initState() {
    super.initState();
    _resolution = widget.resolution;
    _framerate = widget.framerate;
    _model = widget.model;
  }

  Future<bool> _setSettings() {
    widget.setSettings(_resolution, _framerate, _model);
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _setSettings(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Model',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Radio(
                              onChanged: (model) => setState(() => _model = model),
                              groupValue: _model,
                              value: "SSDMobileNet",
                            ),
                            Text('SSD'),
                            Radio(
                              onChanged: (model) => setState(() => _model = model),
                              groupValue: _model,
                              value: "YOLO",
                            ),
                            Text('YOLO'),
                            Radio(
                              onChanged: (model) => setState(() => _model = model),
                              groupValue: _model,
                              value: "FasterRCNN",
                            ),
                            Text('Faster R-CNN'),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Resolution',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Radio(
                              onChanged: (res) => setState(() => _resolution = res),
                              groupValue: _resolution,
                              value: RES_LOW,
                            ),
                            Text('Low'),
                            Radio(
                              onChanged: (res) => setState(() => _resolution = res),
                              groupValue: _resolution,
                              value: RES_MED,
                            ),
                            Text('Medium'),
                            Radio(
                              onChanged: (res) => setState(() => _resolution = res),
                              groupValue: _resolution,
                              value: RES_HIGH,
                            ),
                            Text('High'),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Framerate",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Slider(
                        activeColor: Colors.white,
                        min: 1,
                        max: 25,
                        onChanged: (newRating) =>
                            setState(() => _framerate = newRating),
                        value: _framerate,
                      ),
                    ),
                    Container(
                        width: 80.0,
                        alignment: Alignment.center,
                        child: Text(
                            (_framerate.floor()).toStringAsFixed(0) + " fps"))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
