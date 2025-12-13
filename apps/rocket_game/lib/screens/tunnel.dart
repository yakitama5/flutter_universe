import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// トンネルを管理するクラス
class Tunnel {
  static const double _scale = 5;
  static const double kZLength = 140;

  Tunnel({required Vector3 position}) {
    // 生成時に位置と回転角度を決定する
    final transform = Matrix4.compose(
      position,
      Quaternion.identity(),
      Vector3(_scale, _scale, -_scale),
    );
    node = ResourceCache.getModel(AssetModel.tunnel)
      ..globalTransform = transform;
  }

  late final Node node;
}
