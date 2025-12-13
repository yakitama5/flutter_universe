/// 利用可能な3Dモデルの一覧
enum AssetModel {
  asteroid1('build/models/asteroid1.model'),
  asteroid2('build/models/asteroid2.model'),
  starship('build/models/starship.model', unlit: true),
  dash('build/models/dash.model'),
  spike('build/models/spike.model'),
  background('build/models/background.model'),
  ;

  final String path;
  final bool unlit;
  const AssetModel(this.path, {this.unlit = false});
}
