import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sbusto/card_data_store.dart' show BoosterCard;
import 'package:sbusto/debug_unbox_view.dart';

const double cardAspectRatio = 6.35 / 8.89;

BoxDecoration foilDecoration({
  Alignment alignment = Alignment.center,
  double opacity = 0.4,
  BlendMode blendMode = BlendMode.darken,
}) => BoxDecoration(
  backgroundBlendMode: blendMode,
  gradient: LinearGradient(
    tileMode: TileMode.mirror,
    begin: alignment - Alignment(0.5, 0.5),
    end: alignment + Alignment(0.5, 0.5),
    colors: [
      Color.fromRGBO(167, 154, 239, opacity),
      Color.fromRGBO(102, 227, 247, opacity),
      Color.fromRGBO(160, 252, 204, opacity),
      Color.fromRGBO(242, 241, 183, opacity),
      Color.fromRGBO(255, 183, 223, opacity),
    ],
    transform: GradientRotation(-pi / 6),
  ),
);

Alignment offsetToAlignment(Offset offset, Size size) {
  return Alignment(
    (offset.dx / (size.width / 2)).clamp(-1.0, 1.0), // Normalize X
    (offset.dy / (size.height / 2)).clamp(-1.0, 1.0), // Normalize Y
  );
}

Future showCardPopup(BuildContext context, BoosterCard card) {
  return showDialog(
    context: context,
    builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          padding: EdgeInsets.all(25),
          child: DuringUnboxCardView(card: card),
        ),
      );
    },
  );
}
