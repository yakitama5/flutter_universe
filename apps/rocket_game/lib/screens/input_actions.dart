import 'package:flutter/services.dart';
import 'package:rocket_game/screens/player.dart';
import 'package:vector_math/vector_math.dart';

/// マウス、キーボード、ゲームパッドからの生の入力データを読み取り、
/// 高レベルのイベントと状態に変換します。
///
/// このクラスのインスタンスは1つだけ作成する必要があります。
class InputActions {
  InputActions() {
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
  }

  Map<String, double> keyboardInputState = {
    "W": 0,
    "A": 0,
    "S": 0,
    "D": 0,
    "Arrow Up": 0,
    "Arrow Left": 0,
    "Arrow Down": 0,
    "Arrow Right": 0,
    " ": 0,
    ".": 0,
  };

  bool absorbKeyEvents = false;
  Vector2 inputDirection = Vector2.zero();

  bool enter = false;

  void updatePlayer(KinematicPlayer player) {
    player.inputDirection = inputDirection;
  }

  bool _onKeyEvent(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if (event is KeyDownEvent) {
      if (keyboardInputState.containsKey(key)) {
        keyboardInputState[key] = 1;
      }
    } else if (event is KeyUpEvent) {
      if (keyboardInputState.containsKey(key)) {
        keyboardInputState[key] = 0;
      }
    }

    inputDirection =
        Vector2(
          (keyboardInputState["D"]! - keyboardInputState["A"]!).toDouble(),
          (keyboardInputState["W"]! - keyboardInputState["S"]!).toDouble(),
        ) +
        Vector2(
          (keyboardInputState["Arrow Right"]! -
                  keyboardInputState["Arrow Left"]!)
              .toDouble(),
          (keyboardInputState["Arrow Up"]! - keyboardInputState["Arrow Down"]!)
              .toDouble(),
        );

    enter = keyboardInputState[" "]! > 0;

    return absorbKeyEvents && keyboardInputState.containsKey(key);
  }
}
