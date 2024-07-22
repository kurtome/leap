import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:leap/leap.dart';

/// This component encapsulates the Tiled map, and in particular builds the
/// grid of ground tiles that make up the terrain of the game.
class LeapMap extends PositionComponent with HasGameRef<LeapGame> {
  LeapMap({
    required this.tileSize,
    required this.tiledMap,
    this.tiledOptions = const TiledOptions(),
    this.tiledObjectHandlers = const {},
    this.groundTileHandlers = const {},
  }) {
    groundLayer = getTileLayer<TileLayer>(
      tiledOptions.groundLayerName,
    );

    // Size of the map component is based on the tile map's grid.
    width = tiledMap.tileMap.map.width * tileSize;
    height = tiledMap.tileMap.map.height * tileSize;
  }

  /// Configuration for the game.
  final TiledOptions tiledOptions;

  /// Tile size (width and height) in pixels.
  final double tileSize;

  /// The Tiled map.
  final TiledComponent tiledMap;

  /// The layer used to populate game terrain.
  late TileLayer groundLayer;

  /// Grid of ground tile from the [groundLayer], will be null for any grid
  /// cell that doesn't have a tile in the layer.
  late List<List<LeapMapGroundTile?>> groundTiles;

  /// Handlers for building components or custom logic in the map from
  /// Tiled Objects, keyed by Tiled "Class" which is settable in the Tiled
  /// editor.
  late Map<String, TiledObjectHandler> tiledObjectHandlers;

  /// Handlers for building components or custom logic ground tiles,
  /// keyed by Tiled "Class" which is settable in the Tiled editor.
  late Map<String, GroundTileHandler> groundTileHandlers;

  @override
  void onMount() {
    groundTiles = LeapMapGroundTile.generate(
      this,
      groundLayer,
      game,
      groundTileHandlers,
      tiledOptions: tiledOptions,
    );
    add(tiledMap);

    /// Object layers
    final objectLayers = tiledMap.tileMap.map.layers
        .where((l) => l.type == LayerType.objectGroup)
        .map((l) => l as ObjectGroup)
        .cast<ObjectGroup>();
    for (final layer in objectLayers) {
      for (final obj in layer.objects) {
        final handler = tiledObjectHandlers[obj.class_];
        if (handler != null) {
          handler.handleObject(obj, layer, this);
        }
      }
    }
    return super.onMount();
  }

  /// Convenience method for accessing Tiled layers in the [tiledMap].
  T getTileLayer<T extends Layer>(String name) {
    final layer = tiledMap.tileMap.getLayer<T>(name);
    if (layer != null) {
      return layer;
    }

    Error.throwWithStackTrace(
      Exception(
        'Layer $name not found, check the Tiled map for the correct name.',
      ),
      StackTrace.current,
    );
  }

  /// Spawn location for the player.
  Vector2 get playerSpawn {
    final metadataLayer = tiledMap.tileMap.getLayer<ObjectGroup>(
      tiledOptions.metadataLayerName,
    );
    if (metadataLayer != null) {
      final spawn = metadataLayer.objects.firstWhere(
        (obj) => obj.class_ == tiledOptions.playerSpawnClass,
      );
      return Vector2(spawn.x, spawn.y);
    } else {
      // Default to a couple tiles in from the upper left corner.
      return Vector2(tileSize * 2, tileSize * 2);
    }
  }

  static Future<LeapMap> load({
    required double tileSize,
    required String tiledMapPath,
    String prefix = 'assets/tiles/',
    AssetBundle? bundle,
    Images? images,
    TiledOptions tiledOptions = const TiledOptions(),
    Map<String, TiledObjectHandler> tiledObjectHandlers = const {},
    Map<String, GroundTileHandler> groundTileHandlers = const {},
  }) async {
    final tiledMap = await TiledComponent.load(
      tiledMapPath,
      Vector2.all(tileSize),
      prefix: prefix,
      bundle: bundle,
      images: images,
      atlasMaxX: tiledOptions.atlasMaxX,
      atlasMaxY: tiledOptions.atlasMaxY,
      tsxPackingFilter: tiledOptions.tsxPackingFilter,
      useAtlas: tiledOptions.useAtlas,
      layerPaintFactory: tiledOptions.layerPaintFactory,
      atlasPackingSpacingX: tiledOptions.atlasPackingSpacingX,
      atlasPackingSpacingY: tiledOptions.atlasPackingSpacingY,
    );
    return LeapMap(
      tileSize: tileSize,
      tiledMap: tiledMap,
      tiledOptions: tiledOptions,
      tiledObjectHandlers: tiledObjectHandlers,
      groundTileHandlers: groundTileHandlers,
    );
  }
}

/// Represents the one tile in the map for collision detection.
/// [TiledComponent] handles drawing the tile images.
///
/// For the purposes of collision detection, the hitbox is assumed to be the
/// entire tile (except when [isSlope] is `true`).
class LeapMapGroundTile extends PhysicalEntity {
  LeapGame gameOverride;

  @override
  LeapGame get game => gameOverride;

  @override
  LeapGame get gameRef => gameOverride;

  final TiledOptions tiledOptions;
  final Tile tile;

  /// Coordinates on the tile grid.
  @override
  int get gridX => _gridX;
  final int _gridX;

  @override
  int get gridY => _gridY;
  final int _gridY;

  /// Topmost point on the left side, important for slopes.
  @override
  int? get leftTopOffset => _leftTopOffset;
  int? _leftTopOffset;

  /// Topmost point on the right side, important for slopes.
  @override
  int? get rightTopOffset => _rightTopOffset;
  int? _rightTopOffset;

  /// Is this a sloped section of ground? If so, this is handled specially
  /// in collision detection to ensure player (or other characters) can walk
  /// up and down it properly.
  @override
  bool get isSlope => _isSlope;
  late bool _isSlope;

  /// Is this a pitched (sloped on the bottom) section of ground?
  /// If so, this is handled specially in collision detection to
  /// ensure player (or other characters) can walk up and down it properly.
  @override
  bool get isPitch => _isPitch;
  late bool _isPitch;

  /// Bottommost point on the left side, for pitched ceilings.
  @override
  int? get leftBottomOffset => _leftBottomOffset;
  int? _leftBottomOffset;

  /// Bottommost point on the right side, for pitched ceilings.
  @override
  int? get rightBottomOffset => _rightBottomOffset;
  int? _rightBottomOffset;

  LeapMapGroundTile(
    this.tile,
    this._gridX,
    this._gridY,
    this.gameOverride, {
    this.tiledOptions = const TiledOptions(),
  }) : super(static: true) {
    width = game.tileSize;
    height = game.tileSize;
    position = Vector2(tileSize * _gridX, tileSize * _gridY);

    _rightTopOffset = tile.properties.getValue<int>(
      tiledOptions.rightTopProperty,
    );
    _leftTopOffset = tile.properties.getValue<int>(
      tiledOptions.leftTopProperty,
    );
    _isSlope = _rightTopOffset != null && _leftTopOffset != null;

    _rightBottomOffset = tile.properties.getValue<int>(
      tiledOptions.rightBottomProperty,
    );
    _leftBottomOffset = tile.properties.getValue<int>(
      tiledOptions.leftBottomProperty,
    );
    _isPitch = _rightBottomOffset != null && _leftBottomOffset != null;

    tags.add(CommonTags.ground);

    // Always add the tile's Class property as tag to make it easy
    // to add small bits of behavior to characters during updates
    // with collisions.
    if (tile.class_ != null && tile.class_ != '') {
      tags.add(tile.class_!);
    }

    hazardDamage = tile.properties.getValue<int>(
          tiledOptions.damageProperty,
        ) ??
        0;
  }

  /// Is this a slope going up from left-to-right.
  @override
  bool get isSlopeFromLeft {
    return isSlope && (leftTopOffset! < rightTopOffset!);
  }

  /// Is this a slope going up from right-to-left.
  @override
  bool get isSlopeFromRight {
    return isSlope && (leftTopOffset! > rightTopOffset!);
  }

  /// Is this a vaulted (sloped on the bottom) going up from left-to-right.
  @override
  bool get isPitchFromLeft {
    return isPitch && (leftBottomOffset! > rightBottomOffset!);
  }

  /// Is this a vaulted (sloped on the bottom) going up from right-to-left.
  @override
  bool get isPitchFromRight {
    return isPitch && (leftBottomOffset! < rightBottomOffset!);
  }

  /// The topmost point on this slope that current is within the
  /// horizontal bounds of [other].
  @override
  double relativeTop(PhysicalEntity other) {
    if (isSlopeFromLeft) {
      final delta = rightTopOffset! - leftTopOffset!;
      final fromLeftPx = other.right - left;
      final ratio = (fromLeftPx / tileSize).clamp(0, 1);
      final result = (bottom - leftTopOffset!) - (delta * ratio);
      return result;
    } else if (isSlopeFromRight) {
      final delta = leftTopOffset! - rightTopOffset!;
      final fromRightPx = other.left - left;
      final ratio = 1 - (fromRightPx / tileSize).clamp(0, 1);
      final result = bottom - (rightTopOffset! + (delta * ratio));
      return result;
    }

    return top;
  }

  /// The bottommost point on this that current is within the
  /// horizontal bounds of [other].
  @override
  double relativeBottom(PhysicalEntity other) {
    if (isPitchFromLeft) {
      final delta = leftBottomOffset! - rightBottomOffset!;
      final fromLeftPx = other.left - left;
      final ratio = 1 - (fromLeftPx / tileSize).clamp(0, 1);
      final result = top + (rightBottomOffset! + (delta * ratio));
      return result;
    } else if (isPitchFromRight) {
      final delta = rightBottomOffset! - leftBottomOffset!;
      final fromRightPx = right - other.right;
      final ratio = 1 - (fromRightPx / tileSize).clamp(0, 1);
      final result = top + (leftBottomOffset! + (delta * ratio));
      return result;
    }

    return bottom;
  }

  /// Builds the tile grid full of ground tiles based on [groundLayer].
  static List<List<LeapMapGroundTile?>> generate(
    LeapMap leapMap,
    TileLayer groundLayer,
    LeapGame game,
    Map<String, GroundTileHandler> groundTileHandlers, {
    TiledOptions tiledOptions = const TiledOptions(),
  }) {
    final groundTiles = List.generate(
      groundLayer.width,
      (_) => List<LeapMapGroundTile?>.filled(groundLayer.height, null),
    );

    final tileMap = leapMap.tiledMap.tileMap.map;
    for (var x = 0; x < groundLayer.width; x++) {
      for (var y = 0; y < groundLayer.height; y++) {
        final gid = groundLayer.tileData![y][x].tile;
        if (gid == 0) {
          continue;
        }
        final tile = tileMap.tileByGid(gid)!;
        var groundTile = LeapMapGroundTile(
          tile,
          x,
          y,
          game,
          tiledOptions: tiledOptions,
        );
        final handler = groundTileHandlers[tile.class_];
        if (handler != null) {
          groundTile = handler.handleGroundTile(groundTile, leapMap);
        }
        groundTiles[x][y] = groundTile;
      }
    }
    return groundTiles;
  }
}
