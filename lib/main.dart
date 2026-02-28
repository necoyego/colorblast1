import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'models/game_state.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const GridMasterApp(),
    ),
  );
}

class GridMasterApp extends StatelessWidget {
  const GridMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Master Puzzle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const GameScreen(),
    );
  }
}
