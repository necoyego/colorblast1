import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/block_model.dart';
import '../core/theme.dart';

// 8x8 Oyun Tahtası
class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Ekrana göre tüm ızgaranın sığacağı en ideal hücre boyutu
            final double boardSize = constraints.maxWidth < 400 ? constraints.maxWidth : 400;
            final double cellSize = (boardSize - 16) / GameState.gridSize; // Aralarındaki boşluk payı

            return Container(
              width: boardSize,
              height: boardSize,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppTheme.gridOutlineColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: GameState.gridSize,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: GameState.gridSize * GameState.gridSize,
                    itemBuilder: (context, index) {
                      int row = index ~/ GameState.gridSize;
                      int col = index % GameState.gridSize;
                      Color? cellColor = gameState.board[row][col];

                      return DragTarget<BlockModel>(
                        onWillAcceptWithDetails: (details) {
                          BlockModel block = details.data;
                          if (gameState.canPlaceBlock(block, row, col)) {
                            gameState.updateHoverState(block, row, col);
                            return true;
                          }
                          return false;
                        },
                        onLeave: (block) {
                          gameState.updateHoverState(null, -1, -1);
                        },
                        onAcceptWithDetails: (details) {
                          gameState.updateHoverState(null, -1, -1); // Hover temizle
                          gameState.placeBlock(details.data, row, col);
                        },
                        builder: (context, candidateData, rejectedData) {
                          // Eğer bu hücre, hover edilen bloğun şeklinin içindeyse parlat
                          bool isHoveredByShape = gameState.isCellHoveredByBlock(row, col);
                          bool isExploding = gameState.explodingCells.contains(index);
                          bool isPreviewExploding = gameState.previewExplodingCells.contains(index);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              color: isExploding
                                  ? Colors.white // Gerçek Patlama anında beyaz parlama
                                  : isPreviewExploding
                                      ? Colors.redAccent.withOpacity(0.5) // Öngörülen patlamada kırmızımsı uyarı rengi
                                      : isHoveredByShape 
                                          ? Colors.white.withOpacity(0.4) // Bloğun kaplayacağı düz alan parlaması
                                          : (cellColor ?? AppTheme.gridCellColor),
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: (isExploding || isPreviewExploding)
                                    ? Colors.transparent 
                                    : Colors.black.withOpacity(0.3), // Tüm hücrelerin etrafında hafif gölgeli bir oyuk izi
                                width: 1.5,
                              ),
                              boxShadow: isExploding
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : isPreviewExploding
                                      ? [
                                          BoxShadow(
                                            color: Colors.redAccent.withOpacity(0.8),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : (cellColor == null && !isHoveredByShape) // Sadece boşken iç oyuk (inset) gölgesi
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.4),
                                                blurRadius: 2,
                                                offset: const Offset(1, 1),
                                              ),
                                            ]
                                          : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  // Önizleme Puanı (Sadece hover sırasında patlama olacaksa tahtanın ortasında belirir)
                  if (gameState.previewScore > 0)
                    IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.yellowAccent.withOpacity(0.6), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellowAccent.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.yellowAccent, size: 36),
                            const SizedBox(width: 10),
                            Text(
                              '+${gameState.previewScore}',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.redAccent, blurRadius: 10, offset: Offset(2, 2)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
