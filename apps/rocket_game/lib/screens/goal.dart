import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/screens/game_state.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// ゴールを管理するクラス
class Goal {
  Goal({
    required this.gameState,
    AssetModel assetModel = AssetModel.portal,
    required this.onFinished,
  }) {
    // 生成時に位置と回転角度を決定する
    final transform = Matrix4.compose(
      Vector3(0, 0, 0),
      Quaternion.euler(math.pi, 0, 0),
      Vector3(1, 1, -1),
    );
    node = ResourceCache.getModel(assetModel)..globalTransform = transform;
  }

  static const double kGoalPositionZ = 340;

  final VoidCallback onFinished;

  late final Node node;
  final GameState gameState;

  void update() {
    /// プレイヤーがZ軸で到達したらゴール判定
    final finished = gameState.player.position.z > kGoalPositionZ;
    if (finished) {
      onFinished();
    }
  }
}
