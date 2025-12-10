import 'package:flutter/services.dart';
import 'package:rocket_game/screens/player.dart';
import 'package:vector_math/vector_math.dart';

/// Reads and converts raw input data from the mouse/keyboard/gamepad into high
/// level events and state.
///
/// Only one instance of this class should be created.
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

  bool jump = false;
  bool skipToEnd = false;

  void updatePlayer(KinematicPlayer player) {
    player.inputDirection = inputDirection;
  }

  bool _onKeyEvent(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if (event is KeyDownEvent) {
      if (keyboardInputState.containsKey(key)) {
        keyboardInputState[key] = 1;
      }
      print("Key down: $key, new state: ${keyboardInputState[key]}");
    } else if (event is KeyUpEvent) {
      if (keyboardInputState.containsKey(key)) {
        keyboardInputState[key] = 0;
      }
      print("Key up: $key, new state: ${keyboardInputState[key]}");
    } else if (event is KeyRepeatEvent) {
      print("Key repeat: $key");
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

    jump = keyboardInputState[" "]! > 0;

    return absorbKeyEvents && keyboardInputState.containsKey(key);
  }
}
