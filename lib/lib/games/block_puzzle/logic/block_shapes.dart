// Block shape definitions for Block Puzzle game.
// Pure Dart - no Flutter imports.

class BlockShape {
  final String id;
  final List<List<bool>> pattern;
  final int colorIndex;

  const BlockShape({
    required this.id,
    required this.pattern,
    required this.colorIndex,
  });

  int get rows => pattern.length;
  int get cols => pattern.isNotEmpty ? pattern[0].length : 0;

  int get cellCount {
    var count = 0;
    for (final row in pattern) {
      for (final cell in row) {
        if (cell) count++;
      }
    }
    return count;
  }
}

class BlockShapes {
  BlockShapes._();

  static const List<BlockShape> all = [
    // Single
    BlockShape(id: 'single', pattern: [[true]], colorIndex: 0),

    // Line 2
    BlockShape(id: 'line2h', pattern: [[true, true]], colorIndex: 1),
    BlockShape(id: 'line2v', pattern: [[true], [true]], colorIndex: 1),

    // Line 3
    BlockShape(id: 'line3h', pattern: [[true, true, true]], colorIndex: 2),
    BlockShape(id: 'line3v', pattern: [[true], [true], [true]], colorIndex: 2),

    // Line 4
    BlockShape(id: 'line4h', pattern: [[true, true, true, true]], colorIndex: 3),
    BlockShape(id: 'line4v', pattern: [[true], [true], [true], [true]], colorIndex: 3),

    // Line 5
    BlockShape(id: 'line5h', pattern: [[true, true, true, true, true]], colorIndex: 4),
    BlockShape(id: 'line5v', pattern: [[true], [true], [true], [true], [true]], colorIndex: 4),

    // Square 2x2
    BlockShape(id: 'square2', pattern: [[true, true], [true, true]], colorIndex: 5),

    // Square 3x3
    BlockShape(
      id: 'square3',
      pattern: [
        [true, true, true],
        [true, true, true],
        [true, true, true],
      ],
      colorIndex: 6,
    ),

    // L shapes
    BlockShape(
      id: 'l1',
      pattern: [
        [true, false],
        [true, false],
        [true, true],
      ],
      colorIndex: 7,
    ),
    BlockShape(
      id: 'l2',
      pattern: [
        [false, true],
        [false, true],
        [true, true],
      ],
      colorIndex: 7,
    ),
    BlockShape(
      id: 'l3',
      pattern: [
        [true, true],
        [true, false],
        [true, false],
      ],
      colorIndex: 7,
    ),
    BlockShape(
      id: 'l4',
      pattern: [
        [true, true],
        [false, true],
        [false, true],
      ],
      colorIndex: 7,
    ),

    // T shape
    BlockShape(
      id: 't1',
      pattern: [
        [true, true, true],
        [false, true, false],
      ],
      colorIndex: 8,
    ),

    // Small L
    BlockShape(
      id: 'smallL1',
      pattern: [
        [true, false],
        [true, true],
      ],
      colorIndex: 9,
    ),
    BlockShape(
      id: 'smallL2',
      pattern: [
        [false, true],
        [true, true],
      ],
      colorIndex: 9,
    ),
    BlockShape(
      id: 'smallL3',
      pattern: [
        [true, true],
        [true, false],
      ],
      colorIndex: 9,
    ),
    BlockShape(
      id: 'smallL4',
      pattern: [
        [true, true],
        [false, true],
      ],
      colorIndex: 9,
    ),
  ];
}
