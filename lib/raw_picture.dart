import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class RawPicture {
  late final ByteData bytes; // RGBA
  late final int width;
  late final int height;

  Future<void> loadAsset(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final ui.Image image = await decodeImageFromList(data.buffer.asUint8List());
    final ByteData byteData = (await image.toByteData())!;

    width = image.width;
    height = image.height;
    bytes = byteData;
  }

  Color getPixel(int x, int y) {
    final int offset = getOffset(x, y);
    final int rgba = bytes.getUint32(offset);
    // Convert RGBA format to ARGB format
    final argb = rgba >> 8 | (rgba & 0xff) << 24;
    return Color(argb);
  }

  void setPixel(int x, int y, Color color) {
    final int offset = getOffset(x, y);
    bytes.setUint8(offset + 3, color.alpha);
    bytes.setUint8(offset, color.red);
    bytes.setUint8(offset + 1, color.green);
    bytes.setUint8(offset + 2, color.blue);
  }

  int getByte(int x, int y, int offset) {
    final int pos = getOffset(x, y) + offset;
    return bytes.getUint8(pos);
  }

  void setByte(int x, int y, int offset, int value) {
    final int pos = getOffset(x, y) + offset;
    bytes.setUint8(pos, value);
  }

  int getOffset(int x, int y) {
    assert(x >= 0 && x < width, 'x = $x but total width is $width');
    assert(y >= 0 && y < height, 'y = $y but total height is $height');
    return (x + y * width) * 4;
  }

  Future<ui.Image> toUiImage() async {
    final u8list = bytes.buffer.asUint8List();
    final buffer = await ui.ImmutableBuffer.fromUint8List(u8list);
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
