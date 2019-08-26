import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class Evaluation extends StatefulWidget {
  @override
  _EvaluationState createState() => _EvaluationState();
}

class _EvaluationState extends State<Evaluation> {
  var _annotationTime = 0;
  var _detectionTime = 0;
  var _finishedAnnotation = false;
  var _finishedDetection = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluation'),
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: RaisedButton(
                onPressed: () async => _annotateValidationData(),
                child: Text('Start Annotation'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _showText('Annotation', _annotationTime),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: RaisedButton(
                onPressed: () async => _detectValidationImages(),
                child: Text('Start Detection'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _showText('Detection', _detectionTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showText(String task, int time) {
    if ((task == 'Detection' && !_finishedDetection) ||
        (task == 'Annotation' && !_finishedAnnotation)) {
      return Text('');
    }
    return Text('$task took $time ms.');
  }

  Future<void> _detectValidationImages() async {
    final externalStorageDirectory = await getExternalStorageDirectory();
    final directory = Directory('${externalStorageDirectory.path}/val2017');
    print('starting detection on COCO val2017 set');
    final stopwatch = Stopwatch()..start();

    directory
        .list()
        .map((entity) => entity.path)
        .asyncMap((path) async =>
            await Tflite.detectObjectOnImage(path: path, asynch: false))
        .listen((_) {}, onDone: () {
      final elapsedTime = stopwatch.elapsedMilliseconds;
      print('Object detection on all images took $elapsedTime ms.');
      setState(() {
        _detectionTime = elapsedTime;
        _finishedDetection = true;
      });
    });

    final path = externalStorageDirectory.path;
    await File('$path/results.json').writeAsString('test');
  }

  Future<void> _annotateValidationData() async {
    final externalStorageDirectory = await getExternalStorageDirectory();
    final directory = Directory('${externalStorageDirectory.path}/val2017');
    print('starting annotation on COCO val2017 set');

    final stopwatch = Stopwatch()..start();

    final results = await directory
        .list() // returns Stream<FileSystemEntity>
        .map((entity) => entity.path) // returns only image path to each entity
        .asyncMap((path) async => Pair(
            // Pair creates a tuple to pass down the path for saving, asyncMap waits for Future to complete
            await Tflite.detectObjectOnImage(path: path, asynch: false),
            // set asynch to false to wait for completion
            path)) // detectObjectOnImage returns Future with recognitions
        .map((recognitionsToPath) {
      final recognitions = recognitionsToPath.first;
      final path = recognitionsToPath.second;
      final listOfMaps = _toListOfMaps(
          recognitions); // convert List<dynamic> from detectObjectOnImage to a List<Map<dynamic, dynamic>>
      return Pair(listOfMaps, path);
    }).map((recognitionsToPath) {
      final recognitions = recognitionsToPath.first;
      final path = recognitionsToPath.second;
      return _buildImageRecognition(recognitions,
          path); // build the map for each recognition that will be converted to json
    }).fold<List<Map<String, dynamic>>>(<Map<String, dynamic>>[],
            (previous, element) {
      previous.add(element);
      return previous;
      // fold all maps into one for json conversion
    });

    final elapsedTime = stopwatch.elapsedMilliseconds;
    print('Annotation of images took $elapsedTime ms.');
    setState(() {
      _annotationTime = elapsedTime;
      _finishedAnnotation = true;
    });

    final json = jsonEncode(results);

    final path = externalStorageDirectory.path;
    await File('$path/results.json').writeAsString(json);
  }

  Map<String, dynamic> _buildImageRecognition(
      List<Map> recognitions, String path) {
    final predictions = recognitions.map((recognition) {
      final boundingBox = recognition['rect'] as Map<dynamic, dynamic>;
      final confidence = recognition['confidenceInClass'];
      final clazz = recognition['detectedClass'];

      return <String, dynamic>{
        'BoundingBox': boundingBox,
        'Confidence': confidence,
        'Class': clazz
      };
    }).toList();

    return <String, dynamic>{
      'ID': path,
      'Predictions': predictions,
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
