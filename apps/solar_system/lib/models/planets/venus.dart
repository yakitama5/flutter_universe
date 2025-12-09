import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 金星を表すクラス
class Venus extends Planet {

  Venus({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.venus), radius: 3);
  static const double distanceFromSun = 11;
}
