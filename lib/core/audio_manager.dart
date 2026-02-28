import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();

  // Sabit ses dosyaları eklenecek varsayımıyla (assets/sounds)
  // Şimdilik sadece metod iskeletleri
  Future<void> playClick() async {
    // try {
    //   await _player.play(AssetSource('sounds/click.mp3'));
    // } catch (e) {}
    print('Ses Efekti Çalıyor: CLICK');
  }

  Future<void> playBlast() async {
    // try {
    //   await _player.play(AssetSource('sounds/blast.mp3'));
    // } catch (e) {}
    print('Ses Efekti Çalıyor: BLAST');
  }

  Future<void> playCombo() async {
    // try {
    //   await _player.setPlaybackRate(1.2); // Combo'da ses hızlanır/tizleşir
    //   await _player.play(AssetSource('sounds/combo.mp3'));
    // } catch (e) {}
    print('Ses Efekti Çalıyor: COMBO!');
  }
}
