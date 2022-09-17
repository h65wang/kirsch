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

  Color getPixel(int x, int y) {
    final int offset = getOffset(x, y);
    return Color.fromARGB(
      bytes[offset + 3],
      bytes[offset],
      bytes[offset + 1],
      bytes[offset + 2],
    );
  }

  void setPixel(int x, int y, Color color) {
    final int offset = getOffset(x, y);
    bytes[offset + 3] = color.alpha;
    bytes[offset] = color.red;
    bytes[offset + 1] = color.green;
    bytes[offset + 2] = color.blue;
  }

  int getOffset(int x, int y) {
    assert(x >= 0 && x < width, 'x = $x but total width is $width');
    assert(y >= 0 && y < height, 'y = $y but total height is $height');
    return (x + y * width) * 4;
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
