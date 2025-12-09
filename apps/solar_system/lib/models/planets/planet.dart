import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// 惑星を表すデータコンテナクラス
abstract class Planet {
  Planet({required this.position, required this.node, required this.radius});

  final Node node;
  final double radius;
  Vector3 position;
  double rotation = 0; // 回転は外部の振る舞いクラスによって更新される

  void updateNode() {
    // 位置と回転をノードのトランスフォームに適用する
    node.globalTransform =
        Matrix4.translation(position) * Matrix4.rotationY(rotation);
  }
}
