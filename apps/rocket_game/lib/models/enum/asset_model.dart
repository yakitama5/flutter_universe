/// 利用可能な3Dモデルの一覧
enum AssetModel {
  dash('build/models/dash.model'),
  spike('build/models/spike.model'),
  background('build/models/background.model', unlit: true),
  tunnel('build/models/tunnel.model'),
  portal('build/models/portal.model'),
  ;

  final String path;
  final bool unlit;
  const AssetModel(this.path, {this.unlit = false});
}
