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
    this.configuration = const LeapConfiguration(),
  }) {
    groundLayer = getTileLayer<TileLayer>(
      configuration.tiled.groundLayerName,
    );

    // Size of the map component is based on the tile map's grid.
    width = tiledMap.tileMap.map.width * tileSize;
    height = tiledMap.tileMap.map.height * tileSize;
  }

  /// Configuration for the game.
  final LeapConfiguration configuration;

  /// Tile size (width and height) in pixels.
  final double tileSize;

  /// The Tiled map.
  final TiledComponent tiledMap;

  /// The layer used to populate game terrain.
  late TileLayer groundLayer;

  /// Grid of ground tile from the [groundLayer], will be null for any grid
  /// cell that doesn't have a tile in the layer.
  late List<List<LeapMapGroundTile?>> groundTiles;

  @override
  void onMount() {
    groundTiles = LeapMapGroundTile.generate(
      tiledMap.tileMap.map,
      groundLayer,
      configuration: configuration,
    );
    add(tiledMap);
    for (final column in groundTiles) {
      for (final groundTile in column) {
        if (groundTile != null) {
          add(groundTile);
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
      configuration.tiled.metadataLayerName,
    );
    if (metadataLayer != null) {
      final spawn = metadataLayer.objects.firstWhere(
        (obj) => obj.class_ == configuration.tiled.playerSpawnClass,
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
    LeapConfiguration configuration = const LeapConfiguration(),
  }) async {
    final tiledMap = await TiledComponent.load(
      tiledMapPath,
      Vector2.all(tileSize),
      prefix: prefix,
      bundle: bundle,
      images: images,
    );
    return LeapMap(
      tileSize: tileSize,
      tiledMap: tiledMap,
      configuration: configuration,
    );
  }
}

/// Represents the one tile in the map for collision detection.
/// [TiledComponent] handles drawing the tile images.
///
/// For the purposes of collision detection, the hitbox is assumed to be the
/// entire tile (except when [isSlope] is `true`).
class LeapMapGroundTile extends PhysicalEntity {
  final LeapConfiguration configuration;

  final Tile tile;

  /// Coordinates on the tile grid.
  final int gridX;
  final int gridY;

  /// Topmost point on the left side, important for slopes.
  int? leftTop;

  /// Topmost point on the right side, important for slopes.
  int? rightTop;

  /// Is this a sloped section of ground? If so, this is handled specially
  /// in collision detection to ensure player (or other characters) can walk
  /// up and down it properly.
  late bool isSlope;

  /// Hazards (like spikes) damage on collision.
  bool get isHazard => tile.class_ == configuration.tiled.hazardClass;

  /// Platforms only collide from above so the player can jump through them
  /// and land on top.
  bool get isPlatform => tile.class_ == configuration.tiled.platformClass;

  /// Damage to apply when colliding and [isHazard].
  int get hazardDamage {
    final damage = tile.properties.getValue<int>(
      configuration.tiled.damageProperty,
    );
    return damage ?? 0;
  }

  LeapMapGroundTile(
    this.tile,
    this.gridX,
    this.gridY, {
    this.configuration = const LeapConfiguration(),
  }) : super(static: true, collisionType: CollisionType.tilemapGround) {
    isSlope = tile.type == configuration.tiled.slopeType;
    rightTop = tile.properties.getValue<int>(
      configuration.tiled.slopeRightTopProperty,
    );
    leftTop = tile.properties.getValue<int>(
      configuration.tiled.slopeLeftTopProperty,
    );
  }

  @override
  void onMount() {
    super.onMount();
    width = tileSize;
    height = tileSize;
    position = Vector2(tileSize * gridX, tileSize * gridY);
  }

  /// Is this a slop going up from left-to-right.
  bool get isSlopeFromLeft {
    return isSlope && (leftTop! < rightTop!);
  }

  /// Is this a slop going up from right-to-left.
  bool get isSlopeFromRight {
    return isSlope && (leftTop! > rightTop!);
  }

  /// The topmost point on this slope that current is within the
  /// horizontal bounds of [other].
  @override
  double relativeTop(PhysicalEntity other) {
    if (isSlopeFromLeft) {
      final delta = rightTop! - leftTop!;
      final fromLeftPx = other.right - left;
      final ratio = (fromLeftPx / tileSize).clamp(0, 1);
      return (bottom - leftTop!) - (delta * ratio);
    } else if (isSlopeFromRight) {
      final delta = leftTop! - rightTop!;
      final fromRightPx = other.left - left;
      final ratio = 1 - (fromRightPx / tileSize).clamp(0, 1);
      return (bottom - rightTop!) - (delta * ratio);
    }

    return top;
  }

  /// Builds the tile grid full of ground tiles based on [groundLayer].
  static List<List<LeapMapGroundTile?>> generate(
    TiledMap tileMap,
    TileLayer groundLayer, {
    LeapConfiguration configuration = const LeapConfiguration(),
  }) {
    final groundTiles = List.generate(
      groundLayer.width,
      (_) => List<LeapMapGroundTile?>.filled(groundLayer.height, null),
    );

    for (var x = 0; x < groundLayer.width; x++) {
      for (var y = 0; y < groundLayer.height; y++) {
        final gid = groundLayer.tileData![y][x].tile;
        if (gid == 0) {
          continue;
        }
        final tile = tileMap.tileByGid(gid)!;
        groundTiles[x][y] = LeapMapGroundTile(
          tile,
          x,
          y,
          configuration: configuration,
        );
      }
    }
    return groundTiles;
  }
}
