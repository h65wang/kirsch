import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kirsch/kirsch_detector.dart';
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
  ui.Image? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirsch Edge Detector'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Image.asset('assets/pikachu.webp')),
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

    Stopwatch stopwatch = Stopwatch()..start();
    KirschDetector.process(p, threshold: 500);
    stopwatch.stop();
    print(stopwatch.elapsedMilliseconds);

    final img = await p.toUiImage();
    setState(() => _image = img);
  }
}
