import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class RawPicture {
  late final Uint8List bytes; // RGBA
  late final int width;
  late final int height;

  Future<void> loadAsset(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final ui.Image image = await decodeImageFromList(data.buffer.asUint8List());
    final Uint8List u8list = (await image.toByteData())!.buffer.asUint8List();
    width = image.width;
    height = image.height;
    bytes = u8list;
  }

  Color getPixel(int i, int j) {
    final int offset = (i + j * width) * 4;
    return Color.fromARGB(
      bytes[offset + 3],
      bytes[offset],
      bytes[offset + 1],
      bytes[offset + 2],
    );
  }

  void setPixel(int i, int j, Color color) {
    final int offset = (i + j * width) * 4;
    bytes[offset + 3] = color.alpha;
    bytes[offset] = color.red;
    bytes[offset + 1] = color.green;
    bytes[offset + 2] = color.blue;
  }

  Future<ui.Image> toUiImage() async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final desc = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await desc.instantiateCodec();
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;
    return image;
  }

  Future<Uint8List> toPngBytes() async {
    final image = await toUiImage();
    final outputData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List bytes = outputData!.buffer.asUint8List();
    return bytes;
  }
}
