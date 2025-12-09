import 'package:flutter/foundation.dart';
import 'package:flutter_scene/scene.dart';

import '../../services/resource_cache.dart';
import '../enum/asset_model.dart';
import '../planets/planet.dart';

enum DashAnimation { idle, run }

class Ufo extends Planet {
  Ufo({required super.position})
    : super(
        node: ResourceCache.getModel(AssetModel.ufo),
        radius: 1, // 当たり判定は使わないが必須なので設定
      ) {
    _setupAnimations();
  }

  AnimationClip? _idleClip;
  AnimationClip? _walkClip;
  AnimationClip? _runClip;
  DashAnimation _currentAnimation = DashAnimation.idle;

  void _setupAnimations() {
    for (final animation in node.parsedAnimations) {
      debugPrint('Animation: ${animation.name}');
    }
    // アニメーションクリップを作成して初期化
    final idleAnimation = node.findAnimationByName('Idle');
    if (idleAnimation != null) {
      _idleClip = node.createAnimationClip(idleAnimation)
        ..loop = true
        ..play();
    }
    final walkAnimation = node.findAnimationByName('Walk');
    if (walkAnimation != null) {
      _walkClip = node.createAnimationClip(walkAnimation)
        ..loop = true
        ..weight =
            0.0 // 最初は再生しない
        ..play();
    }
    final runAnimation = node.findAnimationByName('Run');
    if (runAnimation != null) {
      _runClip = node.createAnimationClip(runAnimation)
        ..loop = true
        ..weight =
            0.0 // 最初は再生しない
        ..play();
    }
  }

  void playAnimation(DashAnimation animation) {
    if (_currentAnimation == animation) return;

    _currentAnimation = animation;
    switch (animation) {
      case DashAnimation.idle:
        _walkClip?.weight = 0.0;
        _runClip?.weight = 0.0;
      case DashAnimation.run:
        _idleClip?.weight = 0.0;
        _walkClip?.weight = 1.0;
        _runClip?.weight = 1.0;

    }
  }
}
