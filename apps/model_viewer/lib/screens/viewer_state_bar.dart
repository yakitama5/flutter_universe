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

    return Column(
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
                  onChanged(viewerState.copyWith(modelPositionX: value)),
              header: 'X',
            ),
            RotationSlider(
              value: viewerState.modelRotationY,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelPositionY: value)),
              header: 'Y',
            ),
            RotationSlider(
              value: viewerState.modelRotationZ,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(modelPositionZ: value)),
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
            ModelPositionSlider(
              value: viewerState.cameraPositionX,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraPositionX: value)),
              header: 'X',
            ),
            ModelPositionSlider(
              value: viewerState.cameraPositionY,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraPositionY: value)),
              header: 'Y',
            ),
            ModelPositionSlider(
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
            ModelPositionSlider(
              value: viewerState.cameraTargetX,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraTargetX: value)),
              header: 'X',
            ),
            ModelPositionSlider(
              value: viewerState.cameraTargetY,
              onChanged: (value) =>
                  onChanged(viewerState.copyWith(cameraTargetY: value)),
              header: 'Y',
            ),
            ModelPositionSlider(
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
              value: viewerState.cameraUp,
              selectedValue: CameraUp.up,
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                CameraUpIconButton(
                  onPressed: (value) =>
                      onChanged(viewerState.copyWith(cameraUp: value)),
                  value: viewerState.cameraUp,
                  selectedValue: CameraUp.left,
                ),
                CameraUpIconButton(
                  onPressed: (value) =>
                      onChanged(viewerState.copyWith(cameraUp: value)),
                  value: viewerState.cameraUp,
                  selectedValue: CameraUp.right,
                ),
              ],
            ),
            CameraUpIconButton(
              onPressed: (value) =>
                  onChanged(viewerState.copyWith(cameraUp: value)),
              value: viewerState.cameraUp,
              selectedValue: CameraUp.down,
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
      return IconButton(
        onPressed: () => onPressed(value),
        icon: Icon(value.iconData),
      );
    } else {
      return IconButton(
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
          min: -180,
          max: 180,
          divisions: 360,
          label: value.toStringAsFixed(1),
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
          min: -50,
          max: 50,
          divisions: 100,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
