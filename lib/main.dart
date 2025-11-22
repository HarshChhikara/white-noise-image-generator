import 'package:flutter/material.dart';
import 'pages/noise_home_page.dart';

void main() => runApp(const NoiseApp());

class NoiseApp extends StatelessWidget {
  const NoiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'White Noise Image Generator',
      debugShowCheckedModeBanner: false,
      home: const NoiseHomePage(),
    );
  }
}
