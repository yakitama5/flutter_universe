import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:rocket_game/screens/math_utils.dart';
import 'package:vector_math/vector_math.dart';

class FollowCamera {
  static final Vector3 kFollowOffset = Vector3(0, 0, -5);
  static const double kPlayerBoundary = 5.0;
  static final Vector3 kFramingOffset = Vector3(3, 2, 0);

  Vector3 position = Vector3(0, 5, -5);
  Vector3 target = Vector3(0, 0, 10);

  Camera get camera => PerspectiveCamera(position: position, target: target);

  void reset() {
    // Instantly snap camera to the starting position behind the player at origin
    final Vector3 framingTarget = Vector3.zero();
    position = framingTarget + kFollowOffset;
    target = framingTarget + Vector3(0, 0, 30);
  }

  void updateGameplay(
    Vector3 playerPosition,
    Vector3 movementDirection,
    double deltaSeconds,
  ) {
    // Calculate player's relative position within the boundaries [-1, 1]
    final double relativeX = playerPosition.x / kPlayerBoundary;
    final double relativeY = playerPosition.y / kPlayerBoundary;

    // Calculate a dynamic target for framing, this is where the camera wants to center.
    final Vector3 framingTarget =
        playerPosition.clone() -
        Vector3(
          relativeX * kFramingOffset.x,
          relativeY * kFramingOffset.y,
          0,
        );

    // The actual point the camera looks at is ahead of the framing target.
    final Vector3 destinationTarget = framingTarget + Vector3(0, 0, 30);

    // The camera's position is offset from the framing target.
    final Vector3 destinationPosition = framingTarget + kFollowOffset;

    // Use a stronger lerp for the target to make the camera feel more responsive
    // to where the player is, but a weaker lerp for the position to smooth
    // out the movement.
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

  void updateFinishCamera(Vector3 playerPosition, double deltaSeconds) {
    // Define the offset for the finish camera view (front-right)
    final Vector3 finishOffset = Vector3(2, 1, 3);

    // Calculate the destination position and target
    final Vector3 destinationPosition = playerPosition + finishOffset;
    final Vector3 destinationTarget = playerPosition;

    // Smoothly move the camera to the finish position
    position = vector3LerpDeltaTime(
      position,
      destinationPosition,
      0.05, // Use a slow lerp for a cinematic feel
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
