import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/screens/camera.dart';
import 'package:rocket_game/screens/game_mode.dart';
import 'package:rocket_game/screens/input_actions.dart';
import 'package:rocket_game/screens/leaderboard.dart';
import 'package:rocket_game/screens/math_utils.dart';
import 'package:rocket_game/screens/player.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:vector_math/vector_math_64.dart' as vm64;

class ScenePainter extends CustomPainter {
  ScenePainter({required this.scene, required this.camera});

  Scene scene;
  Camera camera;

  @override
  void paint(Canvas canvas, Size size) {
    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GameState {
  GameState({
    required this.scene,
    required this.player,
  });

  static const kTimeLimit = 60; // Seconds.

  final Scene scene;
  final KinematicPlayer player;
}

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class HUDBox extends StatelessWidget {
  const HUDBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.white.withOpacity(0.1),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class HUDLabelText extends StatelessWidget {
  const HUDLabelText({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    final valueStyle = style.copyWith(
      fontWeight: FontWeight.bold,
      fontFamily: "monospace",
      fontFamilyFallback: ["Courier"],
    );

    return RichText(
      softWrap: false,
      overflow: TextOverflow.clip,
      text: TextSpan(
        style: style,
        text: label,
        children: [
          TextSpan(
            style: valueStyle,
            text: value,
          ),
        ],
      ),
    );
  }
}

String secondsToFormattedTime(double seconds) {
  int minutes = (seconds / 60).floor();
  int remainingSeconds = (seconds % 60).floor();
  int remainingHundredths = ((seconds * 100) % 100).floor();
  return "${minutes.toString().padLeft(2, "0")}:${remainingSeconds.toString().padLeft(2, "0")}.${remainingHundredths.toString().padLeft(2, "0")}";
}

class GameplayHUD extends StatelessWidget {
  const GameplayHUD({super.key, required this.gameState, required this.time});

  final GameState gameState;
  final double time;

  @override
  Widget build(BuildContext context) {
    double secondsRemaining = math.max(0, GameState.kTimeLimit - time);
    return Align(
      alignment: .topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: HUDBox(
          child: HUDLabelText(
            label: "⏱ ",
            value: secondsToFormattedTime(secondsRemaining),
          ),
        ),
      ),
    );
  }
}

class SpringCurve extends Curve {
  @override
  double transformInternal(double t) {
    const a = 0.09;
    const w = 20;
    return -(math.pow(math.e, -t / a) * math.cos(t * w)) + 1.0;
  }
}

class SheenGradientTransform extends GradientTransform {
  SheenGradientTransform(this.rotation, this.translation, this.scale);

  double rotation;
  vm64.Vector3 translation;
  double scale;

  @override
  vm64.Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return (vm64.Matrix4.translation(translation) *
            vm64.Matrix4.rotationZ(rotation) *
            scale)
        as vm64.Matrix4;
  }
}

class VignettePainter extends CustomPainter {
  VignettePainter({this.color = Colors.white});

  ui.Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader =
          RadialGradient(
            radius: 1.0,
            colors: [Colors.transparent, color],
            stops: [0.2, 1.0],
          ).createShader(
            Rect.fromLTRB(0, 0, size.width, size.height),
          )
      ..blendMode = BlendMode.srcOver;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _GameWidgetState extends State<GameWidget> {
  Scene scene = Scene();
  GameMode gameMode = GameMode.startMenu;
  Node skySphere = Node();

  Ticker? tick;
  double time = 0;
  double deltaSeconds = 0;
  double rainbowVignette = 1;

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
      gotoStartMenu();

      skySphere = ResourceCache.getModel(AssetModel.asteroid1);
      scene.add(skySphere);
      scene.add(ResourceCache.getModel(AssetModel.asteroid1));
    });

    super.initState();
  }

  void resetTimer() {
    setState(() {
      tick!.stop();
      time = 0;
      tick!.start();
    });
  }

  void gotoGame() {
    setState(() {
      inputActions.absorbKeyEvents = true;
      gameMode = GameMode.playing;
      resetTimer();
      gameState = GameState(
        scene: scene,
        player: KinematicPlayer(),
      );
      scene.add(gameState!.player.node);
    });
  }

  void gotoStartMenu() {
    setState(() {
      inputActions.absorbKeyEvents = true;
      gameMode = GameMode.startMenu;
      if (gameState != null) {
        scene.remove(gameState!.player.node);
        gameState = null;
      }
    });
  }

  void gotoLeaderboardEntry() {
    setState(() {
      inputActions.absorbKeyEvents = false;
      gameMode = GameMode.finish;
      resetTimer();
      scene.remove(gameState!.player.node);
      gameState = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double rainbowVignetteDest = gameMode == GameMode.playing ? 0 : 1;
    rainbowVignette = lerpDeltaTime(
      rainbowVignette,
      rainbowVignetteDest,
      0.8,
      deltaSeconds,
    );

    if (gameMode == GameMode.playing) {
      // If the game is playing, update the player and camera.
      double secondsRemaining = math.max(0, GameState.kTimeLimit - time);
      inputActions.updatePlayer(gameState!.player);
      gameState!.player.update(deltaSeconds);
      camera.updateGameplay(
        gameState!.player.position,
        vm.Vector3(
              gameState!.player.velocityXZ.x,
              0,
              gameState!.player.velocityXZ.y,
            ) *
            gameState!.player.kMaxSpeed,
        deltaSeconds,
      );

      if (secondsRemaining <= 0 || inputActions.skipToEnd) {
        gotoLeaderboardEntry();
      }
    } else {
      // If we're in the menus, slowly rotate the camera.
      camera.updateOverview(deltaSeconds, time);
    }
    if (gameMode == GameMode.startMenu) {
      // キー押下でゲームスタート
      if (inputActions.keyboardInputState.values.any((value) => value > 0)) {
        gotoGame();
      }
    }

    skySphere.localTransform =
        (vm.Matrix4.translation(camera.position) *
                vm.Matrix4.rotationY(time * 0.1))
            as vm.Matrix4;

    return Stack(
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: ScenePainter(scene: scene, camera: camera.camera),
          ),
        ),
        if (gameMode == GameMode.playing)
          IgnorePointer(
            child: CustomPaint(
              painter: VignettePainter(
                color:
                    Color.lerp(
                      Colors.white.withAlpha(100),
                      Colors.red,
                      math.max(0.0, gameState!.player.damageCooldown - 1),
                    ) ??
                    Colors.transparent,
              ),
              child: Container(),
            ),
          ),
        IgnorePointer(
          child: Opacity(
            opacity: rainbowVignette,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    Color.fromARGB(255, 153, 221, 255),
                    Color.fromARGB(255, 255, 158, 126),
                    Color.fromARGB(255, 230, 229, 255),
                    ui.Color.fromARGB(255, 114, 207, 131),
                    Colors.white,
                    Color.fromARGB(255, 153, 221, 255),
                  ],
                  stops: const [0, 0.1, 0.5, 0.8, 0.9, 1],
                  tileMode: TileMode.repeated,
                  transform: SheenGradientTransform(
                    math.pi / 4,
                    vm64.Vector3(-time * 150, 0, 0),
                    5,
                  ),
                ).createShader(bounds);
              },
              child: CustomPaint(
                painter: VignettePainter(),
                child: Container(),
              ),
            ),
          ),
        ),
        if (gameMode == GameMode.playing)
          GameplayHUD(gameState: gameState!, time: time)
              .animate(key: const ValueKey('gameplayHUD'))
              .slideY(
                curve: Curves.easeOutCubic,
                duration: 1.5.seconds,
                begin: -3,
                end: 0,
              ),
        if (gameMode == GameMode.startMenu)
          Center(
            child: HUDBox(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Color.fromARGB(255, 153, 221, 255),
                      Color.fromARGB(255, 255, 158, 126),
                      Color.fromARGB(255, 230, 229, 255),
                      Color.fromARGB(255, 15, 234, 48),
                      Colors.white,
                    ],
                    stops: const [0, 0.1, 0.5, 0.9, 1],
                    tileMode: TileMode.repeated,
                    transform: SheenGradientTransform(
                      -math.pi / 4,
                      vm64.Vector3(time * 150, 0, 0),
                      10,
                    ),
                  ).createShader(bounds);
                },
                child: const Text(
                  "PRESS Space TO PLAY!",
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (gameMode == GameMode.finish)
          Center(
                child: LeaderboardForm(
                  score: lastScore,
                  onSubmit: () {
                    gotoStartMenu();
                  },
                ),
              )
              .animate(key: const ValueKey("leaderboard"))
              .fade(duration: 0.2.seconds)
              .slide(duration: 1.5.seconds, curve: SpringCurve())
              .flip(),
      ],
    );
  }
}
