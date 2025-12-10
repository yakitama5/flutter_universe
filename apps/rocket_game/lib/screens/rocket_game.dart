import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/screens/asteroid.dart';
import 'package:rocket_game/screens/camera.dart';
import 'package:rocket_game/screens/game.dart';
import 'package:rocket_game/screens/game_mode.dart';
import 'package:rocket_game/screens/input_actions.dart';
import 'package:rocket_game/screens/player.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

class RocketGame extends StatefulWidget {
  const RocketGame({super.key});

  @override
  State<RocketGame> createState() => _RocketGameState();
}

class _RocketGameState extends State<RocketGame> {
  Scene scene = Scene();
  GameMode gameMode = GameMode.startMenu;

  Ticker? tick;
  double time = 0;
  double deltaSeconds = 0;

  /// ゴールの位置
  static const goalPosition = 100;

  /// 縦の分割数
  static const asteroidLaneLength = 10;

  final InputActions inputActions = InputActions();
  final FollowCamera camera = FollowCamera();
  GameState? gameState;

  int lastScore = 0;

  int? currentMusicHandle;

  @override
  void initState() {
    tick = Ticker(
      (elapsed) {
        setState(() {
          double previousTime = time;
          time = elapsed.inMilliseconds / 1000.0;
          deltaSeconds = previousTime > 0 ? time - previousTime : 0;
        });
      },
    );
    resetTimer();

    gameState = GameState(
      scene: scene,
      player: KinematicPlayer(),
    );

    ResourceCache.preloadAll().then((_) {
      setupPlay();
    });

    super.initState();
  }

  void setupPlay() {
    final asteroids = List.generate(asteroidLaneLength, (i) {
      final z = (goalPosition / asteroidLaneLength) * (i + 1);

      return Asteroid(
        position: Vector3(0, 0, z),
        rotation: Vector3.zero(),
        gameState: gameState!,
      );
    });

    scene.addAll(asteroids.map((e) => e.node));
    scene.add(ResourceCache.getModel(AssetModel.starship));

    setState(() {
      gameMode = GameMode.playing;
    });
  }

  void resetTimer() {
    setState(() {
      tick!.stop();
      time = 0;
      tick!.start();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: ScenePainter(scene: scene, camera: camera.camera),
      ),
    );
  }
}
