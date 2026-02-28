import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../core/theme.dart';
import '../widgets/board_widget.dart';
import '../widgets/draggable_block.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  
  @override
  void initState() {
    super.initState();
    // Ekran çizildiği gibi "Güncelleme Aranıyor" kontrolü diyaloğunu aç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpdateCheckSplash(context);
    });
  }

  void _showUpdateCheckSplash(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı tıklayıp kapatamasın
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.gridOutlineColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                'Checking for Updates...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );

    // 2 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Diyaloğu kapat
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GRID MASTER'),
            if (Provider.of<GameState>(context).isProVersion)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              _showSettingsModal(context);
            },
          ),
        ],
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          if (gameState.isGameOver) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SCORE: ${gameState.score}',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'BEST: ${gameState.bestScore}',
                    style: const TextStyle(fontSize: 18, color: Colors.yellowAccent),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      gameState.restartGame();
                    },
                    child: const Text('Play Again', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      backgroundColor: gameState.isProVersion ? Colors.amber : Colors.purpleAccent,
                    ),
                    onPressed: () {
                      if (gameState.isProVersion) {
                        // Pro ise izlemeden direkt hak alabilir veya satır silebilir
                        // Şimdilik test amaçlı 5 hak verip devam ettirsin (GameOver'ı kapatsın)
                        gameState.earnRotationRightFromAd(); // 4 hak verir
                        gameState.restartGame(); // Aslında revive lazım ama şimdilik restart gibi
                      } else {
                        gameState.earnRotationRightFromAd();
                      }
                    },
                    icon: Icon(gameState.isProVersion ? Icons.bolt : Icons.ondemand_video),
                    label: Text(gameState.isProVersion ? 'Pro Revive (Free)' : 'Watch Ad (Clear 3 Lines)'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // 1. Skor ve Bilgi Alanı
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Score: ${gameState.score}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Best: ${gameState.bestScore}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.yellowAccent,
                                ),
                              ),
                            ],
                          ),
                          if (gameState.rotationRights > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blueAccent),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.rotate_right, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${gameState.rotationRights} Rights',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            gameState.isProVersion
                                ? const Text(
                                    'Place blocks to earn rights!',
                                    style: TextStyle(color: Colors.white54, fontSize: 14),
                                  )
                                : Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        child: Text(
                                          '25 blocks = 1 Right',
                                          style: TextStyle(color: Colors.white54, fontSize: 14),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purpleAccent,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: () {
                                          gameState.earnRotationRightFromAd();
                                        },
                                        icon: const Icon(Icons.ondemand_video, size: 16),
                                        label: const Text('Watch & 4 Rights', style: TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                  ),
                        ],
                      ),
                    ),

                    // 2. Oyun Tahtası (8x8 Grid)
                    const Expanded(
                      flex: 3,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: BoardWidget(),
                        ),
                      ),
                    ),

                    // 3. Spawner (Seçilmek üzere gelen 3 parça) Alanı
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gridOutlineColor.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: gameState.spawnBlocks.map((block) {
                            if (block == null) {
                              // Boş yer
                              return const SizedBox(width: 80, height: 80);
                            }
                            return DraggableBlock(block: block);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Combo Overlay Animasyonu
              if (gameState.comboMessage.isNotEmpty)
                Center(
                  child: TweenAnimationBuilder(
                    key: ValueKey(gameState.comboMessage),
                    tween: Tween<double>(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: (1.5 - scale).clamp(0.0, 1.0), // Zamanla solma benzeri
                          child: Text(
                            gameState.comboMessage,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellowAccent,
                              shadows: [
                                Shadow(color: Colors.red, blurRadius: 10, offset: Offset(2, 2)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<GameState>(
        builder: (context, gameState, _) {
          if (gameState.isGameOver) return const SizedBox.shrink(); // Game over ekranında kendi butonu var zaten
          return FloatingActionButton(
            backgroundColor: AppTheme.gridOutlineColor,
            onPressed: () {
              gameState.restartGame();
            },
            child: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reset Game (Start Over)',
          );
        }
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Consumer<GameState>(
            builder: (context, gameState, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(
                      gameState.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: gameState.isSoundEnabled ? Colors.greenAccent : Colors.grey,
                      size: 32,
                    ),
                    title: const Text('Sound Effects', style: TextStyle(fontSize: 18, color: Colors.white)),
                    trailing: Switch(
                      value: gameState.isSoundEnabled,
                      activeColor: Colors.greenAccent,
                      onChanged: (val) {
                        gameState.toggleSound();
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                  ListTile(
                    leading: Icon(
                      gameState.isHapticEnabled ? Icons.vibration : Icons.mobile_off,
                      color: gameState.isHapticEnabled ? Colors.blueAccent : Colors.grey,
                      size: 32,
                    ),
                    title: const Text('Vibration (Haptic)', style: TextStyle(fontSize: 18, color: Colors.white)),
                    trailing: Switch(
                      value: gameState.isHapticEnabled,
                      activeColor: Colors.blueAccent,
                      onChanged: (val) {
                        gameState.toggleHaptic();
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                  ListTile(
                    leading: Icon(
                      gameState.is3DTheme ? Icons.view_in_ar : Icons.crop_square,
                      color: gameState.is3DTheme ? Colors.orangeAccent : Colors.grey,
                      size: 32,
                    ),
                    title: const Text('3D Theme (Jewel)', style: TextStyle(fontSize: 18, color: Colors.white)),
                    trailing: Switch(
                      value: gameState.is3DTheme,
                      activeColor: Colors.orangeAccent,
                      onChanged: (val) {
                        gameState.toggleTheme();
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                  ListTile(
                    leading: Icon(
                      gameState.isHintEnabled ? Icons.visibility : Icons.visibility_off,
                      color: gameState.isHintEnabled ? Colors.yellowAccent : Colors.grey,
                      size: 32,
                    ),
                    title: const Text('Hints', style: TextStyle(fontSize: 18, color: Colors.white)),
                    trailing: Switch(
                      value: gameState.isHintEnabled,
                      activeColor: Colors.yellowAccent,
                      onChanged: (val) {
                        gameState.toggleHint();
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                  ListTile(
                    leading: Icon(
                      gameState.isProVersion ? Icons.star : Icons.star_border,
                      color: gameState.isProVersion ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                    title: Text(
                      gameState.isProVersion ? 'Pro Version Active' : 'Get Pro Version',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    subtitle: gameState.isProVersion 
                        ? const Text('Ad-Free Experience', style: TextStyle(color: Colors.white54, fontSize: 12))
                        : const Text('Remove ads and get extra benefits', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    onTap: () {
                      gameState.toggleProVersion();
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gridOutlineColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  )
                ],
              );
            },
          ),
        );
      }
    );
  }
}
