import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../models/behaviors/behavior.dart';
import '../models/behaviors/composite_behavior.dart';
import '../models/behaviors/orbit_behavior.dart';
import '../models/behaviors/rotation_behavior.dart';
import '../models/enum/asset_model.dart';
import '../models/planets/earth.dart';
import '../models/planets/jupiter.dart';
import '../models/planets/mars.dart';
import '../models/planets/mercury.dart';
import '../models/planets/moon.dart';
import '../models/planets/neptune.dart';
import '../models/planets/planet.dart';
import '../models/planets/saturn.dart';
import '../models/planets/star.dart';
import '../models/planets/sun.dart';
import '../models/planets/uranus.dart';
import '../models/planets/venus.dart';
import '../services/resource_cache.dart';

/// プラネタリウム全体を管理するメインウィジェット
class SolarSystem extends StatefulWidget {
  const SolarSystem({super.key, this.elapsedSeconds = 0});

  final double elapsedSeconds;

  @override
  SolarSystemState createState() => SolarSystemState();
}

/// プラネタリウムの状態を管理するステートクラス
class SolarSystemState extends State<SolarSystem> {
  /// 3Dシーンとオブジェクトのリスト
  Scene scene = Scene();
  List<Planet> planets = [];
  final Map<Planet, Behavior> _behaviors = {};
  List<ShiningStar> shiningStars = [];

  /// ロード状態
  bool loaded = false;

  /// カメラ操作用のフォーカスノード
  final FocusNode _focusNode = FocusNode();

  /// 星の配置用の定数
  static const int _numberOfStars = 1000;

  /// カメラ制御用の定数
  static const double _universeSize = 100;
  static const double _maxPitch = 89;
  static const double _minPitch = -89;
  static const double _cameraSpeed = 0.5;
  static const double _rotationSpeed = 1;

  /// カメラの状態
  vm.Vector3 _cameraPosition = vm.Vector3(0, _universeSize - 1, 0);
  double _cameraYaw = 0;
  double _cameraPitch = -90;
  double _lastScale = 1;
  bool _isPaused = false;

  /// ジェスチャー用の認識器
  late final ScaleGestureRecognizer _scaleRecognizer;
  late final PanGestureRecognizer _panRecognizer;

  @override
  void initState() {
    super.initState();
    // キャッシュを初期化し、太陽系を構築する
    ResourceCache.preloadAll().then((_) {
      _buildSolarSystemUniverse();

      // 輝く星を作成してシーンに追加する
      final random = Random();
      final starModels = [
        AssetModel.pentagram,
        AssetModel.polygonalStar,
        AssetModel.fourPointedStar,
      ];
      shiningStars = List.generate(_numberOfStars, (i) {
        // 球体内にランダムな座標を生成する
        final r = _universeSize * pow(random.nextDouble(), 1 / 3);
        final theta = acos(2 * random.nextDouble() - 1);
        final phi = 2 * pi * random.nextDouble();

        final x = r * sin(theta) * cos(phi);
        final y = r * sin(theta) * sin(phi);
        final z = r * cos(theta);

        final rotX = random.nextDouble() * 2 * pi;
        final rotY = random.nextDouble() * 2 * pi;
        final rotZ = random.nextDouble() * 2 * pi;

        final randomModel = starModels[random.nextInt(starModels.length)];

        return ShiningStar(
          position: vm.Vector3(x, y, z),
          model: randomModel,
          rotationX: rotX,
          rotationY: rotY,
          rotationZ: rotZ,
        );
      });

      scene.addAll(planets.map((p) => p.node));
      scene.addAll(shiningStars.map((s) => s.node));

      // ロード完了
      setState(() {
        debugPrint('Scene loaded.');
        loaded = true;
      });
    });

    _scaleRecognizer = ScaleGestureRecognizer()
      ..onStart = _handleScaleStart
      ..onUpdate = _handleScaleUpdate;
    _panRecognizer = PanGestureRecognizer()..onUpdate = _handlePanUpdate;
  }

  @override
  void dispose() {
    scene.removeAll();
    _focusNode.dispose();
    _scaleRecognizer.dispose();
    _panRecognizer.dispose();
    super.dispose();
  }

  /// 太陽系（公転あり）を構築する
  void _buildSolarSystemUniverse() {
    final sun = Sun(position: vm.Vector3.zero());
    final mercury = Mercury(
      position: vm.Vector3(Mercury.distanceFromSun, 0, 0),
    );
    final venus = Venus(position: vm.Vector3(Venus.distanceFromSun, 0, 0));
    final earth = Earth(position: vm.Vector3(Earth.distanceFromSun, 0, 0));
    final moon = Moon(
      position: earth.position + vm.Vector3(Moon.distanceFromEarth, 0, 0),
    );
    final mars = Mars(position: vm.Vector3(Mars.distanceFromSun, 0, 0));
    final jupiter = Jupiter(
      position: vm.Vector3(Jupiter.distanceFromSun, 0, 0),
    );
    final saturn = Saturn(position: vm.Vector3(Saturn.distanceFromSun, 0, 0));
    final uranus = Uranus(position: vm.Vector3(Uranus.distanceFromSun, 0, 0));
    final neptune = Neptune(
      position: vm.Vector3(Neptune.distanceFromSun, 0, 0),
    );

    planets = [
      sun,
      mercury,
      venus,
      earth,
      moon,
      mars,
      jupiter,
      saturn,
      uranus,
      neptune,
    ];

    _behaviors[sun] = RotationBehavior(rotationSpeed: 0.0005);
    _behaviors[mercury] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.01),
        OrbitBehavior(distance: Mercury.distanceFromSun, orbitalSpeed: 0.8),
      ],
    );
    _behaviors[venus] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.005),
        OrbitBehavior(distance: Venus.distanceFromSun, orbitalSpeed: 0.5),
      ],
    );
    _behaviors[earth] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.05),
        OrbitBehavior(distance: Earth.distanceFromSun, orbitalSpeed: 0.2),
      ],
    );
    _behaviors[moon] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.01),
        OrbitBehavior(
          center: earth,
          distance: Moon.distanceFromEarth,
          orbitalSpeed: 1,
        ),
      ],
    );
    _behaviors[mars] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.04),
        OrbitBehavior(distance: Mars.distanceFromSun, orbitalSpeed: 0.15),
      ],
    );
    _behaviors[jupiter] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.1),
        OrbitBehavior(distance: Jupiter.distanceFromSun, orbitalSpeed: 0.08),
      ],
    );
    _behaviors[saturn] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.09),
        OrbitBehavior(distance: Saturn.distanceFromSun, orbitalSpeed: 0.05),
      ],
    );
    _behaviors[uranus] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.06),
        OrbitBehavior(distance: Uranus.distanceFromSun, orbitalSpeed: 0.03),
      ],
    );
    _behaviors[neptune] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.05),
        OrbitBehavior(distance: Neptune.distanceFromSun, orbitalSpeed: 0.02),
      ],
    );
  }

  /// キーイベントを処理する
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      setState(() {
        final cameraFront = vm.Vector3(
          cos(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
          sin(vm.radians(_cameraPitch)),
          sin(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
        ).normalized();

        switch (event.logicalKey) {
          // Wキーで前進
          case LogicalKeyboardKey.keyW:
            final newPosition = _cameraPosition + cameraFront * _cameraSpeed;
            if (newPosition.length < _universeSize) {
              _cameraPosition = newPosition;
            }
          // Sキーで後退
          case LogicalKeyboardKey.keyS:
            final newPosition = _cameraPosition - cameraFront * _cameraSpeed;
            if (newPosition.length < _universeSize) {
              _cameraPosition = newPosition;
            }
          // Aキーで左に回転
          case LogicalKeyboardKey.keyA:
            _cameraYaw += _rotationSpeed;
          // Dキーで右に回転
          case LogicalKeyboardKey.keyD:
            _cameraYaw -= _rotationSpeed;
          // 上矢印キーでピッチを上げる
          case LogicalKeyboardKey.arrowUp:
            _cameraPitch += _rotationSpeed;
            if (_cameraPitch > _maxPitch) _cameraPitch = _maxPitch;
          // 下矢印キーでピッチを下げる
          case LogicalKeyboardKey.arrowDown:
            _cameraPitch -= _rotationSpeed;
            if (_cameraPitch < _minPitch) _cameraPitch = _minPitch;
        }
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// スケールジェスチャーの開始を処理する
  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _lastScale = 1.0;
    });
  }

  /// スケールジェスチャーの更新を処理する
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      final cameraFront = vm.Vector3(
        cos(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
        sin(vm.radians(_cameraPitch)),
        sin(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
      ).normalized();

      // 2本指のドラッグによる平行移動
      if (details.focalPointDelta.distance != 0.0) {
        final worldUp = vm.Vector3(0, 1, 0);
        final cameraRight = worldUp.cross(cameraFront).normalized();
        final cameraUp = cameraFront.cross(cameraRight).normalized();

        const panSpeedFactor = 0.05;
        _cameraPosition -=
            cameraRight * details.focalPointDelta.dx * panSpeedFactor;
        _cameraPosition +=
            cameraUp * details.focalPointDelta.dy * panSpeedFactor;

        if (_cameraPosition.length >= _universeSize) {
          _cameraPosition.normalize();
          _cameraPosition.scale(_universeSize - 0.1);
        }
      }

      // 2本指のピンチによるズーム
      if (details.scale != 1.0) {
        final scaleDelta = details.scale - _lastScale;
        const zoomFactor = 0.5;
        final newPosition =
            _cameraPosition + cameraFront * scaleDelta * zoomFactor;

        if (newPosition.length < _universeSize) {
          _cameraPosition = newPosition;
        }
      }

      _lastScale = details.scale;
    });
  }

  /// パンジェスチャーの更新を処理する
  void _handlePanUpdate(DragUpdateDetails details) {
    // 1本指ドラッグによる視点回転
    setState(() {
      const rotationFactor = 0.2;
      _cameraYaw -= details.delta.dx * rotationFactor;
      _cameraPitch -= details.delta.dy * rotationFactor;
      _cameraPitch = _cameraPitch.clamp(_minPitch, _maxPitch);
    });
  }

  /// 一時停止状態を切り替える
  void _togglePauseState() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // シーンの更新
    for (final p in planets) {
      // 振る舞いを適用
      if (!_isPaused) {
        _behaviors[p]?.update(p, widget.elapsedSeconds);
      }
      // ノードを更新
      p.updateNode();
    }
    // フォーカスを要求する
    FocusScope.of(context).requestFocus(_focusNode);

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Listener(
        onPointerSignal: (PointerSignalEvent event) {
          if (event is PointerScrollEvent) {
            setState(() {
              // スクロール方向に応じてズーム処理を行う
              final zoomAmount = -event.scrollDelta.dy * 0.1;

              final cameraFront = vm.Vector3(
                cos(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
                sin(vm.radians(_cameraPitch)),
                sin(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
              ).normalized();

              final newPosition = _cameraPosition + cameraFront * zoomAmount;

              if (newPosition.length < _universeSize) {
                _cameraPosition = newPosition;
              }
            });
          }
        },
        child: RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            ScaleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                  () => _scaleRecognizer,
                  (ScaleGestureRecognizer instance) {},
                ),
            PanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                  () => _panRecognizer,
                  (PanGestureRecognizer instance) {},
                ),
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              SizedBox.expand(
                child: CustomPaint(
                  painter: _ScenePainter(
                    scene: scene,
                    cameraPosition: _cameraPosition,
                    cameraYaw: _cameraYaw,
                    cameraPitch: _cameraPitch,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton.icon(
                    onPressed: _togglePauseState,
                    icon: Icon(
                      _isPaused
                          ? Icons.play_circle_filled
                          : Icons.stop_circle_rounded,
                      size: 40,
                    ),
                    label: Text(
                      _isPaused ? '再生' : '停止',
                      style: const TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// シーンを描画するカスタムペインター
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cameraPosition,
    required this.cameraYaw,
    required this.cameraPitch,
  });

  final Scene scene;
  final vm.Vector3 cameraPosition;
  final double cameraYaw;
  final double cameraPitch;

  @override
  void paint(Canvas canvas, Size size) {
    final cameraFront = vm.Vector3(
      cos(vm.radians(cameraYaw)) * cos(vm.radians(cameraPitch)),
      sin(vm.radians(cameraPitch)),
      sin(vm.radians(cameraYaw)) * cos(vm.radians(cameraPitch)),
    ).normalized();

    final cameraTarget = cameraPosition + cameraFront;

    final right = vm.Vector3(0, 1, 0).cross(cameraFront).normalized();
    final cameraUp = cameraFront.cross(right).normalized();

    final camera = PerspectiveCamera(
      position: cameraPosition,
      target: cameraTarget,
      up: cameraUp,
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
