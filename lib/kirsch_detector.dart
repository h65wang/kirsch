import 'dart:math' as math;

import 'package:kirsch/raw_picture.dart';

class KirschDetector {
  static void process(RawPicture p, {int threshold = 200}) {
    // Calculate luminance for each pixel, and store it as the alpha channel
    for (int x = 0; x < p.width; x++) {
      for (int y = 0; y < p.height; y++) {
        final c = p.getPixel(x, y);
        final lum = (c.computeLuminance() * 255).toInt();
        p.setByte(x, y, 3, lum);
      }
    }

    // Calculate kirsch score and set RGB channel to 0x000000 (black) if it's
    // an edge, and 0xffffff (white) if it's not an edge. This operation
    // does not alter the alpha channel (with luminance info) to avoid
    // interfering neighbouring pixels when they calculate their kirsch scores.
    for (int x = 1; x < p.width - 1; x++) {
      for (int y = 1; y < p.height - 1; y++) {
        final List<List<int>> lum = [
          [
            p.getByte(x - 1, y - 1, 3),
            p.getByte(x, y - 1, 3),
            p.getByte(x + 1, y - 1, 3),
          ],
          [
            p.getByte(x - 1, y, 3),
            p.getByte(x, y, 3),
            p.getByte(x + 1, y, 3),
          ],
          [
            p.getByte(x - 1, y + 1, 3),
            p.getByte(x, y + 1, 3),
            p.getByte(x + 1, y + 1, 3),
          ],
        ];
        final int score = _computeKirsch(lum);

        final v = score > threshold ? 0 : 0xff;
        p.setByte(x, y, 0, v);
        p.setByte(x, y, 1, v);
        p.setByte(x, y, 2, v);
      }
    }

    // Set the alpha channel to 0xff (overwriting the luminance info),
    // so that edges identified in the previous step are rendered as black.
    for (int x = 1; x < p.width - 1; x++) {
      for (int y = 1; y < p.height - 1; y++) {
        p.setByte(x, y, 3, 0xff);
      }
    }
  }

  static int _computeKirsch(List<List<int>> pixels) {
    const matrices = [
      [[5, 5, 5], [-3, 0, -3], [-3, -3, -3]], // N
      [[-3, -3, -3], [-3, 0, -3], [5, 5, 5]], // S
      [[5, -3, -3], [5, 0, -3], [5, -3, -3]], // W
      [[-3, -3, 5], [-3, 0, 5], [-3, -3, 5]], // E
      [[5, 5, -3], [5, 0, -3], [-3, -3, -3]], // NW
      [[-3, 5, 5], [-3, 0, 5], [-3, -3, -3]], // NE
      [[-3, -3, -3], [5, 0, -3], [5, 5, -3]], // SW
      [[-3, -3, -3], [-3, 0, 5], [-3, 5, 5]], // SE
    ];

    return matrices.map((m) {
      int sum = 0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          final int product = m[i][j] * pixels[i][j];
          sum += product;
        }
      }
      return sum;
    }).reduce((accumulator, value) => math.max(accumulator, value));
  }
}
