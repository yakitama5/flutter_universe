import 'package:flutter_scene/scene.dart';

import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';

/// 星座ドームを表すクラス
class StarDome {
  StarDome();

  final Node node = ResourceCache.getModel(AssetModel.starDome);
}
