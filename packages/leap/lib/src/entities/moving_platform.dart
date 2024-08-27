import 'dart:developer' as developer;

import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

/// A base class for moving platforms, which behave the same as
/// groun tiles but move around, typically on a set path.
abstract class MovingPlatform extends PhysicalEntity {
  MovingPlatform({
    required Vector2 initialPosition,
    required this.moveSpeed,
    required this.tilePath,
    this.loopMode = MovingPlatformLoopMode.reverseAndLoop,
    this.tiledObject,
    super.size,
    // moving platforms should update before other entities so anything
    // standing on top of it from the previous frame can be properly moved
    // with the platform.
    super.priority = 2,
  }) : super(static: true) {
    // Behaviors
    add(_ApplySpeedBehavior());
    add(ApplyVelocityBehavior());
    add(_PreventOvershotPositionBehavior());
    add(_MoveEntitiesAtopBehavior());

    tags.add(CommonTags.ground);

    position = initialPosition;
  }

  MovingPlatform.fromTiledObject(
    TiledObject tiledObject,
  ) : this(
          initialPosition: Vector2(tiledObject.x, tiledObject.y),
          size: Vector2(tiledObject.width, tiledObject.height),
          moveSpeed: _parseMoveSpeed(tiledObject),
          tilePath: _parseTilePath(tiledObject),
          loopMode: _parseLoopMode(tiledObject),
          tiledObject: tiledObject,
        );

  /// [TiledObject] this was built from
  final TiledObject? tiledObject;

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

  /// The [tilePath] in world space, with the initial position added
  /// at the front (index 0).
  late final List<Vector2> positionPath;

  Vector2 get nextPosition => positionPath[_nextPathNode];

  /// What to do when reaching the end of the tilePath.
  final MovingPlatformLoopMode loopMode;

  int _nextPathNode = 1;
  bool _reversing = false;
  bool _stopped = false;

  @override
  @mustCallSuper
  void onLoad() {
    super.onLoad();
    positionPath = _calculatePositionPath(position, tilePath, tileSize);
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

/// Options for MovingPlatformBehavior when it reaches the extends
/// of its path.
enum MovingPlatformLoopMode {
  /// Stop at the end of the path.
  none,

  /// Jump back to the initial position and start the path again.
  resetAndLoop,

  /// Traverse the path in reverse to the initial position, and then
  /// start the path again.
  reverseAndLoop,
}

class _ApplySpeedBehavior extends PhysicalBehavior<MovingPlatform> {
  @override
  void update(double dt) {
    if (parent._stopped) {
      return;
    }

    if (position == parent.positionPath[parent._nextPathNode]) {
      if (parent._reversing) {
        parent._nextPathNode -= 1;
      } else {
        parent._nextPathNode += 1;
      }

      if (parent._nextPathNode < 0) {
        parent._reversing = false;
        parent._nextPathNode = 1;
      }
      if (parent._nextPathNode >= parent.positionPath.length) {
        switch (parent.loopMode) {
          case MovingPlatformLoopMode.none:
            parent._stopped = true;
          case MovingPlatformLoopMode.resetAndLoop:
            position.x = parent.positionPath[0].x;
            position.y = parent.positionPath[0].y;
            parent._nextPathNode = 1;
          case MovingPlatformLoopMode.reverseAndLoop:
            parent._reversing = true;
            parent._nextPathNode = parent.positionPath.length - 2;
        }
      }
    }

    if (parent.nextPosition.x > parent.x) {
      velocity.x = parent.moveSpeed.x * parent.tileSize;
    } else {
      velocity.x = -parent.moveSpeed.x * parent.tileSize;
    }

    if (parent.nextPosition.y > parent.y) {
      velocity.y = parent.moveSpeed.y * parent.tileSize;
    } else {
      velocity.y = -parent.moveSpeed.y * parent.tileSize;
    }
  }
}

class _MoveEntitiesAtopBehavior extends PhysicalBehavior<MovingPlatform> {
  @override
  void update(double dt) {
    if (!parent._stopped) {
      final deltaX = x - prevPosition.x;
      final deltaY = y - prevPosition.y;
      // Update the position of anything on top of this platform. Ideally
      // this happens before the other entity's collision logic
      leapWorld.physicals
          .where(
        (other) =>
            other.isSolidFromBottom &&
            other.collisionInfo.downCollision == parent,
      )
          .forEach((element) {
        element.x += deltaX;
        element.y += deltaY;
      });
    }
  }
}

class _PreventOvershotPositionBehavior
    extends PhysicalBehavior<MovingPlatform> {
  @override
  void update(double dt) {
    if (parent.nextPosition.x > parent.prevPosition.x) {
      position.x =
          position.x.clamp(parent.prevPosition.x, parent.nextPosition.x);
    } else {
      position.x =
          position.x.clamp(parent.nextPosition.x, parent.prevPosition.x);
    }

    if (parent.nextPosition.y > parent.prevPosition.y) {
      position.y =
          position.y.clamp(parent.prevPosition.y, parent.nextPosition.y);
    } else {
      position.y =
          position.y.clamp(parent.nextPosition.y, parent.prevPosition.y);
    }
  }
}
