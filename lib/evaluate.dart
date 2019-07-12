import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class Evaluate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluate'),
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RaisedButton(
                onPressed: () async => evaluate(),
                child: Text('Start Evaluation'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> evaluate() async {
    final externalStorageDirectory = await getExternalStorageDirectory();
    final directory = Directory('${externalStorageDirectory.path}/test');

    final outerMap = <String, dynamic>{};

    directory
        .list()
        .map((entity) => entity.path)
        .asyncMap((path) async =>
            await Tflite.detectObjectOnImage(path: path, asynch: false))
        .map((recognitions) => toListOfMaps(recognitions))
        .map((recognitions) => buildImageRecognition(recognitions))
        .listen((recognitions) async {
      print(recognitions);
    }, onDone: () {
      print('onDone');
    });
  }

  Map<String, dynamic> buildImageRecognition(List<Map> recognitions) {
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
      'id': 'path',
      'preds': predictions,
    };
  }

  List<Map> toListOfMaps(List recognitions) {
    return recognitions
        .map((recognition) => recognition as Map<dynamic, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> foo(String path) async {
    final recognitions =
        await Tflite.detectObjectOnImage(path: path, asynch: false);
    print(recognitions);

    return <String, dynamic>{};
  }
}
