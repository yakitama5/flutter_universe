import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 海王星を表すクラス
class Neptune extends Planet {
  Neptune({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.neptune), radius: 4.5);
  static const double distanceFromSun = 32;
}
