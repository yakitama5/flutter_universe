import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 太陽を表すクラス
class Sun extends Planet {
  Sun({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.sun), radius: 71);
}
