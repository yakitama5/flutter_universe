import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// 背景用の、衝突判定を持たない隕石。
class SceneryAsteroid {
  final Node node;

  SceneryAsteroid({
    required Vector3 position,
    required Quaternion rotation,
  }) : node = ResourceCache.getAsteroid() {
    node.position = position;
    node.rotation = rotation;
    node.scale = Vector3.all(0.5);
  }
}
