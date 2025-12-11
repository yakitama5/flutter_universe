import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// 背景用の、衝突判定を持たない隕石。
class SceneryAsteroid {
  SceneryAsteroid({
    required Vector3 position,
    required Quaternion rotation,
    AssetModel assetModel = AssetModel.asteroid1,
  }) {
    // 生成時に位置と回転角度を決定する
    final transform = Matrix4.compose(position, rotation, Vector3(1, 1, -1));
    node = ResourceCache.getModel(assetModel)..globalTransform = transform;
  }

  late final Node node;
}
