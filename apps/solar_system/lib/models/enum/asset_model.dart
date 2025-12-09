/// 利用可能な3Dモデルの一覧
enum AssetModel {
  ufo('build/models/ufo.model', unlit: true),
  earth('build/models/earth.model'),
  fourPointedStar('build/models/four_pointed_star.model', unlit: true),
  jupiter('build/models/jupiter.model', unlit: true),
  mars('build/models/mars.model', unlit: true),
  mercury('build/models/mercury.model', unlit: true),
  moon('build/models/moon.model', unlit: true),
  neptune('build/models/neptune.model', unlit: true),
  pentagram('build/models/pentagram.model'),
  polygonalStar('build/models/polygonal_star.model'),
  saturn('build/models/saturn.model'),
  starDome('build/models/star_dome.model'),
  sun('build/models/sun.model', unlit: true),
  uranus('build/models/uranus.model', unlit: true),
  venus('build/models/venus.model', unlit: true);

  final String path;
  final bool unlit;
  const AssetModel(this.path, {this.unlit = false});
}
