import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter_scene/scene.dart';
import 'package:model_viewer/camera_up.dart';
import 'package:model_viewer/dash_animation.dart';
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
  AnimationClip? idleClip;
  AnimationClip? runClip;

  bool loaded = false;
  ViewerState viewerState = ViewerState();

  @override
  void initState() {
    super.initState();

    // モデルの読み込み
    Node.fromAsset(
      'build/models/dash.model',
    ).then((model) {
      dashModel = model;

      // アニメーションの設定　+再生
      idleClip =
          dashModel.createAnimationClip(dashModel.findAnimationByName('Idle')!)
            ..loop = true
            ..play();
      runClip =
          dashModel.createAnimationClip(dashModel.findAnimationByName('Run')!)
            ..loop = true
            ..weight = 0
            ..play();

      // シーンにモデルを追加
      scene.add(dashModel);

      // ローディング完了の通知
      debugPrint('Scene loaded.');
      setState(() {
        loaded = true;
      });
    });
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

    // モデルの位置を座標指定
    final translation = Vector3(
      viewerState.modelPositionX,
      viewerState.modelPositionY,
      viewerState.modelPositionZ,
    );
    // モデルの角度をオイラー角で指定
    final rotation = Quaternion.euler(
      viewerState.modelRotationX,
      viewerState.modelRotationY,
      viewerState.modelRotationZ,
    );
    // モデルのスケールを指定
    final scale = Vector3(
      viewerState.modelScale,
      viewerState.modelScale,
      -viewerState.modelScale, // 表示面が逆転するので、Z軸は反転させる
    );

    // `globalTransform`を変更して反映する
    dashModel.globalTransform = Matrix4.compose(translation, rotation, scale);

    // アニメーションを変更する
    switch (viewerState.dashAnimation) {
      case DashAnimation.idle:
        runClip?.weight = 0;
      case DashAnimation.run:
        runClip?.weight = 1;
    }

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
