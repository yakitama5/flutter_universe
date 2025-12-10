import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';

/// 輝く星を表す基底クラス
class ShiningStar {
  ShiningStar({
    required AssetModel model,
    required Vector3 position,
    double rotationX = 0,
    double rotationY = 0,
    double rotationZ = 0,
  }) : node = ResourceCache.getModel(model)
         ..globalTransform = Matrix4.compose(
           position,
           Quaternion.euler(rotationX, rotationY, rotationZ),
           Vector3(1, 1, -1),
         );

  final Node node;
}
