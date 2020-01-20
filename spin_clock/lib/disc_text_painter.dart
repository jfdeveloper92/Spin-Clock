import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'constants.dart';

class DiscTextPainter extends CustomPainter {
  final TextPainter textPainter;
  final itemsList;
  final radius;

  ///Diameter of the circle
  final double diameter;

  ///Flips the disc horizontally and text vertically
  ///This will be used when placing he widget on the right side.
  final bool flipped;

  ///Paints the text color
  final Color fontColor;

  final bool isAnimating;

  DiscTextPainter(
      {@required this.diameter,
      @required this.itemsList,
      @required this.fontColor,
      this.isAnimating = false,
      this.flipped = false})
      : textPainter = new TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        radius = diameter / 2;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // drawing
    canvas.translate(radius, radius);

    for (var i = 0; i < itemCount; i++) {
      canvas.save();
      canvas.translate(0.0, -radius + 50.0);

      //help make the text straight on far side
      canvas.rotate(flipped ? (math.pi) / 2 : -(math.pi) / 2);

      var discText = itemsList[i];

      textPainter.text = TextSpan(
        text: discText,
        style: TextStyle(
          color: fontColor,
          //fontSize: i == 6 ? 80 : 50,
          fontSize: 70,
          fontFamily: 'Oswald',
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas,
          new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

      canvas.restore();
      //}

      final textAngle = 2 * (math.pi) / itemCount;

      canvas.rotate(textAngle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
