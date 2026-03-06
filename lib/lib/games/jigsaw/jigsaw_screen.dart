import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../shared/game_dialogs.dart';
import '../../shared/game_header.dart';
import 'logic/image_slicer.dart';
import 'logic/jigsaw_engine.dart';

class _PresetImage {
  final String id;
  final String label;
  final String url;

  const _PresetImage({
    required this.id,
    required this.label,
    required this.url,
  });
}

class JigsawScreen extends StatefulWidget {
  const JigsawScreen({super.key});

  @override
  State<JigsawScreen> createState() => _JigsawScreenState();
}

class _JigsawScreenState extends State<JigsawScreen> {
  static const _gridOptions = [3, 4, 5, 6, 8];
  static const _presetImages = [
    _PresetImage(
      id: 'aurora',
      label: 'Aurora',
      url: 'https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?auto=format&w=400',
    ),
    _PresetImage(
      id: 'forest',
      label: 'Forest',
      url: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&w=400',
    ),
    _PresetImage(
      id: 'coast',
      label: 'Coast',
      url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&w=400',
    ),
    _PresetImage(
      id: 'sunset',
      label: 'Sunset',
      url: 'https://images.unsplash.com/photo-1501973801540-537f08ccae7b?auto=format&w=400',
    ),
  ];

  late final JigsawLogic _logic;
  late JigsawState _state;
  int _gridSize = defaultJigsawGrid;
  bool _solvedShown = false;
  int? _draggingPieceId;
  ui.Image? _puzzleImage;
  bool _isImageLoading = false;
  String? _selectedImageId;

  @override
  void initState() {
    super.initState();
    _logic = JigsawLogic();
    _newGame();
  }

  @override
  void dispose() {
    _puzzleImage?.dispose();
    super.dispose();
  }

  void _newGame() {
    setState(() {
      _state = _logic.newGame(gridSize: _gridSize, boardSize: 280);
      _solvedShown = false;
      _draggingPieceId = null;
    });
  }

  void _changeGridSize(int size) {
    if (_gridSize == size) return;
    setState(() {
      _gridSize = size;
    });
    _newGame();
  }

  Future<void> _loadPresetImage(_PresetImage preset) async {
    if (_isImageLoading && preset.id == _selectedImageId) return;

    setState(() {
      _selectedImageId = preset.id;
      _isImageLoading = true;
    });

    try {
      final image = await _fetchImage(preset.url);
      if (!mounted) return;
      _puzzleImage?.dispose();
      setState(() {
        _puzzleImage = image;
        _isImageLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isImageLoading = false;
        _selectedImageId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load image: $error')),
      );
    }
  }

  Future<ui.Image> _fetchImage(String url) {
    final completer = Completer<ui.Image>();
    final provider = NetworkImage(url);
    final stream = provider.resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener((imageInfo, _) {
      stream.removeListener(listener);
      completer.complete(imageInfo.image);
    }, onError: (error, stackTrace) {
      stream.removeListener(listener);
      completer.completeError(error, stackTrace);
    });
    stream.addListener(listener);
    return completer.future;
  }

  void _clearImage() {
    setState(() {
      _selectedImageId = null;
      _puzzleImage?.dispose();
      _puzzleImage = null;
    });
  }

  void _onPieceDragStart(int pieceId) {
    setState(() {
      _draggingPieceId = pieceId;
    });
  }

  void _onPieceDragUpdate(int pieceId, double x, double y) {
    final result = _logic.movePiece(_state, pieceId, x, y);
    setState(() {
      _state = result.state;
    });
  }

  void _onPieceDragEnd(int pieceId, double x, double y) {
    final result = _logic.dropPiece(_state, pieceId, x, y);
    setState(() {
      _state = result.state;
      _draggingPieceId = null;
    });

    if (_state.isSolved && !_solvedShown) {
      _solvedShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameDialog(
          context: context,
          title: 'Puzzle Complete! 🧩',
          message: 'You solved it in ${_state.movesCount} moves!',
          primaryLabel: 'Play Again',
          onPrimary: _newGame,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jigsaw Puzzle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            children: [
              GameHeader(
                title: 'Placed: ${_state.placedCount}/${_state.totalPieces}',
                subtitle: 'Moves: ${_state.movesCount}',
                buttonLabel: 'New',
                onButtonPressed: _newGame,
              ),
              const SizedBox(height: Spacing.s13),
              _SizeSelector(
                options: _gridOptions,
                selected: _gridSize,
                onChanged: _changeGridSize,
              ),
              const SizedBox(height: Spacing.s13),
              _ImageSelector(
                presets: _presetImages,
                selectedId: _selectedImageId,
                isLoading: _isImageLoading,
                onPresetTap: _loadPresetImage,
                onClear: _clearImage,
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: _PuzzleArea(
                  state: _state,
                  puzzleImage: _puzzleImage,
                  draggingPieceId: _draggingPieceId,
                  onDragStart: _onPieceDragStart,
                  onDragUpdate: _onPieceDragUpdate,
                  onDragEnd: _onPieceDragEnd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSelector extends StatelessWidget {
  final List<_PresetImage> presets;
  final String? selectedId;
  final bool isLoading;
  final ValueChanged<_PresetImage> onPresetTap;
  final VoidCallback onClear;

  const _ImageSelector({
    required this.presets,
    required this.selectedId,
    required this.isLoading,
    required this.onPresetTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Puzzle art', style: titleStyle),
            const Spacer(),
            if (selectedId != null)
              TextButton(
                onPressed: isLoading ? null : onClear,
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: Spacing.s8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((preset) {
              final isSelected = preset.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(right: Spacing.s13),
                child: GestureDetector(
                  onTap: isLoading ? null : () => onPresetTap(preset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: Spacing.ms180),
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Spacing.r12),
                              border: Border.all(
                                color: isSelected
                                    ? CalmPalette.primary
                                    : CalmPalette.stroke,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Spacing.r12 - 2),
                              child: Image.network(
                                preset.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (isSelected && isLoading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(Spacing.r12),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: Spacing.s8 / 2),
                      Text(
                        preset.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? CalmPalette.text : CalmPalette.subtext,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final List<int> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const _SizeSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.s8,
      runSpacing: Spacing.s8,
      alignment: WrapAlignment.center,
      children: options.map((size) {
        final isSelected = size == selected;
        return GestureDetector(
          onTap: () => onChanged(size),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.s13,
              vertical: Spacing.s8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? CalmPalette.primary : CalmPalette.surface,
              borderRadius: BorderRadius.circular(Spacing.r12),
              border: Border.all(color: CalmPalette.stroke),
            ),
            child: Text(
              '$size×$size',
              style: TextStyle(
                color: isSelected ? CalmPalette.text : CalmPalette.subtext,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PuzzleArea extends StatelessWidget {
  final JigsawState state;
  final ui.Image? puzzleImage;
  final int? draggingPieceId;
  final ValueChanged<int> onDragStart;
  final void Function(int, double, double) onDragUpdate;
  final void Function(int, double, double) onDragEnd;

  const _PuzzleArea({
    required this.state,
    required this.puzzleImage,
    required this.draggingPieceId,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaWidth = constraints.maxWidth;

        return Stack(
          children: [
            // Board outline
            Positioned(
              left: (areaWidth - state.boardSize) / 2,
              top: 0,
              child: Container(
                width: state.boardSize,
                height: state.boardSize,
                decoration: BoxDecoration(
                  color: CalmPalette.surface,
                  borderRadius: BorderRadius.circular(Spacing.r12),
                  border: Border.all(color: CalmPalette.stroke, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Spacing.r12 - 2),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFDFDFE),
                                Color(0xFFF1F3F6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      if (puzzleImage != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.25,
                            child: RawImage(
                              image: puzzleImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: _BoardGrid(gridSize: state.gridSize),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Pieces
            ...state.pieces.map((piece) {
              final offsetX = (areaWidth - state.boardSize) / 2;
              return _DraggablePiece(
                key: ValueKey(piece.id),
                piece: piece,
                pieceSize: state.pieceSize,
                offsetX: offsetX,
                gridSize: state.gridSize,
                puzzleImage: puzzleImage,
                isDragging: draggingPieceId == piece.id,
                onDragStart: () => onDragStart(piece.id),
                onDragUpdate: (x, y) => onDragUpdate(piece.id, x - offsetX, y),
                onDragEnd: (x, y) => onDragEnd(piece.id, x - offsetX, y),
              );
            }),
          ],
        );
      },
    );
  }
}

class _BoardGrid extends StatelessWidget {
  final int gridSize;

  const _BoardGrid({required this.gridSize});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: CalmPalette.stroke.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        );
      },
    );
  }
}

class _DraggablePiece extends StatefulWidget {
  final JigsawPiece piece;
  final double pieceSize;
  final double offsetX;
  final int gridSize;
  final ui.Image? puzzleImage;
  final bool isDragging;
  final VoidCallback onDragStart;
  final void Function(double, double) onDragUpdate;
  final void Function(double, double) onDragEnd;

  const _DraggablePiece({
    super.key,
    required this.piece,
    required this.pieceSize,
    required this.offsetX,
    required this.gridSize,
    required this.puzzleImage,
    required this.isDragging,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<_DraggablePiece> createState() => _DraggablePieceState();
}

class _DraggablePieceState extends State<_DraggablePiece> {
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final piece = widget.piece;
    final colorData = PieceColorData(
      row: piece.correctRow,
      col: piece.correctCol,
      gridSize: widget.gridSize,
    );
    final hasImage = widget.puzzleImage != null;
    final baseColor = Color(colorData.colorValue);
    const borderRadius = BorderRadius.zero;

    final displayX = _dragOffset?.dx ?? (piece.currentX + widget.offsetX);
    final displayY = _dragOffset?.dy ?? piece.currentY;

    return Positioned(
      left: displayX,
      top: displayY,
      child: GestureDetector(
        onPanStart: piece.isPlaced
            ? null
            : (details) {
                widget.onDragStart();
                setState(() {
                  _dragOffset = Offset(displayX, displayY);
                });
              },
        onPanUpdate: piece.isPlaced
            ? null
            : (details) {
                setState(() {
                  _dragOffset = _dragOffset! + details.delta;
                });
                widget.onDragUpdate(_dragOffset!.dx, _dragOffset!.dy);
              },
        onPanEnd: piece.isPlaced
            ? null
            : (details) {
                widget.onDragEnd(_dragOffset!.dx, _dragOffset!.dy);
                setState(() {
                  _dragOffset = null;
                });
              },
        child: AnimatedContainer(
          duration: Duration(
            milliseconds: widget.isDragging ? 0 : Spacing.ms180,
          ),
          width: widget.pieceSize - 2,
          height: widget.pieceSize - 2,
          decoration: BoxDecoration(
            color: hasImage ? Colors.white : baseColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: piece.isPlaced
                  ? CalmPalette.secondary
                  : widget.isDragging
                      ? CalmPalette.primary
                      : CalmPalette.stroke,
              width: piece.isPlaced ? 2 : 1,
            ),
            boxShadow: widget.isDragging
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  CustomPaint(
                    painter: _PieceImagePainter(
                      image: widget.puzzleImage!,
                      row: piece.correctRow,
                      col: piece.correctCol,
                      gridSize: widget.gridSize,
                    ),
                  )
                else
                  ColoredBox(color: baseColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieceImagePainter extends CustomPainter {
  final ui.Image image;
  final int row;
  final int col;
  final int gridSize;

  _PieceImagePainter({
    required this.image,
    required this.row,
    required this.col,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final src = ImageSlicer.getPieceRect(
      row: row,
      col: col,
      gridSize: gridSize,
      imageWidth: image.width.toDouble(),
      imageHeight: image.height.toDouble(),
    );
    final dst = Offset.zero & size;

    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant _PieceImagePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.row != row ||
        oldDelegate.col != col ||
        oldDelegate.gridSize != gridSize;
  }
}
