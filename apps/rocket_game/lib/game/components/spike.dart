import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/domain/models/asset_model.dart';
import 'package:rocket_game/game/core/game_state.dart';
import 'package:rocket_game/infrastructure/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// 障害物を管理するクラス
class Spike {
  static const radius = 1.2;

  Spike({
    required this.position,
    required this.rotation,
    required this.gameState,
    AssetModel assetModel = AssetModel.spike,
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
        (gameState.player.position + Vector3(0, 0.0, 0) - position).length;
    if (distance < radius) {
      // プレイヤーにダメージを与える
      gameState.player.takeDamage();
    }
  }
}
