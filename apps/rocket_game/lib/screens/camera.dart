import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/screens/math_utils.dart';
import 'package:vector_math/vector_math.dart';

/// プレイヤーを追従するカメラを管理するクラス
class FollowCamera {
  static final Vector3 kFollowOffset = Vector3(0, 0, -5);
  static const double kPlayerBoundary = 5.0;
  static final Vector3 kFramingOffset = Vector3(3, 2, 0);

  Vector3 position = Vector3(0, 5, -5);
  Vector3 target = Vector3(0, 0, 10);

  Camera get camera => PerspectiveCamera(position: position, target: target);

  /// カメラをリセットする
  void reset() {
    // カメラを原点にいるプレイヤーの背後の初期位置に即座に移動させる
    final Vector3 framingTarget = Vector3.zero();
    position = framingTarget + kFollowOffset;
    target = framingTarget + Vector3(0, 0, 30);
  }

  /// ゲームプレイ中のカメラの動きを更新する
  void updateGameplay(
    Vector3 playerPosition,
    Vector3 movementDirection,
    double deltaSeconds,
  ) {
    // 境界 [-1, 1] 内でのプレイヤーの相対位置を計算する
    final double relativeX = playerPosition.x / kPlayerBoundary;
    final double relativeY = playerPosition.y / kPlayerBoundary;

    // カメラが中央に配置したいフレーミング用の動的ターゲットを計算する
    final Vector3 framingTarget =
        playerPosition.clone() -
        Vector3(
          relativeX * kFramingOffset.x,
          relativeY * kFramingOffset.y,
          0,
        );

    // カメラが実際に注視する点は、フレーミングターゲットの前方になる
    final Vector3 destinationTarget = framingTarget + Vector3(0, 0, 30);

    // カメラの位置はフレーミングターゲットからオフセットされる
    final Vector3 destinationPosition = framingTarget + kFollowOffset;

    // ターゲットにはより強い線形補間を使用してカメラの応答性を高め、
    // 位置にはより弱い線形補間を使用して動きを滑らかにする
    final double targetLerp = 0.1;
    final double positionLerp = 0.08;

    target = vector3LerpDeltaTime(
      target,
      destinationTarget,
      targetLerp,
      deltaSeconds,
    );
    position = vector3LerpDeltaTime(
      position,
      destinationPosition,
      positionLerp,
      deltaSeconds,
    );
  }

  /// 概要カメラの動きを更新する
  void updateOverview(double deltaSeconds, double timeElapsed) {
    position = vector3LerpDeltaTime(
      position,
      Vector3(
            math.sin(timeElapsed / 5) * 7,
            5,
            -math.cos(timeElapsed / 5) * 7,
          ) *
          6,
      0.6,
      deltaSeconds,
    );
    target = vector3LerpDeltaTime(target, Vector3.zero(), 0.4, deltaSeconds);
  }

  /// フィニッシュ時のカメラの動きを更新する
  void updateFinishCamera(Vector3 playerPosition, double deltaSeconds) {
    // フィニッシュカメラビュー（右前）のオフセットを定義する
    final Vector3 finishOffset = Vector3(2, 1, 3);

    // 目標の位置とターゲットを計算する
    final Vector3 destinationPosition = playerPosition + finishOffset;
    final Vector3 destinationTarget = playerPosition;

    // カメラをフィニッシュ位置まで滑らかに移動させる
    position = vector3LerpDeltaTime(
      position,
      destinationPosition,
      0.05, // シネマティックな雰囲気のために遅い線形補間を使用
      deltaSeconds,
    );
    target = vector3LerpDeltaTime(
      target,
      destinationTarget,
      0.05,
      deltaSeconds,
    );
  }
}
