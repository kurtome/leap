import 'dart:math' as math;

import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_game.dart';
import 'package:leap/src/leap_map.dart';
import 'package:leap/src/physical_behaviors/physical_behaviors.dart';

/// Contains all the logic for the collision detection system,
/// updates the [velocity], [x], [y], and [collisionInfo] of the as needed.
class CollisionDetectionBehavior extends PhysicalBehavior {
  CollisionDetectionBehavior() : prevCollisionInfo = CollisionInfo();

  /// The previous collision information of the entity.
  final CollisionInfo prevCollisionInfo;

  /// Temporal hits list, used to store collision during detection.
  final List<LeapMapGroundTile> _tmpHits = [];

  /// Used to test intersections.
  final _hitboxProxy = _HitboxProxyComponent();

  @override
  void onMount() {
    super.onMount();
    _hitboxProxy.overrideGameRef = parent.gameRef;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isRemoving) {
      return;
    }

    // NOTE: static entities will never run this behavior, so making entities
    // static has important for performance

    prevCollisionInfo.copyFrom(collisionInfo);
    collisionInfo.reset();

    mapCollisionDetection(dt);
    nonMapCollisionDetection(dt);
  }

  void nonMapCollisionDetection(double dt) {
    // This should be a small enough number of  objects that looping over all
    // of them is efficient (we intentionally don't do this for ground tiles for
    // that reason)

    final nonMapCollidables = world.physicals.where(
      (p) => p.collisionType == CollisionType.standard,
    );
    for (final other in nonMapCollidables) {
      if (intersects(other)) {
        collisionInfo.otherCollisions ??= [];
        collisionInfo.otherCollisions!.add(other);
      }
    }
  }

  /// This handles the tilemap ground tiles collisions
  void mapCollisionDetection(double dt) {
    // The collision detection process work in a few steps:
    //
    // 1. Update x/y position as if there were no collisions (from velocity)
    // 2. Find all objects that collide with this in its new position
    // 3. Reset x/y position to original values
    // 4. Inspect the collisions to determine how far the x/y values can be updated
    // 5. Keep references to which collisions still apply, for game logic

    _proxyHitboxForHorizontalMovement(dt);

    if (velocity.x > 0) {
      // Moving right.
      _calculateTilemapHits((c) {
        return c.left <= _hitboxProxy.right &&
            c.right >= _hitboxProxy.right &&
            !c.isPlatform;
      });

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => a.left.compareTo(b.left));
        final firstRightHit = _tmpHits.first;
        if (firstRightHit.isSlopeFromLeft) {
          if (velocity.y >= 0) {
            // Ignore slope underneath while moving upwards.
            collisionInfo.downCollision = firstRightHit;
          } else {
            collisionInfo.rightCollision = firstRightHit;
          }
        } else if (firstRightHit.left >= right) {
          collisionInfo.rightCollision = firstRightHit;
        }
      }
    }
    if (velocity.x < 0) {
      // Moving left.
      _calculateTilemapHits((c) {
        return c.left <= _hitboxProxy.left &&
            c.right >= _hitboxProxy.left &&
            !c.isPlatform;
      });

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => b.right.compareTo(a.right));
        final firstLeftHit = _tmpHits.first;
        if (firstLeftHit.isSlopeFromRight) {
          // Ignore slope underneath while moving upwards, should not collide
          // on left.
          if (velocity.y >= 0) {
            collisionInfo.downCollision = firstLeftHit;
          } else {
            collisionInfo.leftCollision = firstLeftHit;
          }
        } else if (firstLeftHit.right <= left) {
          collisionInfo.leftCollision = firstLeftHit;
        }
      }
    }

    _proxyHitboxForVerticalMovement(dt);

    if (velocity.y > 0 &&
        // Already found down collision from a slope from horizontal movement.
        !collisionInfo.down &&
        !collisionInfo.onSlope) {
      // Moving down.
      _calculateTilemapHits((c) {
        return c.bottom >= bottom &&
            // Bottom edge of this the below top of c.
            c.relativeTop(_hitboxProxy) <= _hitboxProxy.bottom;
      });

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) {
          if (a.isSlope && !b.isSlope) {
            return -1;
          } else if (!a.isSlope && b.isSlope) {
            return 1;
          }
          return a.relativeTop(_hitboxProxy).compareTo(b.top);
        });
        final firstBottomHit = _tmpHits.first;
        collisionInfo.downCollision = firstBottomHit;
      }
    }

    if (velocity.y < 0) {
      // Moving up.
      _calculateTilemapHits((c) {
        return c.top <= top &&
            // Bottom edge of this the below top of c.
            c.bottom >= _hitboxProxy.top &&
            !c.isPlatform;
      });

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => a.bottom.compareTo(b.bottom));
        final firstTopHit = _tmpHits.first;
        collisionInfo.upCollision = firstTopHit;
      }
    }

    // When walking downhill, objects should stick to the slope they are
    // currently on instead of walking off of it.
    if (velocity.y > 0 && !collisionInfo.down && prevCollisionInfo.down) {
      final prevDown = prevCollisionInfo.downCollision!;
      if (velocity.x > 0) {
        // Walking down slope to the right.
        final nextSlopeYDelta = prevDown.rightTop == 0 ? 1 : 0;
        final nextSlope = map.groundTiles[prevDown.gridX + 1]
            [prevDown.gridY + nextSlopeYDelta];
        if (prevDown.right >= left) {
          collisionInfo.downCollision = prevDown;
        } else if (nextSlope != null && nextSlope.isSlopeFromRight) {
          collisionInfo.downCollision = nextSlope;
        }
      } else if (velocity.x < 0) {
        // Walking down slope to the left.
        final nextSlopeYDelta = prevDown.leftTop == 0 ? 1 : 0;
        final nextSlope = map.groundTiles[prevDown.gridX - 1]
            [prevDown.gridY + nextSlopeYDelta];
        if (prevDown.left <= right) {
          collisionInfo.downCollision = prevDown;
        } else if (nextSlope != null && nextSlope.isSlopeFromLeft) {
          collisionInfo.downCollision = nextSlope;
        }
      }
    }
  }

  void _proxyHitboxForVerticalMovement(double dt) {
    // Horizontal axis should be unchanged.
    _hitboxProxy.x = x;
    _hitboxProxy.width = width;

    if (velocity.y > 0) {
      _hitboxProxy.y = y;
    } else {
      _hitboxProxy.y = y + velocity.y * dt;
    }
    _hitboxProxy.height = height + velocity.y.abs() * dt;
  }

  void _proxyHitboxForHorizontalMovement(double dt) {
    // Vertical axis should be unchanged.
    _hitboxProxy.y = y;
    _hitboxProxy.height = height;

    if (velocity.x > 0) {
      _hitboxProxy.x = x;
    } else {
      _hitboxProxy.x = x + velocity.x * dt;
    }
    _hitboxProxy.width = width + velocity.x.abs() * dt;
  }

  void _calculateTilemapHits(bool Function(LeapMapGroundTile) filter) {
    _tmpHits.clear();

    // Find the edges of the map.
    final maxXTile = map.groundTiles.length - 1;
    final maxYTile = map.groundTiles[0].length - 1;

    // Find the edges of this physical component, in tile space.
    final leftTile = math.max(0, _hitboxProxy.gridLeft - 1);
    final rightTile = math.min(maxXTile, _hitboxProxy.gridRight + 1);
    final topTile = math.max(0, _hitboxProxy.gridTop - 1);
    final bottomTile = math.min(maxYTile, _hitboxProxy.gridBottom + 1);

    for (var j = leftTile; j <= rightTile; j++) {
      for (var i = topTile; i <= bottomTile; i++) {
        final tile = map.groundTiles[j][i];
        if (tile != null &&
            intersectsOther(_hitboxProxy, tile) &&
            tile.collisionType == CollisionType.tilemapGround &&
            filter(tile)) {
          _tmpHits.add(tile);
        }
      }
    }
  }

  static bool intersectsOther(PhysicalEntity a, PhysicalEntity b) {
    final bHeight = b.bottom - b.relativeTop(a);
    // This works by checking if the distance between the objects is less than
    // their combined width (meaning they must overlap).
    return ((a.centerX - b.centerX).abs() * 2 < (a.width + b.width)) &&
        ((a.centerY - (b.bottom - (bHeight / 2))).abs() * 2 <
            (a.height + bHeight));
  }

  bool intersects(PhysicalEntity b) {
    final bHeight = b.bottom - b.relativeTop(parent);
    // This works by checking if the distance between the objects is less than
    // their combined width (meaning they must overlap).
    return ((centerX - b.centerX).abs() * 2 < (width + b.width)) &&
        ((centerY - (b.bottom - (bHeight / 2))).abs() * 2 < (height + bHeight));
  }
}

/// Used by [CollisionDetectionBehavior] so it can manipulate width/height
/// in order to calculate collision detection of a moving object without
/// allowing it to pass through another object due to velocity or long
/// time step.
class _HitboxProxyComponent extends PhysicalEntity {
  _HitboxProxyComponent() : super(static: true);

  late LeapGame overrideGameRef;

  @override
  LeapGame get gameRef => overrideGameRef;
}
