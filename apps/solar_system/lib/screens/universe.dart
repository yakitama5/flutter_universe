import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../models/behaviors/behavior.dart';
import '../models/behaviors/composite_behavior.dart';
import '../models/behaviors/orbit_behavior.dart';
import '../models/behaviors/rotation_behavior.dart';
import '../models/planets/earth.dart';
import '../models/planets/jupiter.dart';
import '../models/planets/mars.dart';
import '../models/planets/mercury.dart';
import '../models/planets/moon.dart';
import '../models/planets/neptune.dart';
import '../models/planets/planet.dart';
import '../models/planets/saturn.dart';
import '../models/planets/star.dart';
import '../models/planets/star_dome.dart';
import '../models/planets/sun.dart';
import '../models/planets/uranus.dart';
import '../models/planets/venus.dart';
import '../services/resource_cache.dart';

/// プラネタリウム全体を管理するメインウィジェット
class Universe extends StatefulWidget {
  const Universe({super.key, this.elapsedSeconds = 0});
  final double elapsedSeconds;

  @override
  UniverseState createState() => UniverseState();
}

/// プラネタリウムの状態を管理するステートクラス
class UniverseState extends State<Universe> {
  Scene scene = Scene();
  List<Planet> planets = [];
  final Map<Planet, Behavior> _behaviors = {};
  List<ShiningStar> shiningStars = [];
  bool loaded = false;

  @override
  void initState() {
    // キャッシュを初期化
    ResourceCache.preloadAll().then((_) {
      // シーンを構築
      _buildSolarSystemUniverse();
      scene.add(StarDome().node);
      scene.addAll(planets.map((p) => p.node));

      setState(() {
        loaded = true;
      });
    });

    super.initState();
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

  @override
  void dispose() {
    scene.removeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // シーンの更新
    // 月が地球の後に更新されるように順序を保証する
    final updateOrder = List<Planet>.from(planets);
    updateOrder.sort((a, b) {
      final aIsMoon =
          _behaviors[a] is CompositeBehavior &&
          (_behaviors[a]! as CompositeBehavior).behaviors.any(
            (e) => e is OrbitBehavior && e.center != null,
          );
      final bIsMoon =
          _behaviors[b] is CompositeBehavior &&
          (_behaviors[b]! as CompositeBehavior).behaviors.any(
            (e) => e is OrbitBehavior && e.center != null,
          );

      if (aIsMoon && !bIsMoon) {
        return 1;
      }
      if (!aIsMoon && bIsMoon) {
        return -1;
      }
      return 0;
    });

    for (final p in updateOrder) {
      // 振る舞いを適用
      _behaviors[p]?.update(p, widget.elapsedSeconds);
      // ノードを更新
      p.updateNode();
    }

    return SizedBox.expand(
      child: CustomPaint(painter: _ScenePainter(scene, widget.elapsedSeconds)),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.elapsedSeconds);

  Scene scene;
  final double elapsedSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      position: vm.Vector3(0, 70, 0),
      target: vm.Vector3(0, 0, 1),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
