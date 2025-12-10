import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:model_viewer/camera_up.dart';
import 'package:model_viewer/screens/viewer_state_bar.dart';
import 'package:model_viewer/viewer_state.dart';
import 'package:vector_math/vector_math.dart' as vm;

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
      'build/models/flutter_logo_baked.model',
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
    final vm.Matrix4 transform =
        vm.Matrix4.translation(
            vm.Vector3(
              viewerState.modelPositionX,
              viewerState.modelPositionY,
              viewerState.modelPositionZ,
            ),
          )
          ..rotateX(viewerState.modelRotationX)
          ..rotateY(viewerState.modelRotationY)
          ..rotateZ(viewerState.modelRotationZ)
          ..scaleByVector3(
            vm.Vector3(
              viewerState.modelScale,
              viewerState.modelScale,
              viewerState.modelScale,
            ),
          );
    dashModel.globalTransform = transform;

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
      position: vm.Vector3(
        viewerState.cameraPositionX,
        viewerState.cameraPositionY,
        viewerState.cameraPositionZ,
      ),
      target: vm.Vector3(
        viewerState.cameraTargetX,
        viewerState.cameraTargetY,
        viewerState.cameraTargetZ,
      ),
      up: switch (viewerState.cameraUp) {
        CameraUp.up => vm.Vector3(0, 1, 0),
        CameraUp.down => vm.Vector3(0, -1, 0),
        CameraUp.left => vm.Vector3(-1, 0, 0),
        CameraUp.right => vm.Vector3(1, 0, 0),
      },
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
