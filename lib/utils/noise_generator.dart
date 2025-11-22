import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

class NoiseGenerator {
  Future<ui.Image> generateSprite8x8() async {
    const int w = 8;
    const int h = 8;
    final rng = Random();

    final palette = [
      const Color(0xFF000000),
      const Color(0xFFFFFFFF),
      const Color(0xFFFF0000),
      const Color(0xFF00FF00),
      const Color(0xFF0000FF),
      const Color(0xFFFFFF00),
      const Color(0xFF00FFFF),
      const Color(0xFF800080),
      const Color(0xFFFFA500),
      const Color(0xFFA52A2A),
    ];

    final bg = palette[rng.nextInt(palette.length)];

    final buffer = Uint8List(w * h * 4);
    int index = 0;
    for (int i = 0; i < w * h; i++) {
      final c = rng.nextBool() ? palette[rng.nextInt(palette.length)] : bg;
      buffer[index++] = c.red;
      buffer[index++] = c.green;
      buffer[index++] = c.blue;
      buffer[index++] = 255;
    }

    return decode(w, h, buffer);
  }

  Future<ui.Image> generateNoise(int w, int h, String mode) async {
    final rng = Random();
    final pixels = Uint8List(w * h * 4);

    for (int i = 0; i < w * h; i++) {
      int r, g, b;
      switch (mode) {
        case 'RGB 6-Bit':
          r = (rng.nextInt(4)) * 85;
          g = (rng.nextInt(4)) * 85;
          b = (rng.nextInt(4)) * 85;
          break;
        case 'Grayscale':
          r = g = b = rng.nextInt(256);
          break;
        default:
          r = rng.nextInt(256);
          g = rng.nextInt(256);
          b = rng.nextInt(256);
      }
      final o = i * 4;
      pixels[o] = r;
      pixels[o + 1] = g;
      pixels[o + 2] = b;
      pixels[o + 3] = 255;
    }

    return decode(w, h, pixels);
  }

  Future<ui.Image> decode(int w, int h, Uint8List buffer) async {
    final comp = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      buffer,
      w,
      h,
      ui.PixelFormat.rgba8888,
      comp.complete,
    );
    return comp.future;
  }
}
