import 'package:flutter_scene_importer/build_hooks.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    buildModels(
      buildInput: config,
      inputFilePaths: [
        'assets/glb/earth.glb',
        'assets/glb/four_pointed_star.glb',
        'assets/glb/jupiter.glb',
        'assets/glb/mars.glb',
        'assets/glb/mercury.glb',
        'assets/glb/moon.glb',
        'assets/glb/neptune.glb',
        'assets/glb/pentagram.glb',
        'assets/glb/polygonal_star.glb',
        'assets/glb/saturn.glb',
        'assets/glb/sun.glb',
        'assets/glb/uranus.glb',
        'assets/glb/venus.glb',
      ],
    );
  });
}
