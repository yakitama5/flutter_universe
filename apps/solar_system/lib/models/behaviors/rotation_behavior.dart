import '../planets/planet.dart';
import 'behavior.dart';

/// 惑星の自転を制御する振る舞い
class RotationBehavior implements Behavior {
  RotationBehavior({required this.rotationSpeed});

  final double rotationSpeed;

  @override
  void update(Planet planet, double elapsedSeconds) {
    planet.rotation += rotationSpeed;
  }
}
