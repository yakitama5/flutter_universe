import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/screens/background.dart';
import 'package:rocket_game/screens/camera.dart';
import 'package:rocket_game/screens/game_mode.dart';
import 'package:rocket_game/screens/game_state.dart';
import 'package:rocket_game/screens/goal.dart';
import 'package:rocket_game/screens/input_actions.dart';
import 'package:rocket_game/screens/player.dart';
import 'package:rocket_game/screens/scene_painter.dart';
import 'package:rocket_game/screens/spike.dart';
import 'package:rocket_game/screens/tunnel.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

class RocketGame extends StatefulWidget {
  const RocketGame({super.key});

  @override
  State<RocketGame> createState() => _RocketGameState();
}

class _RocketGameState extends State<RocketGame> {
  static const _timerTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const _congratsTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 48,
    fontWeight: FontWeight.bold,
  );
  static const _restartTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
  );

  Scene scene = Scene();
  GameMode gameMode = GameMode.startMenu;

  Ticker? tick;
  double time = 0;
  double deltaSeconds = 0;
  double gameplayTime = 0.0;
  bool isTimerRunning = false;
  bool _isRestarting = false;

  /// コースに配置する隕石の総数
  static const totalAsteroids = 300;

  final InputActions inputActions = InputActions();
  final FollowCamera camera = FollowCamera();
  List<Spike> asteroids = [];
  GameState? gameState;
  late Goal goal;

  int lastScore = 0;

  int? currentMusicHandle;

  String _formatGameplayTime(double timeInSeconds) {
    final int hours = (timeInSeconds / 3600).floor();
    final int minutes = (timeInSeconds / 60).floor() % 60;
    final int seconds = timeInSeconds.floor() % 60;
    final int milliseconds = (timeInSeconds * 1000).floor() % 1000;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';
  }

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
      setupPlay();
    });

    super.initState();
  }

  void restartGame() {
    // Clear old objects
    scene.removeAll();
    asteroids.clear();

    // Setup a new game
    setupPlay();
    _isRestarting = false;
  }

  void setupPlay() {
    scene.add(Background().node);
    scene.add(Tunnel(position: Vector3(0, -6, Tunnel.kZLength)).node);
    scene.add(Tunnel(position: Vector3(0, -6, Tunnel.kZLength * 2)).node);
    scene.add(Tunnel(position: Vector3(0, -6, Tunnel.kZLength * 3)).node);
    gameState = GameState(
      scene: scene,
      player: KinematicPlayer(),
    );
    setupCourse();

    // 初期位置に設定
    gameState?.player.initPosition();
    scene.add(gameState!.player.node);

    goal = Goal(
      gameState: gameState!,
      onFinished: () {
        setState(() {
          gameMode = GameMode.finish;
          isTimerRunning = false;
        });
      },
    );
    scene.add(goal.node);

    setState(() {
      gameplayTime = 0.0;
      isTimerRunning = true;
      gameMode = GameMode.playing;
    });
  }

  void setupCourse() {
    final random = Random();
    final allAsteroidPositions = <Vector3>[];

    const courseWidth = 10.0;
    const courseHeight = 10.0;
    const courseLength = Goal.kGoalPositionZ - 40;
    const playerSize = 1.0;
    const asteroidSize = 0.6;
    const safeMargin = playerSize / 2 + asteroidSize / 2;
    const asteroidCollisionMargin = asteroidSize; // 隕石の直径
    final asteroidCollisionMarginSq = pow(asteroidCollisionMargin, 2);

    // 安全な経路の制御点を生成
    const controlPointCount = 2;
    final pathPoints = List.generate(controlPointCount + 1, (i) {
      final z = (courseLength / controlPointCount) * i;
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
        final z = random.nextDouble() * courseLength;
        newPosition = Vector3(x, y, z);

        // 安全経路との衝突チェック (常に内部エリアなので常にチェック)
        final segmentIndex = (z / (courseLength / controlPointCount))
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
        Spike(
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
    if (isTimerRunning) {
      gameplayTime += deltaSeconds;
    }

    if (gameState != null) {
      final player = gameState!.player;
      if (gameMode == GameMode.playing) {
        inputActions.updatePlayer(player);
        player.updatePlaying(deltaSeconds);
      } else if (gameMode == GameMode.finish) {
        player.updateFinish();
        if (inputActions.enter && !_isRestarting) {
          _isRestarting = true;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            restartGame();
          });
        }
      }
      goal.update();
      if (gameMode == GameMode.playing) {
        camera.updateGameplay(
          player.position,
          Vector3(player.velocityXY.x, 0, player.velocityZ),
          deltaSeconds,
        );
      } else if (gameMode == GameMode.finish) {
        camera.updateFinishCamera(player.position, deltaSeconds);
      }
    }

    return Stack(
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: RocketScenePainter(scene: scene, camera: camera.camera),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Text(
            'Time: ${_formatGameplayTime(gameplayTime)}',
            style: _timerTextStyle,
          ),
        ),
        if (gameMode == GameMode.finish)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Congratulations!', style: _congratsTextStyle),
                SizedBox(height: 20),
                Text('Press Space to Restart', style: _restartTextStyle),
              ],
            ),
          ),
      ],
    );
  }
}
