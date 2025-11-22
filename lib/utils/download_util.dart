import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class DownloadUtils {
  static const MethodChannel platform = MethodChannel(
    "custom.download.channel",
  );

  static Future<void> saveAsPng(BuildContext context, GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image img = await boundary.toImage(pixelRatio: 2.0);
      ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = data!.buffer.asUint8List();

      final filename = "noise_${DateTime.now().millisecondsSinceEpoch}.png";

      final ok = await platform.invokeMethod("saveImage", {
        "bytes": pngBytes,
        "filename": filename,
      });

      if (ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Saved: $filename")));
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
