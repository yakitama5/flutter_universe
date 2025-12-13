import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// トンネルを管理するクラス
class Background {
  static const double scale = 1;

  Background() {
    // 生成時に位置と回転角度を決定する
    final transform = Matrix4.compose(
      Vector3(0, 0, 480), // ゴールの先を包むように配置
      Quaternion.identity(),
      Vector3(scale, scale, scale), // 球の裏面に画像を表示
    );
    node = ResourceCache.getModel(AssetModel.background)
      ..globalTransform = transform;
  }

  late final Node node;
}
