import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._createInstance();

  factory SoundManager() {
    return _instance;
  }

  SoundManager._createInstance();

  static final player = AudioPlayer(playerId: "player");

  void playSound(String path) async {
    await player.play(AssetSource(path));
  }

  void changeVolume(double newVolume) {
    player.setVolume(newVolume);
  }
}