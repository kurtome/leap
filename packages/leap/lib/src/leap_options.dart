/// A configurable class that allows the developer to
/// customize names and classes that Leap will look for
/// when reading the map.
class LeapOptions {
  const LeapOptions({
    this.groundLayerName = 'Ground',
    this.metadataLayerName = 'Metadata',
    this.playerSpawnClass = 'PlayerSpawn',
    this.hazardClass = 'Hazard',
    this.damageProperty = 'Damage',
    this.platformClass = 'Platform',
    this.slopeType = 'Slope',
    this.slopeRightTopProperty = 'RightTop',
    this.slopeLeftTopProperty = 'LeftTop',
  });

  /// The default options for Leap.
  static LeapOptions defaults = const LeapOptions();

  /// Which layer name should be used for the player, defaults to "Ground".
  final String groundLayerName;

  /// Which layer name should be used for the metadata, defaults to "Metadata".
  final String metadataLayerName;

  /// Which class name should be used for the player spawn point,
  /// defaults to "PlayerSpawn".
  final String playerSpawnClass;

  /// Whick class name represents hazard objects, defaults to "Hazard".
  final String hazardClass;

  /// Which property name represents damage, defaults to "Damage".
  final String damageProperty;

  /// Which class name represents platform objects, defaults to "Platform".
  final String platformClass;

  /// Which property name represents the slope type, defaults to "Slope".
  final String slopeType;

  /// Which property name represents the slope left bottom, defaults to
  /// "RightTop".
  final String slopeRightTopProperty;

  /// Which property name represents the slope right bottom, defaults to
  /// "LeftTop".
  final String slopeLeftTopProperty;
}
