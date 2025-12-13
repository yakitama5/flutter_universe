import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/screens/asteroid.dart';
import 'package:rocket_game/screens/camera.dart';
import 'package:rocket_game/screens/game_mode.dart';
import 'package:rocket_game/screens/game_state.dart';
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
  static const goalPosition = 300;

  /// コースに配置する隕石の総数
  static const totalAsteroids = 150;

  final InputActions inputActions = InputActions();
  final FollowCamera camera = FollowCamera();
  List<Asteroid> asteroids = [];
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
    final allAsteroidPositions = <Vector3>[];

    const courseWidth = 10.0; // 10x10に戻す
    const courseHeight = 10.0; // 10x10に戻す
    const courseDepth = 300.0; // goalPositionと同じ
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
      Vector3 newPosition;

      while (true) {
        final x =
            random.nextDouble() * courseWidth - courseWidth / 2; // 10x10の範囲で生成
        final y =
            random.nextDouble() * courseHeight -
            courseHeight / 2; // 10x10の範囲で生成
        final z = random.nextDouble() * courseDepth;
        newPosition = Vector3(x, y, z);

        // 安全経路との衝突チェック (常に内部エリアなので常にチェック)
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
          continue;
        }

        // 既存の全隕石との衝突チェック
        bool overlaps = false;
        for (final existingPosition in allAsteroidPositions) {
          if (existingPosition.distanceToSquared(newPosition) <
              asteroidCollisionMarginSq) {
            overlaps = true;
            break;
          }
        }
        if (overlaps) {
          continue;
        }

        break;
      }

      allAsteroidPositions.add(newPosition);
      final newRotation = Quaternion.euler(
        random.nextDouble() * 2 * pi,
        random.nextDouble() * 2 * pi,
        random.nextDouble() * 2 * pi,
      );

      asteroids.add(
        Asteroid(
          // 全て Asteroid として生成
          position: newPosition,
          rotation: newRotation,
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
    asteroids.forEach((e) => e.update());
    if (gameState != null) {
      final player = gameState!.player;
      inputActions.updatePlayer(player);
      player.update(deltaSeconds);
      camera.updateGameplay(
        player.position,
        Vector3(player.velocityXY.x, 0, player.velocityZ),
        deltaSeconds,
      );
    }

    return SizedBox.expand(
      child: CustomPaint(
        painter: RocketScenePainter(scene: scene, camera: camera.camera),
      ),
    );
  }
}
