import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Process Demo'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Image.asset('assets/pikachu.webp')),
            if (_bytes != null) Expanded(child: Image.memory(_bytes!)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _process,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  void _process() async {
    // Decode image file to Uint8List `bytes`
    final data = await rootBundle.load('assets/pikachu.webp');
    ui.Image image = await decodeImageFromList(data.buffer.asUint8List());
    final bytes = (await image.toByteData())!.buffer.asUint8List();

    // Process `bytes` in RGBA format
    for (int i = 0; i < bytes.length; i += 4) {
      // Extract rgb channels
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];

      // Convert to greyscale
      final double brightness = r * 0.3 + g * 0.6 + b * 0.1;
      bytes[i] = brightness.toInt();
      bytes[i + 1] = brightness.toInt();
      bytes[i + 2] = brightness.toInt();
    }

    // Encode the Uint8List `bytes` to a ui.Image
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final desc = ui.ImageDescriptor.raw(
      buffer,
      width: image.width,
      height: image.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await desc.instantiateCodec();
    final frame = await codec.getNextFrame();
    final ui.Image outputImage = frame.image;

    // Convert ui.Image to PNG format
    final outputData = await outputImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List pngBytes = outputData!.buffer.asUint8List();

    // Display Uint8List data (PNG format) with an `Image.memory` widget.
    setState(() => _bytes = pngBytes);
  }
}
