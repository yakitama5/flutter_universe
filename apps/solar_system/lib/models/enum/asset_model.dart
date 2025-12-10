/// 利用可能な3Dモデルの一覧
enum AssetModel {
  earth('build/models/earth.model'),
  fourPointedStar('build/models/four_pointed_star.model'),
  jupiter('build/models/jupiter.model'),
  mars('build/models/mars.model'),
  mercury('build/models/mercury.model'),
  moon('build/models/moon.model'),
  neptune('build/models/neptune.model'),
  pentagram('build/models/pentagram.model'),
  polygonalStar('build/models/polygonal_star.model'),
  saturn('build/models/saturn.model'),
  sun('build/models/sun.model'),
  uranus('build/models/uranus.model'),
  venus('build/models/venus.model')
  ;

  final String path;
  const AssetModel(this.path);
}
