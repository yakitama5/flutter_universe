import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

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

  // No longer needed for rotation, but useful for camera/other logic
  Vector2 get velocityXY =>
      Vector2(_inputDirection.x, _inputDirection.y) * kMaxSpeedXY;

  /// Velocity on the Z axis, automatic forward movement.
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

  /// Returns true if the player took damage.
  bool takeDamage() {
    if (damageCooldown > 0) {
      return false;
    }
    damageCooldown = 2;
    // XY velocity is now instant, so no need to reset it.
    _velocityZ = kInitialVelocityZ; // Reset forward speed
    return true;
  }

  void update(double deltaSeconds) {
    if (damageCooldown > 0) {
      damageCooldown = math.max(0, damageCooldown - deltaSeconds);
    }

    // Handle Z movement (automatic acceleration)
    _velocityZ = math.min(
      kMaxVelocityZ,
      _velocityZ + kAccelerationZ * deltaSeconds,
    );

    // Link animation speed to Z-velocity
    final speedProgress =
        (_velocityZ - kInitialVelocityZ) / (kMaxVelocityZ - kInitialVelocityZ);
    runAnimation.playbackTimeScale =
        initialPlaybackTimeScale +
        (kMaxPlaybackTimeScale - initialPlaybackTimeScale) * speedProgress;

    // Combine velocities
    Vector3 velocity = Vector3(
      _inputDirection.x * kMaxSpeedXY, // XY velocity is now instantaneous
      _inputDirection.y * kMaxSpeedXY,
      _velocityZ, // Z-axis is automatic forward motion
    );

    // Displace.
    _position += velocity * deltaSeconds;

    // Apply X-axis boundary checks
    const double kXBoundary = 5.0;
    if (_position.x > kXBoundary) {
      _position.x = kXBoundary;
    } else if (_position.x < -kXBoundary) {
      _position.x = -kXBoundary;
    }

    // Apply Y-axis boundary checks
    const double kYBoundary = 5.0;
    if (_position.y > kYBoundary) {
      _position.y = kYBoundary;
    } else if (_position.y < -kYBoundary) {
      _position.y = -kYBoundary;
    }

    updateNode();
  }
}
