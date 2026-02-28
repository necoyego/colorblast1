import 'dart:math';
import 'package:flutter/material.dart';

// Polyomino bloğunu temsil eder
class BlockModel {
  final int id; // Eşsiz ID, Drag and Drop işlemlerinde bloğu tanımak için
  final List<List<int>> shape; // 0 boş, 1 dolu
  final Color color;

  BlockModel({
    required this.id,
    required this.shape,
    required this.color,
  });

  // Matrisin genişliği ve yüksekliğini verir (Örn: 2x3 bir L bloğu için w=2, h=3)
  int get columns => shape.isNotEmpty ? shape[0].length : 0;
  int get rows => shape.length;
}

// Blokların bazı klasik örnek şekilleri
class BlockFactory {
  static List<List<List<int>>> get _shapes => [
    // Tekli
    [[1]],
    // 2'li yatay
    [[1, 1]],
    // 2x2 Kare
    [[1, 1], [1, 1]],
    // L şekli
    [
      [1, 0],
      [1, 0],
      [1, 1],
    ],
    // Ters L şekli
    [
      [1, 1, 1],
      [1, 0, 0],
    ],
    // 3'lü dikey çizgi
    [
      [1],
      [1],
      [1],
    ],
    // T Şekli
    [
      [0, 1, 0],
      [1, 1, 1],
    ]
  ];

  static int _idCounter = 0;
  static final Random _random = Random();

  // Matrisi 90 derece saat yönünde döndürür
  static List<List<int>> rotateMatrixClockwise(List<List<int>> matrix) {
    if (matrix.isEmpty) return matrix;
    int rows = matrix.length;
    int cols = matrix[0].length;
    List<List<int>> rotated = List.generate(cols, (_) => List.filled(rows, 0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rotated[j][rows - 1 - i] = matrix[i][j];
      }
    }
    return rotated;
  }

  // Rastgele bir parça üretir
  static BlockModel generateRandomBlock(Color color) {
    // Rastgele bir şekil seç
    int randomIndex = _random.nextInt(_shapes.length);
    List<List<int>> randomShape = _shapes[randomIndex];

    // Arada bir (örneğin %50 ihtimalle) bloğun rastgele dönmesini sağla
    if (_random.nextBool()) {
      int rotations = _random.nextInt(4); // 0, 1, 2 veya 3 kez 90 derece döndür
      for (int i = 0; i < rotations; i++) {
        randomShape = rotateMatrixClockwise(randomShape);
      }
    }

    return BlockModel(
      id: ++_idCounter,
      shape: randomShape,
      color: color,
    );
  }
}
