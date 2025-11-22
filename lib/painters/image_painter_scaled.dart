import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImagePainterScaled extends CustomPainter {
  final ui.Image image;
  final double dstWidth;
  final double dstHeight;

  ImagePainterScaled({
    required this.image,
    required this.dstWidth,
    required this.dstHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, dstWidth, dstHeight),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
