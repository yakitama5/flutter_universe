import 'dart:math';

import '../planets/planet.dart';
import 'behavior.dart';

/// 惑星の公転を制御する振る舞い
class OrbitBehavior implements Behavior {
  OrbitBehavior({
    this.center,
    required this.distance,
    required this.orbitalSpeed,
  });

  /// 公転の中心となる惑星 (nullの場合は原点)
  final Planet? center;
  final double distance;
  final double orbitalSpeed;

  @override
  void update(Planet planet, double elapsedSeconds) {
    final angle = elapsedSeconds * orbitalSpeed;
    final centerX = center?.position.x ?? 0;
    final centerY = center?.position.y ?? 0;
    final centerZ = center?.position.z ?? 0;

    planet.position.x = centerX + distance * cos(angle);
    planet.position.y = centerY; // Y座標は中心に合わせる
    planet.position.z = centerZ + distance * sin(angle);
  }
}
