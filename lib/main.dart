import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_face_detector/MarkedImage.dart';
import 'package:my_flutter_face_detector/UserImagePicker.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  File _userImageFile;
  List<Face> faces = [];

  void _pickedImage(File image) async {
    _userImageFile = image;
    setState(() {});
  }

  //Face Detection
  Future<void> _getImageAndDetect() async {
    final image = FirebaseVisionImage.fromFile(_userImageFile);
    final faceDetector =
        FirebaseVision.instance.faceDetector(FaceDetectorOptions(
      mode: FaceDetectorMode.accurate,
    ));
    faces = await faceDetector.processImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("My Flutter Face Detector"),
          elevation: 0,
          backgroundColor: Colors.blue[300],
        ),
        body: Center(
          child: Column(
            children: [
              new Flexible(flex: 1,child: UserImagePicker(_pickedImage)),
              new Flexible(
                flex: 1,
                child: _userImageFile == null
                    ? Center(child: new Text("..."))
                    : FutureBuilder(
                        future: _getImageAndDetect(),
                        builder: (context, data) {
                          if (data.connectionState == ConnectionState.done) {
                            return new MarkedImage(image: _userImageFile, faces: faces);
                          } else {
                            return Center(child: new CircularProgressIndicator());
                          }
                        },
                      ),
              ),
            ],
          ),
        ));
  }
}
