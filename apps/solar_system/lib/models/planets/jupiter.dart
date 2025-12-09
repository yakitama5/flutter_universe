import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 木星を表すクラス
class Jupiter extends Planet {
  Jupiter({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.jupiter), radius: 8);
  static const double distanceFromSun = 20;
}
