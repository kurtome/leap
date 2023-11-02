import 'dart:developer' as developer;

import 'package:flame/extensions.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

abstract class MovingPlatform<T extends LeapGame> extends PhysicalEntity<T> {
  MovingPlatform({
    required Vector2 initialPosition,
    required double tileSize,
    required this.tilePath,
    required this.moveSpeed,
    this.loopMode = MovingPlatformLoopMode.reverseAndLoop,
    // moving platforms should update before other entities so anything
    // standing on top of it from the previous frame can be properly moved
    // with the platform.
    super.priority = 1,
  }) : super(static: true, collisionType: CollisionType.standard) {
    tags.add('ground');

    position = initialPosition;

    // Snap to the closes position on the tile grid
    position.x = position.x - position.x % tileSize;
    position.y = position.y - position.y % tileSize;

    this.positionPath = _calculatePositionPath(position, tilePath, tileSize);
  }

  MovingPlatform.fromTiledObject(
    TiledObject tiledObject,
    double tileSize,
  ) : this(
          initialPosition: Vector2(tiledObject.x, tiledObject.y),
          moveSpeed: _parseMoveSpeed(tiledObject),
          tilePath: _parseTilePath(tiledObject),
          loopMode: _parseLoopMode(tiledObject),
          tileSize: tileSize,
        );

  /// Move speed in tiles per second
  final Vector2 moveSpeed;

  /// Path of this platform, described as list of nodes of tile offsets.
  ///
  /// For example, the tuple {-2, 4} would indicate that the platform should
  /// move 2 tiles to the left and 4 tiles down from its last node in the
  /// tile path.
  ///
  /// The initial position of the platform is implicitly considered the current
  /// node when the platform is created.
  final List<(int, int)> tilePath;

  late final List<Vector2> positionPath;

  /// What to do when reaching the end of the tilePath.
  final MovingPlatformLoopMode loopMode;

  int _nextPathNode = 1;
  bool _reversing = false;
  bool _stopped = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (!_stopped) {
      final prevX = x;
      final prevY = y;

      updatePositionAndLoop(dt);

      final deltaX = x - prevX;
      final deltaY = y - prevY;
      // Update the position of anything on top of this platform. Ideally
      // this happens before the other entity's collision logic
      world.physicals
          .where((other) => other.collisionInfo.downCollision == this)
          .forEach((element) {
        element.x += deltaX;
        element.y += deltaY;
      });
    }
  }

  void updatePositionAndLoop(double dt) {
    if (position == positionPath[_nextPathNode]) {
      if (_reversing) {
        _nextPathNode -= 1;
      } else {
        _nextPathNode += 1;
      }

      if (_nextPathNode < 0) {
        _reversing = false;
        _nextPathNode = 1;
      }
      if (_nextPathNode >= positionPath.length) {
        switch (loopMode) {
          case MovingPlatformLoopMode.none:
            _stopped = true;
          case MovingPlatformLoopMode.resetAndLoop:
            position.x = positionPath[0].x;
            position.y = positionPath[0].y;
            _nextPathNode = 1;
          case MovingPlatformLoopMode.reverseAndLoop:
            _reversing = true;
            _nextPathNode = positionPath.length - 2;
        }
      }
    }

    final nextPosition = positionPath[_nextPathNode];

    final lastX = position.x;
    if (nextPosition.x > x) {
      position.x += dt * moveSpeed.x * tileSize;
      position.x = position.x.clamp(lastX, nextPosition.x);
    } else {
      position.x -= dt * moveSpeed.x * tileSize;
      position.x = position.x.clamp(nextPosition.x, lastX);
    }

    final lastY = position.y;
    if (nextPosition.y > y) {
      position.y += dt * moveSpeed.y * tileSize;
      position.y = position.y.clamp(lastY, nextPosition.y);
    } else {
      position.y -= dt * moveSpeed.y * tileSize;
      position.y = position.y.clamp(nextPosition.y, lastY);
    }
  }

  static Vector2 _parseMoveSpeed(TiledObject tiledObject) {
    final x = tiledObject.properties.getValue<double>('MoveSpeedX') ?? 1;
    final y = tiledObject.properties.getValue<double>('MoveSpeedY') ?? 1;
    return Vector2(x, y);
  }

  static List<(int, int)> _parseTilePath(TiledObject tiledObject) {
    final rawTilePath =
        tiledObject.properties.getValue<String>('TilePath') ?? '';
    try {
      return rawTilePath
          .trim()
          .split(';')
          .where((s) => s.isNotEmpty)
          .map((rawPair) {
        final parts = rawPair.trim().split(',');
        final x = int.parse(parts[0]);
        final y = int.parse(parts[1]);
        return (x, y);
      }).toList();
    } on Exception catch (e) {
      developer.log('Could not parse tile path', error: e);
      // tile path was malformed, return an empty path
      return [];
    }
  }

  static MovingPlatformLoopMode _parseLoopMode(TiledObject tiledObject) {
    final rawLoopMode =
        tiledObject.properties.getValue<String>('LoopMode') ?? '';
    try {
      return MovingPlatformLoopMode.values.byName(rawLoopMode);
    } on ArgumentError {
      return MovingPlatformLoopMode.reverseAndLoop;
    }
  }

  static List<Vector2> _calculatePositionPath(
    Vector2 initialPosition,
    List<(int, int)> tilePath,
    double tileSize,
  ) {
    if (tilePath.isEmpty) {
      throw ArgumentError('Must have at least one node in the tile path.');
    }

    final positions = [initialPosition.clone()];

    var position = initialPosition;
    for (final node in tilePath) {
      if (node.$1 == 0 && node.$2 == 0) {
        throw ArgumentError("Can't have a 0,0 offset node in the path.");
      }
      final nextPosition = Vector2(
        position.x + tileSize * node.$1,
        position.y + tileSize * node.$2,
      );
      positions.add(nextPosition);
      position = nextPosition;
    }

    return positions;
  }
}

enum MovingPlatformLoopMode {
  none,
  resetAndLoop,
  reverseAndLoop,
}
