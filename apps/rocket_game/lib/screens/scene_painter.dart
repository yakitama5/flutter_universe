import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';

class RocketScenePainter extends CustomPainter {
  RocketScenePainter({required this.scene, required this.camera});

  Scene scene;
  Camera camera;

  @override
  void paint(Canvas canvas, Size size) {
    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
