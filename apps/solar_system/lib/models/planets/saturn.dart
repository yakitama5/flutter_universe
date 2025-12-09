import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 土星を表すクラス
class Saturn extends Planet {
  Saturn({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.saturn), radius: 7);

  static const double distanceFromSun = 25;
}
