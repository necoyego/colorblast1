import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/block_model.dart';
import '../models/game_state.dart';

// Belirli bir matris şeklindeki bloğu ekrana çizer
class BlockWidget extends StatelessWidget {
  final BlockModel block;
  final double cellSize;

  const BlockWidget({
    super.key,
    required this.block,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        bool is3D = gameState.is3DTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            block.rows,
            (r) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                block.columns,
                (c) => Container(
                  width: cellSize,
                  height: cellSize,
                  margin: EdgeInsets.all(is3D ? 0.5 : 1.0),
                  decoration: BoxDecoration(
                    color: block.shape[r][c] == 1
                        ? block.color
                        : Colors.transparent, 
                    borderRadius: BorderRadius.circular(is3D ? 5.0 : 4.0),
                    border: (block.shape[r][c] == 1 && is3D)
                      ? Border(
                          // Kalın 3D Pah (Bevel) - Işığı İyice Patlatalım
                          top: BorderSide(color: Colors.white.withOpacity(0.9), width: 6.5), // Neredeyse saf beyaz ışık şeridi
                          left: BorderSide(color: Colors.white.withOpacity(0.7), width: 6.5), 
                          bottom: BorderSide(color: Colors.black.withOpacity(0.75), width: 6.5), // Derin karanlık gölge
                          right: BorderSide(color: Colors.black.withOpacity(0.55), width: 6.5), 
                        )
                      : null,
                    boxShadow: (block.shape[r][c] == 1 && is3D)
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6), // Zemin gölgesi
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ]
                        : null,
                  ),
                  // İç yüzey (Mücevherin düz, parlak cam ön yüzü)
                  child: (block.shape[r][c] == 1 && is3D)
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.95), // Köşede resmen flaş patlıyor
                                Colors.white.withOpacity(0.5),  // Şiddetli ışık hüzmesi
                                Colors.transparent,             // Aniden kesilip bloğun gerçek doygun rengine geçiş
                                Colors.black.withOpacity(0.4),  // Sağ alt diplerdeki koyu siyah is
                              ],
                              stops: const [0.0, 0.15, 0.4, 1.0], // Çok dar alanda aşırı keskin kırılma (Cam gibi)
                            ),
                            // İç yüzey ile dış pah (bevel) arasına ince bir cam kesik izi
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
