import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kirsch/raw_picture.dart';

class KirschDetector {
  static void process(RawPicture p, {int threshold = 200}) {
    for (int x = 0; x < p.width; x++) {
      for (int y = 0; y < p.height; y++) {
        final c = p.getPixel(x, y);
        final lum = (c.computeLuminance() * 255).toInt();
        p.setPixel(x, y, Color.fromARGB(lum, 0, 0, 0));
      }
    }

    for (int i = 1; i < p.width - 1; i++) {
      for (int j = 1; j < p.height - 1; j++) {
        final List<List<Color>> pixels = [
          [
            p.getPixel(i - 1, j - 1),
            p.getPixel(i, j - 1),
            p.getPixel(i + 1, j - 1)
          ],
          [
            p.getPixel(i - 1, j),
            p.getPixel(i, j),
            p.getPixel(i + 1, j),
          ],
          [
            p.getPixel(i - 1, j + 1),
            p.getPixel(i, j + 1),
            p.getPixel(i + 1, j + 1),
          ],
        ];
        final int score = _computeKirsch(pixels);
        p.setPixel(
          i,
          j,
          score > threshold
              ? p.getPixel(i, j).withRed(255)
              : p.getPixel(i, j).withRed(0),
        );
      }
    }

    for (int i = 1; i < p.width - 1; i++) {
      for (int j = 1; j < p.height - 1; j++) {
        final c = p.getPixel(i, j);
        if (c.red > 0) {
          p.setPixel(i, j, Colors.black);
        } else {
          p.setPixel(i, j, Colors.white);
        }
      }
    }
  }

  static int _computeKirsch(List<List<Color>> pixels) {
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
          final int product = m[i][j] * pixels[i][j].alpha;
          sum += product;
        }
      }
      return sum;
    }).reduce((accumulator, value) => math.max(accumulator, value));
  }
}
