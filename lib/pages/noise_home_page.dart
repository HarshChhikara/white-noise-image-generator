import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../painters/image_painter_scaled.dart';
import '../utils/noise_generator.dart';
import '../utils/download_util.dart';

class NoiseHomePage extends StatefulWidget {
  const NoiseHomePage({super.key});

  @override
  State<NoiseHomePage> createState() => _NoiseHomePageState();
}

class _NoiseHomePageState extends State<NoiseHomePage> {
  int horizontal = 50;
  int vertical = 50;
  double pixelSize = 5.0;

  late TextEditingController horizontalCtrl;
  late TextEditingController verticalCtrl;

  String selectedMode = 'RGB 6-Bit';
  ui.Image? outputImage;
  bool generating = false;

  final GlobalKey previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    horizontalCtrl = TextEditingController(text: "$horizontal");
    verticalCtrl = TextEditingController(text: "$vertical");
  }

  Future<void> generate() async {
    setState(() => generating = true);
    try {
      final generator = NoiseGenerator();

      if (selectedMode == "8×8 Sprite") {
        horizontal = 8;
        vertical = 8;
        horizontalCtrl.text = "8";
        verticalCtrl.text = "8";
        outputImage = await generator.generateSprite8x8();
      } else {
        outputImage = await generator.generateNoise(
          horizontal,
          vertical,
          selectedMode,
        );
      }
    } finally {
      setState(() => generating = false);
    }
  }

  @override
  void dispose() {
    horizontalCtrl.dispose();
    verticalCtrl.dispose();
    outputImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("White Noise Generator"),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showInfoDialog(),
          ),
        ],
      ),

      floatingActionButton: outputImage == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => DownloadUtils.saveAsPng(context, previewKey),
              label: const Text("Download"),
              icon: const Icon(Icons.download),
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Horizontal:"),
                const SizedBox(width: 10),
                _numberField(horizontalCtrl, (v) {
                  if (selectedMode != "8×8 Sprite") {
                    horizontal = int.tryParse(v) ?? horizontal;
                  }
                }),
                const Spacer(),
                const Text("Vertical:"),
                const SizedBox(width: 10),
                _numberField(verticalCtrl, (v) {
                  if (selectedMode != "8×8 Sprite") {
                    vertical = int.tryParse(v) ?? vertical;
                  }
                }),
              ],
            ),

            Row(
              children: [
                const Text("Zoom:"),
                Expanded(
                  child: Slider(
                    value: pixelSize,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: pixelSize.toInt().toString(),
                    onChanged: (v) => setState(() => pixelSize = v),
                  ),
                ),
              ],
            ),

            DropdownButton(
              value: selectedMode,
              items: const [
                DropdownMenuItem(value: 'RGB 6-Bit', child: Text('RGB 6-Bit')),
                DropdownMenuItem(value: 'RGB 8-Bit', child: Text('RGB 8-Bit')),
                DropdownMenuItem(value: 'Grayscale', child: Text('Grayscale')),
                DropdownMenuItem(
                  value: '8×8 Sprite',
                  child: Text('8×8 Sprite'),
                ),
              ],
              onChanged: (val) => setState(() => selectedMode = val!),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: generating ? null : generate,
              child: Text("Generate"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: RepaintBoundary(
                    key: previewKey,
                    child: outputImage == null
                        ? const Center(child: Text("No image yet"))
                        : CustomPaint(
                            painter: ImagePainterScaled(
                              image: outputImage!,
                              dstWidth: horizontal * pixelSize,
                              dstHeight: vertical * pixelSize,
                            ),
                            size: Size(
                              horizontal * pixelSize,
                              vertical * pixelSize,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: 70,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: const InputDecoration(isDense: true),
      ),
    );
  }

  void showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "About",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "This app generates custom noise patterns.\n"
                  "You can adjust pixel width/height and color settings "
                  "then download the output image.",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
