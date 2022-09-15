import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kirsch/raw_picture.dart';

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
  ui.Image? _image;

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
            if (_bytes != null)
              Expanded(child: Image.memory(_bytes!))
            else
              const Spacer(),
            if (_image != null)
              Expanded(child: RawImage(image: _image))
            else
              const Spacer(),
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
    final p = RawPicture();
    await p.loadAsset('assets/pikachu.webp');
    // final Uint8List bytes = p.bytes;

    for (int i = 0; i < 200; i++) {
      for (int j = 0; j < 200; j++) {
        p.setPixel(i, j, Colors.red);
      }
    }

    // // Process `bytes` in RGBA format
    // for (int i = 0; i < bytes.length; i += 4) {
    //   // Extract rgb channels
    //   final r = bytes[i];
    //   final g = bytes[i + 1];
    //   final b = bytes[i + 2];
    //
    //   // Convert to greyscale
    //   final double brightness = r * 0.3 + g * 0.6 + b * 0.1;
    //   bytes[i] = brightness.toInt();
    //   bytes[i + 1] = brightness.toInt();
    //   bytes[i + 2] = brightness.toInt();
    // }

    final img = await p.toUiImage();
    setState(() => _image = img);

    final png = await p.toPngBytes();
    setState(() => _bytes = png);
  }
}
