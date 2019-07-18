import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class Annotation extends StatefulWidget {
  @override
  _AnnotationState createState() => _AnnotationState();
}

class _AnnotationState extends State<Annotation> {
  var _time = 0.0;
  var _finishedAnnotation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Annotation'),
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: RaisedButton(
                onPressed: () async => _annotate(),
                child: Text('Start Annotation'),
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
    if (_finishedAnnotation) {
      return Text('Evaluation took $_time seconds (${_time/60} minutes).');
    } else {
      return Text('');
    }
  }

  Future<void> _annotate() async {
    final externalStorageDirectory = await getExternalStorageDirectory();
    final directory = Directory('${externalStorageDirectory.path}/test');
    print('starting evaluation on val2017');

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
    print('Images got processed in $elapsedTime ms.');
    setState(() {
      _time = elapsedTime / 1000.0;
      _finishedAnnotation = true;
    });

    final json = jsonEncode(results);
//    print(json);

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
