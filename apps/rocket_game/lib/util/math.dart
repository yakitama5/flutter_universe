import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

/// 2つの値 [a] と [b] を量 [t] で線形補間します。
/// [t] は通常0.0から1.0の範囲です。
T lerp<T>(T a, T b, double t) {
  if (a is double && b is double) {
    return a + (b - a) * t as T;
  } else if (a is Vector3 && b is Vector3) {
    return a + (b - a) * t as T;
  } else {
    throw "サポートされていない型です: ${a.runtimeType}";
  }
}

/// フレームレートに依存しない線形補間（lerp）を実行します。
T lerpDeltaTime<T>(T a, T b, double t, double deltaTime) {
  return lerp(a, b, math.min(1, 1 - math.pow(t, deltaTime).toDouble()));
}

/// 2つの [Vector3] を量 [t] で線形補間します。
Vector3 vector3Lerp(Vector3 a, Vector3 b, double t) {
  return a + (b - a) * t;
}

/// フレームレートに依存しない [Vector3] の線形補間を実行します。
Vector3 vector3LerpDeltaTime(Vector3 a, Vector3 b, double t, double deltaTime) {
  return vector3Lerp(a, b, math.min(1, 1 - math.pow(t, deltaTime).toDouble()));
}
