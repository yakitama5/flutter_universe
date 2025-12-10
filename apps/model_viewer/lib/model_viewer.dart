import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter_scene/scene.dart';
import 'package:model_viewer/camera_up.dart';
import 'package:model_viewer/viewer_state.dart';
import 'package:model_viewer/viewer_state_bar.dart';
import 'package:vector_math/vector_math.dart';

class ModelViewer extends StatefulWidget {
  const ModelViewer({super.key});

  @override
  ModelViewerState createState() => ModelViewerState();
}

class ModelViewerState extends State<ModelViewer> {
  // シーンとモデルの定義
  Scene scene = Scene();
  late Node dashModel;

  bool loaded = false;
  ViewerState viewerState = ViewerState();

  @override
  void initState() {
    super.initState();

    // モデルの読み込み
    Node.fromAsset(
      'build/models/dash.model',
    ).then((model) {
      dashModel = _convertToUnlit(model);

      // シーンにモデルを追加
      scene.add(dashModel);

      // ローディング完了の通知
      debugPrint('Scene loaded.');
      setState(() {
        loaded = true;
      });
    });
  }

  /// ノードをアンリットマテリアルに変換する
  Node _convertToUnlit(Node node) {
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

  @override
  void dispose() {
    scene.removeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // モデルを更新
    final translation = Vector3(
      viewerState.modelPositionX,
      viewerState.modelPositionY,
      viewerState.modelPositionZ,
    );
    final rotation = Quaternion.euler(
      viewerState.modelRotationY,
      viewerState.modelRotationZ,
      viewerState.modelRotationX,
    );
    final scale = Vector3(
      viewerState.modelScale,
      viewerState.modelScale,
      -viewerState.modelScale, // 表示面が逆転するので、Z軸は反転させる
    );
    // `globalTransform`を変更して反映する
    dashModel.globalTransform = Matrix4.compose(translation, rotation, scale);

    return Row(
      children: [
        Expanded(
          child: SizedBox.expand(
            child: CustomPaint(
              painter: _ScenePainter(scene, viewerState),
            ),
          ),
        ),
        SizedBox(
          width: 240,
          child: ViewerStateBar(
            viewerState: viewerState,
            onChanged: (state) {
              setState(() {
                viewerState = state;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.viewerState);

  final ViewerState viewerState;
  Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      // カメラの位置 - 3D空間上のどこに置くかを座標指定する
      position: Vector3(
        viewerState.cameraPositionX,
        viewerState.cameraPositionY,
        viewerState.cameraPositionZ,
      ),
      // カメラの向き - 3D空間上のどこを見るかを座標指定する
      target: Vector3(
        viewerState.cameraTargetX,
        viewerState.cameraTargetY,
        viewerState.cameraTargetZ,
      ),
      // カメラの頂点 - カメラの頂点をどこに向けるか
      // 寝かせたり逆さにしたりかたむけたりなど
      up: switch (viewerState.cameraUp) {
        CameraUp.up => Vector3(0, 1, 0),
        CameraUp.down => Vector3(0, -1, 0),
        CameraUp.left => Vector3(-1, 0, 0),
        CameraUp.right => Vector3(1, 0, 0),
      },
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
