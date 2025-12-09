import '../planets/planet.dart';

/// 惑星の振る舞いを定義するインターフェース
abstract class Behavior {
  void update(Planet planet, double elapsedSeconds);
}
