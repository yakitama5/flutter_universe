import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/models/enum/asset_model.dart';
import 'package:rocket_game/services/resource_cache.dart';
import 'package:vector_math/vector_math.dart';

class KinematicPlayer {
  KinematicPlayer() {
    node = ResourceCache.getModel(AssetModel.starship);
  }

  /// キャラのスケール
  static const double playerScale = 0.5;

  late Node node;

  // XY movement properties
  final double kAccelerationRate = 8; // XY acceleration
  final double kFrictionRate = 4; // XY friction
  final double kMaxSpeedXY = 12; // Max speed on XY plane

  // Z movement properties
  final double kInitialVelocityZ = 2.0;
  final double kAccelerationZ = 2.0;
  final double kMaxVelocityZ = 30.0;

  Vector3 _position = Vector3.zero();
  Vector3 get position => _position;

  Vector3 _direction = Vector3(0, 0, 1);

  /// Velocity on the XY plane, controlled by user input.
  Vector2 _velocityXY = Vector2.zero();
  Vector2 get velocityXY => _velocityXY;

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
    _position = Vector3.zero();
    _velocityXY = Vector2.zero();
    _velocityZ = kInitialVelocityZ;
    _direction = Vector3(0, 0, 1);
    updateNode();
  }

  void updateNode() {
    node.visible = damageCooldown % 0.2 <= 0.12;

    // Create a rotation that points the ship in the direction of its movement
    final transform = Matrix4.compose(
      _position,
      Quaternion.fromTwoVectors(Vector3(0, 0, 1), _direction),
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
    _velocityXY = Vector2.zero();
    _velocityZ = kInitialVelocityZ; // Reset forward speed
    return true;
  }

  void update(double deltaSeconds) {
    if (damageCooldown > 0) {
      damageCooldown = math.max(0, damageCooldown - deltaSeconds);
    }

    // Handle XY movement based on input
    // Speed up when there's input.
    if (_inputDirection.length2 > 1e-3) {
      debugPrint("kiteru?");
      _velocityXY += _inputDirection * kAccelerationRate * deltaSeconds;
      if (_velocityXY.length > 1) {
        _velocityXY.normalize();
      }
    }
    // Slow down when there's no input.
    else if (_velocityXY.length2 > 0) {
      double speed = math.max(
        0,
        _velocityXY.length - kFrictionRate * deltaSeconds,
      );
      _velocityXY = _velocityXY.normalized() * speed;
    }

    // Handle Z movement (automatic acceleration)
    _velocityZ = math.min(
      kMaxVelocityZ,
      _velocityZ + kAccelerationZ * deltaSeconds,
    );

    // Combine velocities
    Vector3 velocity = Vector3(
      _velocityXY.x * kMaxSpeedXY,
      _velocityXY.y * kMaxSpeedXY, // Input controls Y-axis now
      _velocityZ, // Z-axis is automatic forward motion
    );

    // Displace.
    _position += velocity * deltaSeconds;

    updateNode();
  }
}
