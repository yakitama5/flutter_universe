import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../models/enum/asset_model.dart';
import '../models/planets/earth.dart';
import '../models/planets/jupiter.dart';
import '../models/planets/mars.dart';
import '../models/planets/mercury.dart';
import '../models/planets/moon.dart';
import '../models/planets/neptune.dart';
import '../models/planets/saturn.dart';
import '../models/planets/star.dart';
import '../models/planets/star_dome.dart';
import '../models/planets/sun.dart';
import '../models/planets/uranus.dart';
import '../models/planets/venus.dart';
import '../models/player/ufo.dart';
import '../services/resource_cache.dart';

class ModelCheck extends StatefulWidget {
  const ModelCheck({super.key});

  @override
  State<ModelCheck> createState() => _ModelCheckState();
}

class _ModelCheckState extends State<ModelCheck> {
  final Scene _scene = Scene();
  Node? _modelNode;
  double _rotationX = 0;
  Timer? _timer;
  double _cameraZ = 10;
  AssetModel _selectedModel = AssetModel.ufo;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // ResourceCacheのpreloadが終わってからモデルの読み込みと回転を開始
    ResourceCache.preloadAll().then((_) {
      setState(() {
        _isLoaded = true;
        _loadModel();
        _startRotation();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scene.removeAll();
    super.dispose();
  }

  void _loadModel() {
    if (_modelNode != null) {
      _scene.remove(_modelNode!);
      _modelNode = null;
    }

    Node newNode;
    switch (_selectedModel) {
      case AssetModel.sun:
        newNode = Sun(position: vm.Vector3.zero()).node;
      case AssetModel.mercury:
        newNode = Mercury(position: vm.Vector3.zero()).node;
      case AssetModel.venus:
        newNode = Venus(position: vm.Vector3.zero()).node;
      case AssetModel.earth:
        newNode = Earth(position: vm.Vector3.zero()).node;
      case AssetModel.mars:
        newNode = Mars(position: vm.Vector3.zero()).node;
      case AssetModel.jupiter:
        newNode = Jupiter(position: vm.Vector3.zero()).node;
      case AssetModel.saturn:
        newNode = Saturn(position: vm.Vector3.zero()).node;
      case AssetModel.uranus:
        newNode = Uranus(position: vm.Vector3.zero()).node;
      case AssetModel.neptune:
        newNode = Neptune(position: vm.Vector3.zero()).node;
      case AssetModel.moon:
        newNode = Moon(position: vm.Vector3.zero()).node;
      case AssetModel.ufo:
        final dash = Ufo(position: vm.Vector3.zero());
        dash.playAnimation(DashAnimation.idle);
        newNode = dash.node;
      case AssetModel.fourPointedStar:
      case AssetModel.pentagram:
      case AssetModel.polygonalStar:
        newNode = ShiningStar(
          position: vm.Vector3.zero(),
          model: _selectedModel,
        ).node;
      case AssetModel.starDome:
        newNode = StarDome().node;
    }
    _modelNode = newNode;
    _scene.add(_modelNode!);
    _updateModelTransform();
  }

  void _updateModelTransform() {
    if (_modelNode == null) return;
    final rotationMatrix = vm.Matrix4.rotationX(_rotationX);
    _modelNode!.globalTransform = rotationMatrix;
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _rotationX += 0.01;
        _updateModelTransform();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: ColoredBox(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.7,
                      height: constraints.maxHeight * 0.7,
                      child: CustomPaint(
                        painter: _ModelPainter(
                          scene: _scene,
                          cameraZ: _cameraZ,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButton<AssetModel>(
                value: _selectedModel,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                underline: const SizedBox.shrink(),
                items: AssetModel.values.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model.name),
                  );
                }).toList(),
                onChanged: (AssetModel? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedModel = newValue;
                      _loadModel();
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Camera Z: ${_cameraZ.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: _cameraZ,
                    min: 1,
                    max: 200,
                    onChanged: (value) {
                      setState(() {
                        _cameraZ = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelPainter extends CustomPainter {
  _ModelPainter({required this.scene, required this.cameraZ});

  final Scene scene;
  final double cameraZ;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      position: vm.Vector3(0, 0, cameraZ),
      target: vm.Vector3(0, 0, 0),
      up: vm.Vector3(0, 1, 0),
    );
    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
