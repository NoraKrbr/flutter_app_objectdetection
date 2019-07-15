import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class Evaluate extends StatefulWidget {
  @override
  _EvaluateState createState() => _EvaluateState();
}

class _EvaluateState extends State<Evaluate> {
  var _time = 0.0;
  var _finishedEval = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluate'),
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: RaisedButton(
                onPressed: () async => _evaluate(),
                child: Text('Start Evaluation'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _showText(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showText() {
    if(_finishedEval) {
      return Text('Evaluation took $_time seconds.');
    }
    else {
      return Text('');
    }
  }

  Future<void> _evaluate() async {
    final externalStorageDirectory = await getExternalStorageDirectory();
    final directory = Directory('${externalStorageDirectory.path}/test');

    final stopwatch = Stopwatch()..start();

    final results = await directory
        .list()
        .map((entity) => entity.path)
        .asyncMap((path) async => Pair(
            await Tflite.detectObjectOnImage(path: path, asynch: false), path))
        .map((recognitionsToPath) {
      final recognitions = recognitionsToPath.first;
      final path = recognitionsToPath.second;
      final listOfMaps = _toListOfMaps(recognitions);
      return Pair(listOfMaps, path);
    }).map((recognitionsToPath) {
      final recognitions = recognitionsToPath.first;
      final path = recognitionsToPath.second;
      return _buildImageRecognition(recognitions, path);
    }).fold<List<Map<String, dynamic>>>(<Map<String, dynamic>>[],
            (previous, element) {
      previous.add(element);
      return previous;
    });

    final elapsedTime = stopwatch.elapsedMilliseconds;
    print('Images got processed in $elapsedTime ms.');
    setState(() {
      _time = elapsedTime / 1000.0;
      _finishedEval = true;
    });

    final json = jsonEncode(results);
    print(json);

    final path = externalStorageDirectory.path;
    await File('$path/results.json').writeAsString(json);
  }

  Map<String, dynamic> _buildImageRecognition(
    List<Map> recognitions,
    String path,
  ) {
    final predictions = recognitions.map((recognition) {
      final boundingBox = recognition['rect'] as Map<dynamic, dynamic>;
      final confidence = recognition['confidenceInClass'];
      final clazz = recognition['detectedClass'];

      return <String, dynamic>{
        'boundingBox': boundingBox,
        'confidence': confidence,
        'class': clazz
      };
    }).toList();

    return <String, dynamic>{
      'id': path,
      'preds': predictions,
    };
  }

  List<Map> _toListOfMaps(List recognitions) {
    return recognitions
        .map((recognition) => recognition as Map<dynamic, dynamic>)
        .toList();
  }
}

class Pair<T, S> {
  final T first;
  final S second;

  Pair(this.first, this.second);
}
