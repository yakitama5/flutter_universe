import 'package:flutter/material.dart';
import 'package:model_viewer/camera_up.dart';
import 'package:model_viewer/viewer_state.dart';

typedef ViewerStateChanged = void Function(ViewerState state);

class ViewerStateBar extends StatelessWidget {
  const ViewerStateBar({
    super.key,
    required this.viewerState,
    required this.onChanged,
  });

  final ViewerState viewerState;
  final ViewerStateChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      children: [
        Text(
          'Model',
          style: tt.headlineMedium,
        ),
        Column(
          children: [
            Text('Position'),
            ModelPositionSlider(
              value: viewerState.modelPositionX,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelPositionX: value)),
              header: 'X',
            ),
            ModelPositionSlider(
              value: viewerState.modelPositionY,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelPositionY: value)),
              header: 'Y',
            ),
            ModelPositionSlider(
              value: viewerState.modelPositionZ,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelPositionZ: value)),
              header: 'Z',
            ),
          ],
        ),
        Column(
          children: [
            Text('Scale'),
            Slider(
              value: viewerState.modelScale,
              min: 0.1,
              max: 5.0,
              divisions: 49,
              label: viewerState.modelScale.toStringAsFixed(2),
              onChanged: (value) {
                onChanged(viewerState.copyWith(modelScale: value));
              },
            ),
          ],
        ),
        Divider(),
        Column(
          children: [
            Text(
              'Rotation',
            ),
            RotationSlider(
              value: viewerState.modelRotationX,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelRotationX: value)),
              header: 'X',
            ),
            RotationSlider(
              value: viewerState.modelRotationY,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelRotationY: value)),
              header: 'Y',
            ),
            RotationSlider(
              value: viewerState.modelRotationZ,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelRotationZ: value)),
              header: 'Z',
            ),
          ],
        ),
        Divider(),
        Text(
          'Camera',
          style: tt.headlineMedium,
        ),
        Column(
          children: [
            Text('Position'),
            CameraPositionSlider(
              value: viewerState.cameraPositionX,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraPositionX: value)),
              header: 'X',
            ),
            CameraPositionSlider(
              value: viewerState.cameraPositionY,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraPositionY: value)),
              header: 'Y',
            ),
            CameraPositionSlider(
              value: viewerState.cameraPositionZ,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraPositionZ: value)),
              header: 'Z',
            ),
          ],
        ),
        Column(
          children: [
            Text('Target'),
            CameraPositionSlider(
              value: viewerState.cameraTargetX,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraTargetX: value)),
              header: 'X',
            ),
            CameraPositionSlider(
              value: viewerState.cameraTargetY,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraTargetY: value)),
              header: 'Y',
            ),
            CameraPositionSlider(
              value: viewerState.cameraTargetZ,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraTargetZ: value)),
              header: 'Z',
            ),
          ],
        ),
        Column(
          crossAxisAlignment: .center,
          children: [
            Text('Camera Up'),
            CameraUpIconButton(
              onPressed: (value) =>
                  onChanged(viewerState.copyWith(cameraUp: value)),
              value: CameraUp.up,
              selectedValue: viewerState.cameraUp,
            ),
            Row(
              mainAxisAlignment: .spaceAround,
              children: [
                CameraUpIconButton(
                  onPressed: (value) =>
                      onChanged(viewerState.copyWith(cameraUp: value)),
                  value: CameraUp.left,
                  selectedValue: viewerState.cameraUp,
                ),
                CameraUpIconButton(
                  onPressed: (value) =>
                      onChanged(viewerState.copyWith(cameraUp: value)),
                  value: CameraUp.right,
                  selectedValue: viewerState.cameraUp,
                ),
              ],
            ),
            CameraUpIconButton(
              onPressed: (value) =>
                  onChanged(viewerState.copyWith(cameraUp: value)),
              value: CameraUp.down,
              selectedValue: viewerState.cameraUp,
            ),
          ],
        ),
      ],
    );
  }
}

class CameraUpSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .center,
      children: [],
    );
  }
}

class CameraUpIconButton extends StatelessWidget {
  const CameraUpIconButton({
    super.key,
    required this.value,
    required this.selectedValue,
    required this.onPressed,
  });

  final CameraUp selectedValue;
  final CameraUp value;
  final ValueChanged<CameraUp> onPressed;

  @override
  Widget build(BuildContext context) {
    if (selectedValue == value) {
      return IconButton.filled(
        onPressed: () => onPressed(value),
        icon: Icon(value.iconData),
      );
    } else {
      return IconButton.outlined(
        onPressed: () => onPressed(value),
        icon: Icon(value.iconData),
      );
    }
  }
}

class RotationSlider extends StatelessWidget {
  const RotationSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.header,
  });

  final String header;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(header),
        Slider(
          value: value,
          min: -6,
          max: 6,
          divisions: 600,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class CameraPositionSlider extends StatelessWidget {
  const CameraPositionSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.header,
  });

  final String header;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(header),
        Slider(
          value: value,
          min: -50,
          max: 50,
          divisions: 100,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class ModelPositionSlider extends StatelessWidget {
  const ModelPositionSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.header,
  });

  final String header;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(header),
        Slider(
          value: value,
          min: -10,
          max: 10,
          divisions: 20,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
