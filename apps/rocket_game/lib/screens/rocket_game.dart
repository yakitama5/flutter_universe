import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/screens/asteroid.dart';
import 'package:rocket_game/screens/camera.dart';
import 'package:rocket_game/screens/game.dart';
import 'package:rocket_game/screens/game_mode.dart';
import 'package:rocket_game/screens/input_actions.dart';
import 'package:rocket_game/screens/player.dart';
import 'package:rocket_game/screens/scene_painter.dart';
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

    ResourceCache.preloadAll().then((_) {
      gameState = GameState(
        scene: scene,
        player: KinematicPlayer(),
      );

      setupPlay();
    });

    super.initState();
  }

  void setupPlay() {
    setupCourse();

    setState(() {
      gameMode = GameMode.playing;
    });
  }

  void setupCourse() {
    final random = Random();
    final asteroids = <Asteroid>[];

    const courseWidth = 10.0;
    const courseHeight = 10.0;
    const playerSize = 1.5;
    const asteroidSize = 1.0;
    // プレイヤーと隕石が衝突しないための安全マージン
    // (プレイヤー半径 + 隕石半径)
    const safeMargin = playerSize / 2 + asteroidSize / 2;

    // 各レーンに隕石を生成
    for (var i = 0; i < asteroidLaneLength; i++) {
      final z = (goalPosition / asteroidLaneLength) * (i + 1.0);

      // このレーンの安全な通路の中心をランダムに決定
      final safeX = random.nextDouble() * (courseWidth - playerSize) -
          (courseWidth - playerSize) / 2;
      final safeY = random.nextDouble() * (courseHeight - playerSize) -
          (courseHeight - playerSize) / 2;

      // このレーンに配置する隕石の数 (5〜9個)
      final asteroidCount = random.nextInt(5) + 5;

      for (var j = 0; j < asteroidCount; j++) {
        double x;
        double y;
        do {
          // 隕石の座標をコース内にランダムに決定
          x = random.nextDouble() * courseWidth - courseWidth / 2;
          y = random.nextDouble() * courseHeight - courseHeight / 2;
          // 安全な通路と重なっていないかチェック
        } while ((x > safeX - safeMargin && x < safeX + safeMargin) &&
            (y > safeY - safeMargin && y < safeY + safeMargin));

        asteroids.add(
          Asteroid(
            position: Vector3(x, y, z),
            rotation: Quaternion.euler(
              random.nextDouble() * 2 * pi,
              random.nextDouble() * 2 * pi,
              random.nextDouble() * 2 * pi,
            ),
            gameState: gameState!,
          ),
        );
      }
    }

    scene.addAll(asteroids.map((e) => e.node));
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
        painter: RocketScenePainter(scene: scene, camera: camera.camera),
      ),
    );
  }
}
