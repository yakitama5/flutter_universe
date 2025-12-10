import 'package:flutter_scene_importer/build_hooks.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    buildModels(
      buildInput: config,
      inputFilePaths: [
        // 用意したassetsを記載
        'assets/glb/dash.glb',
      ],
    );
  });
}
