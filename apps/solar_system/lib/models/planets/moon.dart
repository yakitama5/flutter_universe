import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import 'planet.dart';

/// 月を表すクラス
class Moon extends Planet {
  Moon({required super.position})
    : super(node: ResourceCache.getModel(AssetModel.moon), radius: 1);
  static const double distanceFromEarth = 1;
}
