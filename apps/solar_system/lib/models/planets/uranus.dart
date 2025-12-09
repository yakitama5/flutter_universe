import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 天王星を表すクラス
class Uranus extends Planet {
  Uranus({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.uranus), radius: 5);
  static const double distanceFromSun = 30;
}
