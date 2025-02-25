import 'dart:math';

import 'package:flutter/material.dart';

BoxDecoration foilDecoration({Alignment alignment = Alignment.center}) =>
    BoxDecoration(
      backgroundBlendMode: BlendMode.darken,
      gradient: LinearGradient(
        tileMode: TileMode.mirror,
        begin: alignment - Alignment(0.5, 0.5),
        end: alignment + Alignment(0.5, 0.5),
        colors: [
          Color.fromRGBO(167, 154, 239, 0.7),
          Color.fromRGBO(102, 227, 247, 0.7),
          Color.fromRGBO(160, 252, 204, 0.7),
          Color.fromRGBO(242, 241, 183, 0.7),
          Color.fromRGBO(255, 183, 223, 0.7),
        ],
        transform: GradientRotation(pi / 4),
      ),
    );

Alignment offsetToAlignment(Offset offset, Size size) {
  return Alignment(
    (offset.dx / (size.width / 2)).clamp(-1.0, 1.0), // Normalize X
    (offset.dy / (size.height / 2)).clamp(-1.0, 1.0), // Normalize Y
  );
}
