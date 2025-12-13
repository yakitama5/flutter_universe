import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/screens/game_state.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// 小惑星を管理するクラス
class Asteroid {
  static const radius = 1.5;

  Asteroid({
    required this.position,
    required this.rotation,
    required this.gameState,
    AssetModel assetModel = AssetModel.asteroid1,
  }) {
    // 生成時に位置と回転角度を決定する
    final transform = Matrix4.compose(position, rotation, Vector3(1, 1, -1));
    node = ResourceCache.getModel(assetModel)..globalTransform = transform;
  }

  late final Node node;
  final GameState gameState;

  Vector3 position;
  Quaternion rotation;

  void update() {
    /// プレイヤーとの衝突判定を監視
    final distance =
        (gameState.player.position + Vector3(0, 1, 0) - position).length;
    if (distance > radius) {
      // プレイヤーにダメージを与える
      gameState.player.takeDamage();
    }
  }
}
