import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class MarkedImage extends StatelessWidget {

  final File image;
  final List<Face> faces;

  MarkedImage({@required this.image, @required this.faces});

  Future<ui.Image> readImageData(File image) async {
    var tmpData = await image.readAsBytes();
    return await decodeImageFromList(tmpData);
  }

  List<Rect> readFaceRects(List<Face> faces) {
    List<Rect> rects = [];
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
    return rects;
  }

  @override
  Widget build(BuildContext context) {

    List<Rect> faceRects = readFaceRects(this.faces);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                color: Colors.green.withOpacity(0.3),
                height: 300,
                child: new FutureBuilder(
                    future: readImageData(this.image),
                    builder: (BuildContext context, AsyncSnapshot<ui.Image> myData) {
                      if (myData.connectionState == ConnectionState.done) {
                        return FittedBox(
                          child: SizedBox(
                            width: myData.data.width.toDouble(),
                            height: myData.data.height.toDouble(),
                            child: CustomPaint(
                              painter: PaintImage(
                                  faceRects: faceRects,
                                  image: myData.data
                              ),
                            ),
                          ),
                        );
                      } else {
                        return new CircularProgressIndicator();
                      }
                    }
                )
            ),
          ),
        ),
      ],
    );
  }
}

class PaintImage extends CustomPainter {

  final ui.Image image;
  final List<Rect> faceRects;

  PaintImage({@required this.image, @required this.faceRects});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 15.0
    ..color = Colors.red;
    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faceRects.length; i++) {
      canvas.drawRect(faceRects[i], paint);
    }
  }

  @override
  bool shouldRepaint(PaintImage oldDelegate) =>
      image != oldDelegate.image || faceRects != oldDelegate.faceRects;

}
