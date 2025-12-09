import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 水星を表すクラス
class Mercury extends Planet {
  Mercury({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.mercury), radius: 2);

  static const double distanceFromSun = 10;
}
