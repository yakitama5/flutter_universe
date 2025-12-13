import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/screens/player.dart';

class GameState {
  GameState({
    required this.scene,
    required this.player,
  });

  static const kTimeLimit = 60; // Seconds.

  final Scene scene;
  final KinematicPlayer player;
}
