import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

class RocketScenePainter extends CustomPainter {
  RocketScenePainter({required this.scene, required this.camera});

  Scene scene;
  Camera camera;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO(yakitama5): テスト用
    final camera = PerspectiveCamera(
      position: Vector3(0, 3, 0),
      target: Vector3(0, 0, 30),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
