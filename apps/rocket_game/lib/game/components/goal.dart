import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/domain/models/asset_model.dart';
import 'package:rocket_game/game/core/game_state.dart';
import 'package:rocket_game/infrastructure/services/resource_cache.dart';
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
      Vector3(0, -8, kGoalPositionZ),
      Quaternion.euler(math.pi, 0, 0),
      Vector3(_scale, _scale, -_scale),
    );
    node = ResourceCache.getModel(assetModel)..globalTransform = transform;
  }

  static const double _scale = 6;
  static const double kGoalPositionZ = 450;

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
