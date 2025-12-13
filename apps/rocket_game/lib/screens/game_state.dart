import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/screens/player.dart';

class GameState {
  GameState({
    required this.scene,
    required this.player,
  });

  final Scene scene;
  final KinematicPlayer player;
}
