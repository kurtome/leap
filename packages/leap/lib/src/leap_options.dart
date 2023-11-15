import 'dart:ui';

/// A configurable class that allows the developer to
/// customize different options that Leap will use
/// when reading the map.
class LeapConfiguration {
  const LeapConfiguration({
    this.tiled = const TiledOptions(),
  });

  /// The tiled options, change it to configure how Leap
  /// interpret the tiled map.
  final TiledOptions tiled;
}

/// A configurable class specifically about Tiled names, classes and etc.
class TiledOptions {
  const TiledOptions({
    this.groundLayerName = 'Ground',
    this.metadataLayerName = 'Metadata',
    this.playerSpawnClass = 'PlayerSpawn',
    this.hazardClass = 'Hazard',
    this.damageProperty = 'Damage',
    this.platformClass = 'Platform',
    this.slopeType = 'Slope',
    this.slopeRightTopProperty = 'RightTop',
    this.slopeLeftTopProperty = 'LeftTop',
    this.atlasMaxX,
    this.atlasMaxY,
    this.useAtlas = true,
    this.layerPaintFactory,
  });

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

  /// The max width of the atlas texture, defaults to Flame Tiled default
  /// value when omitted.
  final double? atlasMaxX;

  /// The max height of the atlas texture, defaults to Flame Tiled default
  /// value when omitted.
  final double? atlasMaxY;

  /// A flag that indicates if Flame Tiled should render the map
  /// using `Canvas.drawAtlas` instead of `Canvas.drawImageRect`.
  ///
  /// Defaults to Flame Tiled default value, which is `true`.
  ///
  /// Refer to Flame's SpriteBatch documentation for more information
  /// on the differences between the two methods.
  final bool useAtlas;

  /// A function that allows the developer to customize the paint
  /// used to render tile maps
  ///
  /// When ommited, resorts to Flame Tiled one, which creates a
  /// a white Paint with the layer opacity value.
  final Paint Function(double opacity)? layerPaintFactory;
}
