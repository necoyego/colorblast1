import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/block_model.dart';
import '../models/game_state.dart';
import 'block_widget.dart';

// Kullanıcının alt panoda görüp sürükleyebileceği blok türü
class DraggableBlock extends StatelessWidget {
  final BlockModel block;

  const DraggableBlock({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    // Mobil için varsayılan dokunulacak hücre büyüklüğü
    const double normalCellSize = 30.0;
    const double draggingCellSize = 35.0; // Sürüklerken bir tık büyük olsun (UX)

    return GestureDetector(
      onTap: () {
        // Tıklanınca çevir (Eğer hak varsa)
        context.read<GameState>().rotateSpawnBlock(block.id);
      },
      child: Draggable<BlockModel>(
        data: block,
        // Sürüklenirken parmak altındaki görünüm
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.8,
            child: BlockWidget(block: block, cellSize: draggingCellSize),
          ),
        ),
        // Sürüklendikten sonra ilk yerinde dursa nasıl görünür (Boş gösterebiliriz)
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: BlockWidget(block: block, cellSize: normalCellSize),
        ),
        // Alt paneldeki normal görünüm
        child: BlockWidget(block: block, cellSize: normalCellSize),
      ),
    );
  }
}
