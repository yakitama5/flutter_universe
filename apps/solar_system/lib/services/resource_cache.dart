import 'package:flutter_scene/scene.dart';

import '../models/enum/asset_model.dart';

/// 3Dモデルのキャッシュを管理するクラス
class ResourceCache {
  static final Map<String, Node> _models = {};

  /// モデルをロードする
  static Future<void> preloadAll() async {
    await Future.wait([
      ...AssetModel.values.map(
        (model) => Node.fromAsset(model.path).then((node) {
          _models[model.name] = node;
        }),
      ),
    ]);
  }

  /// モデルを取得する
  static Node getModel(AssetModel model) {
    return _models[model.name]!.clone();
  }
}
