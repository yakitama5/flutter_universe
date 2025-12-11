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

  /// コースに配置する隕石の総数
  static const totalAsteroids = 500;

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

    // 初期位置に設定
    gameState?.player.initPosition();
    scene.add(gameState!.player.node);

    setState(() {
      gameMode = GameMode.playing;
    });
  }

  void setupCourse() {
    final random = Random();
    final asteroids = <Asteroid>[];

    const courseWidth = 30.0;
    const courseHeight = 30.0;
    const courseDepth = 100.0; // goalPositionと同じ
    const playerSize = 1.5;
    const asteroidSize = 1.0;
    const safeMargin = playerSize / 2 + asteroidSize / 2;
    const asteroidCollisionMargin = asteroidSize; // 隕石の直径
    final asteroidCollisionMarginSq = pow(asteroidCollisionMargin, 2);

    // 安全な経路の制御点を生成
    const controlPointCount = 5;
    final pathPoints = List.generate(controlPointCount + 1, (i) {
      final z = (courseDepth / controlPointCount) * i;
      if (i == 0) {
        return Vector3(0, 0, z); // スタートは中央
      }
      final x =
          random.nextDouble() * (courseWidth - playerSize) -
          (courseWidth - playerSize) / 2;
      final y =
          random.nextDouble() * (courseHeight - playerSize) -
          (courseHeight - playerSize) / 2;
      return Vector3(x, y, z);
    });

    // 隕石を生成
    for (var i = 0; i < totalAsteroids; i++) {
      double x, y, z;

      while (true) {
        // 隕石の3D座標をコース内にランダムに決定
        x = random.nextDouble() * courseWidth - courseWidth / 2;
        y = random.nextDouble() * courseHeight - courseHeight / 2;
        z = random.nextDouble() * courseDepth;

        // --- 安全経路との衝突チェック ---
        final segmentIndex = (z / (courseDepth / controlPointCount))
            .floor()
            .clamp(0, controlPointCount - 1);
        final startPoint = pathPoints[segmentIndex];
        final endPoint = pathPoints[segmentIndex + 1];
        final t = (z - startPoint.z) / (endPoint.z - startPoint.z);
        final pathX = startPoint.x + (endPoint.x - startPoint.x) * t;
        final pathY = startPoint.y + (endPoint.y - startPoint.y) * t;
        final distanceToPathSq = pow(x - pathX, 2) + pow(y - pathY, 2);

        if (distanceToPathSq < pow(safeMargin, 2)) {
          continue; // 経路と衝突するので再試行
        }

        // --- 既存の隕石との衝突チェック ---
        bool overlapsWithOtherAsteroids = false;
        final newPosition = Vector3(x, y, z);
        for (final existingAsteroid in asteroids) {
          if (existingAsteroid.position.distanceToSquared(newPosition) <
              asteroidCollisionMarginSq) {
            overlapsWithOtherAsteroids = true;
            break;
          }
        }

        if (overlapsWithOtherAsteroids) {
          continue; // 他の隕石と衝突するので再試行
        }

        // 全てのチェックをクリアしたのでループを抜ける
        break;
      }

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
