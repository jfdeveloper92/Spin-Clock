import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'constants.dart';

class SpinDisc extends StatelessWidget {
  ///Flip the disc horizontally and text vertically
  final bool flipped;

  final CustomPainter discTextPainter;

  ///Correctly positions the spin disc with the current number
  final activePosition;

  const SpinDisc({this.flipped = false, this.discTextPainter})
      : activePosition = (flipped ? 0 : 5);

  @override
  Widget build(BuildContext context) {
    final bool darkTheme = Theme.of(context).brightness == Brightness.dark;

    // set the rotation of the spin disc mathematically
    var rotation =
        ((flipped ? -90 : 90) - ((360 / itemCount) * activePosition)) *
            math.pi /
            180;

    return Transform(
      alignment: FractionalOffset.center,
      transform: new Matrix4.identity()..rotateZ(rotation),
      child: Container(
          decoration: new BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Colors.grey,
                blurRadius: 4.0,
              ),
            ],
            shape: BoxShape.circle,
            color: darkTheme ? Colors.black : Colors.white,
          ),
          child: CustomPaint(
            painter: discTextPainter,
          )),
    );
  }
}
