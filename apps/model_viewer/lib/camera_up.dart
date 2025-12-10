import 'package:flutter/material.dart';

/// カメラの上方向を表す列挙型
enum CameraUp {
  up(Icons.arrow_drop_up),
  down(Icons.arrow_drop_down),
  left(Icons.arrow_left),
  right(Icons.arrow_right)
  ;

  final IconData iconData;

  const CameraUp(this.iconData);
}
