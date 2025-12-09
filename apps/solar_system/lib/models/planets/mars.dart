import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 火星を表すクラス
class Mars extends Planet {

  Mars({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.mars), radius: 2.5);
  static const double distanceFromSun = 14;
}
