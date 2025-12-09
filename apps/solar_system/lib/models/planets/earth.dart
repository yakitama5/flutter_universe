import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 地球を表すクラス
class Earth extends Planet {
  Earth({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.earth), radius: 3.5);

  static const double distanceFromSun = 13;
}
