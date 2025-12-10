import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
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
  void initState() async {
    // モデルの読み込み
    dashModel = await Node.fromAsset('build/models/dash.model');

    // シーンにモデルを追加
    scene.add(dashModel);

    // ローディング完了の通知
    debugPrint('Scene loaded.');
    setState(() {
      loaded = true;
    });

    super.initState();
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
    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _ScenePainter(scene),
          ),
        ),
        ToolBar(
          viewerState: viewerState,
          onChanged: (state) {
            setState(() {
              viewerState = state;
            });
          },
        ),
      ],
    );
  }
}

typedef ViewerStateChanged = void Function(ViewerState state);

class ToolBar extends StatelessWidget {
  const ToolBar({
    super.key,
    required this.viewerState,
    required this.onChanged,
  });

  final ViewerState viewerState;
  final ViewerStateChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene);

  Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      position: vm.Vector3(0, 0, 0),
      target: vm.Vector3(0, 0, 10),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
