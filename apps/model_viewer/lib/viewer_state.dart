import 'package:flutter/foundation.dart'; // @immutable アノテーションなどで使用 (任意)
import 'package:model_viewer/camera_up.dart';

/// モデルビューアの状態を管理するクラス
@immutable
final class ViewerState {
  const ViewerState({
    this.modelPositionX = 0,
    this.modelPositionY = 0,
    this.modelPositionZ = 0,
    this.modelRotationX = 0,
    this.modelRotationY = 0,
    this.modelRotationZ = 0,
    this.modelScale = 1,
    this.cameraPositionX = 0,
    this.cameraPositionY = 0,
    this.cameraPositionZ = 0,
    this.cameraTargetX = 0,
    this.cameraTargetY = 0,
    this.cameraTargetZ = 10,
    this.cameraUp = CameraUp.up,
  });

  // モデルの位置
  final double modelPositionX;
  final double modelPositionY;
  final double modelPositionZ;
  // モデルの回転
  final double modelRotationX;
  final double modelRotationY;
  final double modelRotationZ;
  // モデルのスケール
  final double modelScale;
  // カメラの位置
  final double cameraPositionX;
  final double cameraPositionY;
  final double cameraPositionZ;
  // カメラのターゲット位置
  final double cameraTargetX;
  final double cameraTargetY;
  final double cameraTargetZ;
  // カメラの頂点
  final CameraUp cameraUp;

  /// 現在のインスタンスを元に、指定されたフィールドだけを更新した新しいインスタンスを返します。
  ViewerState copyWith({
    double? modelPositionX,
    double? modelPositionY,
    double? modelPositionZ,
    double? modelRotationX,
    double? modelRotationY,
    double? modelRotationZ,
    double? modelScale,
    double? cameraPositionX,
    double? cameraPositionY,
    double? cameraPositionZ,
    double? cameraTargetX,
    double? cameraTargetY,
    double? cameraTargetZ,
    CameraUp? cameraUp,
  }) {
    return ViewerState(
      modelPositionX: modelPositionX ?? this.modelPositionX,
      modelPositionY: modelPositionY ?? this.modelPositionY,
      modelPositionZ: modelPositionZ ?? this.modelPositionZ,
      modelRotationX: modelRotationX ?? this.modelRotationX,
      modelRotationY: modelRotationY ?? this.modelRotationY,
      modelRotationZ: modelRotationZ ?? this.modelRotationZ,
      modelScale: modelScale ?? this.modelScale,
      cameraPositionX: cameraPositionX ?? this.cameraPositionX,
      cameraPositionY: cameraPositionY ?? this.cameraPositionY,
      cameraPositionZ: cameraPositionZ ?? this.cameraPositionZ,
      cameraTargetX: cameraTargetX ?? this.cameraTargetX,
      cameraTargetY: cameraTargetY ?? this.cameraTargetY,
      cameraTargetZ: cameraTargetZ ?? this.cameraTargetZ,
      cameraUp: cameraUp ?? this.cameraUp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ViewerState &&
        other.modelPositionX == modelPositionX &&
        other.modelPositionY == modelPositionY &&
        other.modelPositionZ == modelPositionZ &&
        other.modelRotationX == modelRotationX &&
        other.modelRotationY == modelRotationY &&
        other.modelRotationZ == modelRotationZ &&
        other.modelScale == modelScale &&
        other.cameraPositionX == cameraPositionX &&
        other.cameraPositionY == cameraPositionY &&
        other.cameraPositionZ == cameraPositionZ &&
        other.cameraTargetX == cameraTargetX &&
        other.cameraTargetY == cameraTargetY &&
        other.cameraTargetZ == cameraTargetZ &&
        other.cameraUp == cameraUp;
  }

  @override
  int get hashCode {
    return Object.hash(
      modelPositionX,
      modelPositionY,
      modelPositionZ,
      modelRotationX,
      modelRotationY,
      modelRotationZ,
      modelScale,
      cameraPositionX,
      cameraPositionY,
      cameraPositionZ,
      cameraTargetX,
      cameraTargetY,
      cameraTargetZ,
      cameraUp,
    );
  }

  @override
  String toString() {
    return 'ViewerState('
        'modelPos: ($modelPositionX, $modelPositionY, $modelPositionZ), '
        'modelRot: ($modelRotationX, $modelRotationY, $modelRotationZ), '
        'scale: $modelScale, '
        'cameraPos: ($cameraPositionX, $cameraPositionY, $cameraPositionZ), '
        'cameraTarget: ($cameraTargetX, $cameraTargetY, $cameraTargetZ), '
        'up: $cameraUp'
        ')';
  }
}
