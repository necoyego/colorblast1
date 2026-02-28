import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/audio_manager.dart';
import '../core/theme.dart';
import 'block_model.dart';

class GameState extends ChangeNotifier {
  static const int gridSize = 8;
  
  // 8x8 Grid. null: boş hücre, Color: dolu hücre.
  late List<List<Color?>> board;
  
  // Kullanıcıya alt kısımda sunulacak 3 rastgele blok
  List<BlockModel?> spawnBlocks = [null, null, null];
  
  int score = 0;
  int bestScore = 0;
  bool isGameOver = false;

  int blocksPlaced = 0;
  int rotationRights = 0; // Her 25 blok yerleştirmede 1 artar
  bool isProVersion = false; // Reklamsız ve ek özellikli sürüm

  // Animasyon state verileri
  String comboMessage = '';
  List<int> explodingCells = []; // Gerçekten patlayan hücre indeksleri
  List<int> previewExplodingCells = []; // Hover anında (henüz basılmadan) patlaması muhtemel hücre indeksleri
  int previewScore = 0; // Kullanıcı patlama yapacakken önizlemede kazanacağı muhtemel puan

  // Kullanıcı Ayarları
  bool isSoundEnabled = true;
  bool isHapticEnabled = true;
  bool is3DTheme = true; // Tema Seçeneği (Klasik / 3D)
  bool isHintEnabled = true; // Kopyayı Göster/Gizle Seçeneği

  // Drag (Sürükleme) Hover anında bloğun tam şeklini göstermek için geçici veriler
  BlockModel? hoveringBlock;
  int hoveringRow = -1;
  int hoveringCol = -1;

  GameState() {
    _initializeBoard();
    _fillSpawns();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bestScore') ?? 0;
    isProVersion = prefs.getBool('isProVersion') ?? false;
    
    // Pro ise başlangıçta ekstra hak verelim veya başka avantajlar
    if (isProVersion && rotationRights < 5) {
      rotationRights = 5;
    }
    
    notifyListeners();
  }

  Future<void> toggleProVersion() async {
    isProVersion = !isProVersion;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProVersion', isProVersion);
    
    if (isProVersion) {
      rotationRights += 10; // Hediye hak
    }
    
    notifyListeners();
  }

  void _addScore(int points) {
    score += points;
    if (score > bestScore) {
      bestScore = score;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('bestScore', bestScore);
      });
    }
  }

  void _initializeBoard() {
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
  }

  void _fillSpawns() {
    final random = Random();
    for (int i = 0; i < 3; i++) {
        spawnBlocks[i] = _createRandomBlock(random);
    }
  }

  BlockModel _createRandomBlock(Random random) {
    List<Color> colorPool = is3DTheme ? AppTheme.jewelBlockColors : AppTheme.classicBlockColors;
    Color randColor = colorPool[random.nextInt(colorPool.length)];
    return BlockFactory.generateRandomBlock(randColor);
  }

  // Belirli bir bloğu spawns listesinden siler
  void removeSpawnBlock(int blockId) {
    for (int i = 0; i < spawnBlocks.length; i++) {
      if (spawnBlocks[i]?.id == blockId) {
        spawnBlocks[i] = null;
        break;
      }
    }
    // Tüm 3 slot boşaldıysa yenilerini oluştur
    if (spawnBlocks.every((block) => block == null)) {
      _fillSpawns();
      _checkGameOver();
    }
    notifyListeners();
  }

  // Verilen bloğun grid üzerine [row, col] başlangıç koordinatından yerleşip yerleşemeyeceğini kontrol eder
  bool canPlaceBlock(BlockModel block, int row, int col) {
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.columns; c++) {
        if (block.shape[r][c] == 1) {
          int boardRow = row + r;
          int boardCol = col + c;
          
          // Sınırların dışına çıkıyor mu?
          if (boardRow >= gridSize || boardCol >= gridSize || boardRow < 0 || boardCol < 0) {
            return false;
          }
          // Hücre zaten dolu mu?
          if (board[boardRow][boardCol] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // Sürüklenen bir bloğun üstte dolaştığı anki koordinatlarını kaydeder ve patlama ihtimalini önceden hesaplar
  void updateHoverState(BlockModel? block, int row, int col) {
    if (hoveringBlock != block || hoveringRow != row || hoveringCol != col) {
      hoveringBlock = block;
      hoveringRow = row;
      hoveringCol = col;
      
      previewExplodingCells.clear();
      previewScore = 0;
      
      // Eğer geçerli bir hover formu varsa ve ipuçları açıksa bırakılması halindeki patlamaları simüle et
      if (isHintEnabled && block != null && row != -1 && col != -1 && canPlaceBlock(block, row, col)) {
        _calculatePreviewClears(block, row, col);
      }
      
      notifyListeners();
    }
  }

  // Bırakılacak bloğun grid'i nasıl dolduracağını geçici olarak öngörüp, silinecek line'ların endekslerini toplar
  void _calculatePreviewClears(BlockModel block, int row, int col) {
    // 1. Gridin geçici bir kopyasını al (shallow copy yeterli olmayabilir çünkü iç listeler var)
    List<List<Color?>> tempBoard = List.generate(gridSize, (r) => List.from(board[r]));
    
    // 2. Parçayı geçici gride yerleştir
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.columns; c++) {
        if (block.shape[r][c] == 1) {
          tempBoard[row + r][col + c] = block.color;
        }
      }
    }
    
    // 3. Geçici gridde silinecek satır ve sütunları tespit et
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    // Satır kontrolü
    for (int r = 0; r < gridSize; r++) {
      if (tempBoard[r].every((cell) => cell != null)) {
        rowsToClear.add(r);
      }
    }

    // Sütun kontrolü
    for (int c = 0; c < gridSize; c++) {
      bool isColFull = true;
      for (int r = 0; r < gridSize; r++) {
        if (tempBoard[r][c] == null) {
          isColFull = false;
          break;
        }
      }
      if (isColFull) colsToClear.add(c);
    }
    
    // 4. Sonuçları preview state'ine at
    for (int r in rowsToClear) {
      for (int c = 0; c < gridSize; c++) {
        previewExplodingCells.add(r * gridSize + c);
      }
    }
    for (int c in colsToClear) {
      for (int r = 0; r < gridSize; r++) {
         previewExplodingCells.add(r * gridSize + c);
      }
    }

    // 5. Potansiyel Puan Hesaplaması
    if (rowsToClear.isNotEmpty || colsToClear.isNotEmpty) {
      int tempScore = block.rows * block.columns; // Blok boyutu puanı
      if (rowsToClear.length + colsToClear.length > 1) { // Combo puanı durumu
        tempScore += ((rowsToClear.length + colsToClear.length) * 5);
      }
      // Temizlenen hatların puanı
      tempScore += (rowsToClear.length * 10) + (colsToClear.length * 10);
      previewScore = tempScore;
    }
  }

  // Hangi hücrenin hover iz düşümünde parlayacağını hesaplar
  bool isCellHoveredByBlock(int cellRow, int cellCol) {
    if (hoveringBlock == null || hoveringRow == -1 || hoveringCol == -1) return false;

    // Hedef row/col'dan başlayan bloğun sınırları içinde mi?
    int rDiff = cellRow - hoveringRow;
    int cDiff = cellCol - hoveringCol;

    if (rDiff >= 0 && rDiff < hoveringBlock!.rows && cDiff >= 0 && cDiff < hoveringBlock!.columns) {
      return hoveringBlock!.shape[rDiff][cDiff] == 1; // 1 ise o blok o hücreyi kaplıyordur.
    }
    return false;
  }

  // Bloğu grid üzerine yerleştirir
  bool placeBlock(BlockModel block, int row, int col) {
    if (!canPlaceBlock(block, row, col)) return false;

    // Yerleştir
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.columns; c++) {
        if (block.shape[r][c] == 1) {
          board[row + r][col + c] = block.color;
        }
      }
    }
    
    // Ses ve Haptic (Ayarlara bağlı)
    if (isHapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (isSoundEnabled) {
      AudioManager().playClick();
    }

    _addScore(block.rows * block.columns); // Yerleştirilen parça kadar puan
    
    // Satır ve sütun patlamalarını kontrol et
    _checkClears();

    removeSpawnBlock(block.id);

    // Her 25 yerleştirmede 1 çevirme hakkı ver
    // Pro sürümde her 15 blokta bir hak (daha hızlı)
    int threshold = isProVersion ? 15 : 25;
    if (blocksPlaced % threshold == 0) {
      rotationRights++;
    }

    _checkGameOver();
    
    notifyListeners();
    return true;
  }

  void earnRotationRightFromAd() {
    rotationRights += 4; // Tam tur için 4 hak
    notifyListeners();
  }

  void _checkClears() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    // Satır kontrolü
    for (int r = 0; r < gridSize; r++) {
      if (board[r].every((cell) => cell != null)) {
        rowsToClear.add(r);
      }
    }

    // Sütun kontrolü
    for (int c = 0; c < gridSize; c++) {
      bool isColFull = true;
      for (int r = 0; r < gridSize; r++) {
        if (board[r][c] == null) {
          isColFull = false;
          break;
        }
      }
      if (isColFull) colsToClear.add(c);
    }

    if (rowsToClear.isEmpty && colsToClear.isEmpty) return;

    // Patlayan hücreleri görselleştirmek için işaretleyelim
    explodingCells.clear();
    for (int r in rowsToClear) {
      for (int c = 0; c < gridSize; c++) {
        explodingCells.add(r * gridSize + c);
      }
    }
    for (int c in colsToClear) {
      for (int r = 0; r < gridSize; r++) {
         explodingCells.add(r * gridSize + c);
      }
    }

    // COMBO Algoritması
    if (rowsToClear.length + colsToClear.length > 1) {
      if (isHapticEnabled) HapticFeedback.heavyImpact(); 
      if (isSoundEnabled) AudioManager().playCombo();
      _addScore((rowsToClear.length + colsToClear.length) * 5);
      showComboMessage('COMBO x${rowsToClear.length + colsToClear.length}!');
    } else {
      if (isSoundEnabled) AudioManager().playBlast();
    }

    // Gerçek silme işlemini animasyondan hemen sonra yapmak üzere gecikmeli yapıyoruz (UI'da parlasın diye)
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      for (int r in rowsToClear) {
        for (int c = 0; c < gridSize; c++) {
          board[r][c] = null;
        }
        _addScore(10);
      }

      for (int c in colsToClear) {
        for (int r = 0; r < gridSize; r++) {
          board[r][c] = null;
        }
        _addScore(10);
      }
      explodingCells.clear();
      notifyListeners();
    });
  }

  void showComboMessage(String msg) {
    comboMessage = msg;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      comboMessage = '';
      notifyListeners();
    });
  }

  // Bekleyen 3 bloğun herhangi birinin ızgaraya sığıp sığmadığını kontrol eder
  void _checkGameOver() {
    bool hasValidMove = false;
    for (var block in spawnBlocks) {
      if (block != null) {
        // Tüm board ı tara, sığıyor mu
        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            if (canPlaceBlock(block, r, c)) {
              hasValidMove = true;
              break;
            }
          }
          if (hasValidMove) break;
        }
      }
      if (hasValidMove) break;
    }

    if (!hasValidMove) {
      isGameOver = true;
    }
  }
  
  void restartGame() {
    _initializeBoard();
    _fillSpawns();
    score = 0;
    blocksPlaced = 0;
    rotationRights = 0;
    isGameOver = false;
    notifyListeners();
  }

  // Ayarları değiştiren metodlar
  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
    notifyListeners();
  }

  void toggleHaptic() {
    isHapticEnabled = !isHapticEnabled;
    notifyListeners();
  }

  void toggleTheme() {
    is3DTheme = !is3DTheme;
    // Tema değişince tahtadaki tüm parçaları yeni temaya göre renklendirmiyoruz (oyun bozulmasın diye).
    // Sadece altta bekleyen parçaları güncelleyelim.
    for (int i = 0; i < 3; i++) {
      if (spawnBlocks[i] != null) {
        Random rnd = Random();
        List<Color> colorPool = is3DTheme ? AppTheme.jewelBlockColors : AppTheme.classicBlockColors;
        // Mevcut parçanın şeklini koruyalım ama rengini değiştirelim. (Kısmen zordur ama idlerini de ezip yeni yaratabiliriz: )
        spawnBlocks[i] = BlockModel(
          id: spawnBlocks[i]!.id, 
          shape: spawnBlocks[i]!.shape, 
          color: colorPool[rnd.nextInt(colorPool.length)],
        );
      }
    }
    notifyListeners();
  }

  void toggleHint() {
    isHintEnabled = !isHintEnabled;
    notifyListeners();
  }

  // Sahnedeki (spawnBlocks) belirtilen bloğu çevirir
  bool rotateSpawnBlock(int blockId) {
    if (rotationRights <= 0) return false;

    for (int i = 0; i < spawnBlocks.length; i++) {
      if (spawnBlocks[i]?.id == blockId) {
        var currentShape = spawnBlocks[i]!.shape;
        var newShape = BlockFactory.rotateMatrixClockwise(currentShape);
        
        spawnBlocks[i] = BlockModel(
          id: spawnBlocks[i]!.id,
          shape: newShape,
          color: spawnBlocks[i]!.color,
        );
        
        rotationRights--;
        
        if (isHapticEnabled) HapticFeedback.lightImpact();
        if (isSoundEnabled) AudioManager().playClick(); 

        _checkGameOver(); // Döndürünce oyuna devam etme durumu değişmiş olabilir
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
