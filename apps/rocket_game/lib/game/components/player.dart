import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/domain/models/asset_model.dart';
import 'package:rocket_game/infrastructure/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

/// プレイヤーキャラクター（Dash）の動作や状態を管理するクラス。
class KinematicPlayer {
  KinematicPlayer() {
    node = ResourceCache.getModel(AssetModel.dash);
    idleAnimation = node.createAnimationClip(node.findAnimationByName("Idle")!)
      ..loop = true
      ..play();
    runAnimation = node.createAnimationClip(node.findAnimationByName("Run")!)
      ..loop = true
      ..weight = 1.0
      ..playbackTimeScale = initialPlaybackTimeScale
      ..play();
  }

  /// キャラのスケール
  static const double playerScale = 0.5;

  late Node node;

  // 移動関連の定数
  /// XY軸への移動速度
  static const double kMaxSpeedXY = 8;

  /// 初期速度
  static const double kInitialVelocityZ = 1.0;

  ///　加速度（秒間）
  static const double kAccelerationZ = 3.0;

  /// 最高速度
  static const double kMaxVelocityZ = 30.0;

  // Dashくんのアニメーション関連で利用する定数
  static const double initialPlaybackTimeScale = 0.5;
  static const double kMaxPlaybackTimeScale = 2.5;

  // Dashくんのアニメーション関連で利用する変数
  late AnimationClip idleAnimation;
  late AnimationClip runAnimation;
  double runPlaybackTimeScale = initialPlaybackTimeScale;

  static final Vector3 initialPosition = Vector3(0, 0, -10);
  Vector3 _position = initialPosition;
  Vector3 get position => _position;

  /// カメラや他のロジックで利用されるXY平面の速度ベクトル。
  Vector2 get velocityXY =>
      Vector2(_inputDirection.x, _inputDirection.y) * kMaxSpeedXY;

  /// Z軸方向（前進方向）の速度。自動で前進する。
  late double _velocityZ = kInitialVelocityZ;
  double get velocityZ => _velocityZ;

  Vector2 _inputDirection = Vector2.zero();

  set inputDirection(Vector2 inputDirection) {
    _inputDirection = inputDirection;
    if (_inputDirection.length > 1) {
      _inputDirection.normalize();
    }
  }

  double damageCooldown = 0;

  void initPosition() {
    _position = initialPosition;
    _velocityZ = kInitialVelocityZ;
    updateNode();
  }

  void updateNode() {
    // ダメージ表現
    node.visible = damageCooldown % 0.2 <= 0.12;

    // 移動中の傾き
    final roll = _inputDirection.x * 0.4;
    final pitch = _inputDirection.y * -0.4;
    final rotation = Quaternion.euler(roll, pitch, 0);

    // モデルへの反映
    final transform = Matrix4.compose(
      _position,
      rotation,
      Vector3(playerScale, playerScale, -playerScale),
    );
    node.globalTransform = transform;
  }

  /// プレイヤーがダメージを受けたかどうかを返す。
  bool takeDamage() {
    if (damageCooldown > 0) {
      return false;
    }
    damageCooldown = 2;
    // XY平面の速度は瞬間的に決まるためリセット不要。
    _velocityZ = kInitialVelocityZ; // 前進速度をリセット
    return true;
  }

  void updateFinish() {
    runAnimation..weight = 0.0;
  }

  void updatePlaying(double deltaSeconds) {
    if (damageCooldown > 0) {
      damageCooldown = math.max(0, damageCooldown - deltaSeconds);
    }

    // Z軸方向の移動（自動加速）を処理する
    _velocityZ = math.min(
      kMaxVelocityZ,
      _velocityZ + kAccelerationZ * deltaSeconds,
    );

    // アニメーション速度をZ軸の速度に連動させる
    final speedProgress =
        (_velocityZ - kInitialVelocityZ) / (kMaxVelocityZ - kInitialVelocityZ);
    runAnimation.playbackTimeScale =
        initialPlaybackTimeScale +
        (kMaxPlaybackTimeScale - initialPlaybackTimeScale) * speedProgress;

    // 各軸の速度を合成する
    Vector3 velocity = Vector3(
      _inputDirection.x * kMaxSpeedXY, // XY平面の速度は瞬間的に決まる
      _inputDirection.y * kMaxSpeedXY,
      _velocityZ, // Z軸は自動的な前進移動
    );

    // 位置を更新する
    _position += velocity * deltaSeconds;

    // X軸の境界チェックを適用する
    const double kXBoundary = 5.0;
    if (_position.x > kXBoundary) {
      _position.x = kXBoundary;
    } else if (_position.x < -kXBoundary) {
      _position.x = -kXBoundary;
    }

    // Y軸の境界チェックを適用する
    const double kYBoundary = 5.0;
    if (_position.y > kYBoundary) {
      _position.y = kYBoundary;
    } else if (_position.y < -kYBoundary) {
      _position.y = -kYBoundary;
    }

    updateNode();
  }
}
