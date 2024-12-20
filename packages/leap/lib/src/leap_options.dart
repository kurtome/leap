import 'dart:ui';
import 'package:tiled/tiled.dart';

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
    this.damageProperty = 'Damage',
    this.platformClass = 'Platform',
    this.tagsProperty = 'Tags',
    this.rightTopProperty = 'RightTop',
    this.leftTopProperty = 'LeftTop',
    this.rightBottomProperty = 'RightBottom',
    this.leftBottomProperty = 'LeftBottom',
    this.atlasMaxX,
    this.atlasMaxY,
    this.tsxPackingFilter,
    this.useAtlas = true,
    this.layerPaintFactory,
    this.atlasPackingSpacingX = 0,
    this.atlasPackingSpacingY = 0,
  });

  /// Which layer name should be used for the player, defaults to "Ground".
  final String groundLayerName;

  /// Which layer name should be used for the metadata, defaults to "Metadata".
  final String metadataLayerName;

  /// Which class name should be used for the player spawn point,
  /// defaults to "PlayerSpawn".
  final String playerSpawnClass;

  /// Which property name represents damage, defaults to "Damage".
  final String damageProperty;

  /// Which class name represents platform objects, defaults to "Platform".
  final String platformClass;

  /// Strings to add to `tags`, comma separated
  final String tagsProperty;

  /// Which property name represents the left top, defaults to
  /// "RightTop".
  final String rightTopProperty;

  /// Which property name represents the right top, defaults to
  /// "LeftTop".
  final String leftTopProperty;

  /// Which property name represents the left bottom, defaults to
  /// "RightBottom".
  final String rightBottomProperty;

  /// Which property name represents the right bottom, defaults to
  /// "LeftBottom".
  final String leftBottomProperty;

  /// The max width of the atlas texture, defaults to Flame Tiled default
  /// value when omitted.
  final double? atlasMaxX;

  /// The max height of the atlas texture, defaults to Flame Tiled default
  /// value when omitted.
  final double? atlasMaxY;

  /// A filter that allows you to filter which tilesets should be packed
  /// into Flame Tiled Texture Atlas.
  ///
  /// When omitted defaults to Flame Tiled's default filter, which include all
  /// tilesets in the atlas.
  final bool Function(Tileset)? tsxPackingFilter;

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

  /// The horizontal spacing between tilesets in the atlas texture,
  /// defaults to 0.
  final double atlasPackingSpacingX;

  /// The vertical between tilesets in the atlas texture,
  /// defaults to 0.
  final double atlasPackingSpacingY;
}
