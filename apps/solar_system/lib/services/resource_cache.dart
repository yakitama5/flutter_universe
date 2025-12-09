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
          _models[model.name] = model.unlit ? _convertToUnlit(node) : node;
        }),
      ),
    ]);
  }

  /// モデルを取得する
  static Node getModel(AssetModel model) {
    return _models[model.name]!.clone();
  }

  /// ノードをアンリットマテリアルに変換するヘルパー関数
  static Node _convertToUnlit(Node node) {
    if (node.mesh != null) {
      for (final primitive in node.mesh!.primitives) {
        if (primitive.material is PhysicallyBasedMaterial) {
          final pbr = primitive.material as PhysicallyBasedMaterial;
          primitive.material = UnlitMaterial(
            colorTexture: pbr.baseColorTexture,
          );
        }
      }
    }
    for (final child in node.children) {
      _convertToUnlit(child);
    }

    return node;
  }
}
