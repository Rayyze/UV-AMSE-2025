import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._createInstance();

  factory SoundManager() {
    return _instance;
  }

  SoundManager._createInstance() {
    if (kIsWeb) {
      player.setReleaseMode(ReleaseMode.stop);
    }
  }

  static final player = AudioPlayer(playerId: "player");

  void playSound(String path) async {
    await player.stop();
    await player.play(AssetSource(path));
  }

  void changeVolume(double newVolume) {
    player.setVolume(newVolume);
  }
}