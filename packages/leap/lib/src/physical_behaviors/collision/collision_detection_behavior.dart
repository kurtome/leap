import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:leap/leap.dart';

/// Contains all the logic for the collision detection system,
/// updates the [velocity], [x], [y], and [collisionInfo] of the as needed.
class CollisionDetectionBehavior extends PhysicalBehavior {
  CollisionDetectionBehavior() : prevCollisionInfo = CollisionInfo();

  /// The previous collision information of the entity.
  final CollisionInfo prevCollisionInfo;

  /// All potential hits for this `update` cycle
  final List<PhysicalEntity> _potentialHits = [];

  /// Temporary hits list, used to store collision during detection.
  final List<PhysicalEntity> _tmpHits = [];

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

    prevCollisionInfo.copyFrom(collisionInfo);
    collisionInfo.reset();

    // NOTE: static entities will never run this behavior, so making entities
    // static is important for performance

    if (isRemoving ||
        parent.statuses
            .where((s) => s is IgnoredByWorld || s is IgnoresCollisions)
            .isNotEmpty) {
      return;
    }

    _calculatePotentialHits(dt);
    if (!parent.hasStatus<IgnoresSolidCollisions>()) {
      _solidCollisionDetection(dt);
    }
    if (!parent.hasStatus<IgnoresNonSolidCollisions>()) {
      _nonSolidCollisionDetection(dt);
    }
  }

  void _nonSolidCollisionDetection(double dt) {
    // Now that we have up/down/left/right collisions from solid detection phase,
    // we can re-check which potential hits would still collide even.
    _proxyHitboxForNonSolidHits();
    for (final other in _potentialHits) {
      if (!parent.isOtherSolid(other) && intersectsOther(_hitboxProxy, other)) {
        collisionInfo.addNonSolidCollision(other);
      }
    }
  }

  /// This handles the tilemap ground tiles collisions and collisions with any
  /// other solid entity, as determined by [PhysicalEntity.solidTags]
  void _solidCollisionDetection(double dt) {
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
      _calculateSolidHits((c) {
        return c.left <= _hitboxProxy.right &&
            c.right >= _hitboxProxy.right &&
            c.isSolidFromLeft;
      });

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => a.left.compareTo(b.left));
        final firstRightHit = _tmpHits.first;
        if (firstRightHit.isSlopeFromLeft) {
          if (velocity.y >= 0) {
            // Ignore slope underneath while moving upwards.
            collisionInfo.addDownCollision(firstRightHit);
          } else {
            collisionInfo.addRightCollision(firstRightHit);
          }
        } else if (firstRightHit.left >= right) {
          _tmpHits
              .where((c) => c.left == firstRightHit.left)
              .forEach(collisionInfo.addRightCollision);
        }
      }
    }
    if (velocity.x < 0) {
      // Moving left.
      _calculateSolidHits((c) {
        return c.left <= _hitboxProxy.left &&
            c.right >= _hitboxProxy.left &&
            c.isSolidFromRight;
      });

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => b.right.compareTo(a.right));
        final firstLeftHit = _tmpHits.first;
        if (firstLeftHit.isSlopeFromRight) {
          // Ignore slope underneath while moving upwards, should not collide
          // on left.
          if (velocity.y >= 0) {
            collisionInfo.addDownCollision(firstLeftHit);
          } else {
            collisionInfo.addLeftCollision(firstLeftHit);
          }
        } else if (firstLeftHit.right <= left) {
          _tmpHits
              .where((c) => c.right == firstLeftHit.right)
              .forEach(collisionInfo.addLeftCollision);
        }
      }
    }

    _proxyHitboxForVerticalMovement(dt);

    if (velocity.y > 0 &&
        // Already found down collision from a slope from horizontal movement.
        !collisionInfo.down &&
        !collisionInfo.onSlope) {
      // Moving down.
      _calculateSolidHits((c) {
        return c.bottom > bottom &&
            c.isSolidFromTop &&
            // For one-way platforms from underneath, make sure this is
            // currently above it so this doesn't pop up on top of it
            // when overlapping from the below
            (c.isSolidFromBottom || c.top >= bottom) &&
            // Bottom edge of this the below top of c, with current velocity
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
        final firstDown = _tmpHits.first;
        _tmpHits
            .where((h) => h.top == firstDown.top)
            .forEach(collisionInfo.addDownCollision);
      }
    }

    if (velocity.y < 0) {
      // Moving up.
      _calculateSolidHits((c) {
        return c.top <= top &&
            // Bottom edge of this the below top of c.
            c.bottom >= _hitboxProxy.top &&
            c.isSolidFromBottom;
      });

      if (_tmpHits.isNotEmpty) {
        _tmpHits.sort((a, b) => a.bottom.compareTo(b.bottom));
        _tmpHits.forEach(collisionInfo.addUpCollision);
      }
    }

    // When walking downhill, objects should stick to the slope they are
    // currently on instead of walking off of it.
    if (velocity.y > 0 &&
        !collisionInfo.down &&
        prevCollisionInfo.down &&
        prevCollisionInfo.downCollision!.gridX >= 0 &&
        prevCollisionInfo.downCollision!.gridY >= 0) {
      final prevDown = prevCollisionInfo.downCollision!;
      if (velocity.x > 0) {
        // Walking down slope to the right.
        final nextSlopeYDelta = prevDown.rightTop == 0 ? 1 : 0;
        final nextSlope = map.groundTiles[prevDown.gridX + 1]
            [prevDown.gridY + nextSlopeYDelta];
        if (prevDown.right >= left) {
          collisionInfo.addDownCollision(prevDown);
        } else if (nextSlope != null && nextSlope.isSlopeFromRight) {
          collisionInfo.addDownCollision(nextSlope);
        }
      } else if (velocity.x < 0) {
        // Walking down slope to the left.
        final nextSlopeYDelta = prevDown.leftTop == 0 ? 1 : 0;
        final nextSlope = map.groundTiles[prevDown.gridX - 1]
            [prevDown.gridY + nextSlopeYDelta];
        if (prevDown.left <= right) {
          collisionInfo.addDownCollision(prevDown);
        } else if (nextSlope != null && nextSlope.isSlopeFromLeft) {
          collisionInfo.addDownCollision(nextSlope);
        }
      }
    }
  }

  void _proxyHitboxForPotentialHits(double dt) {
    _hitboxProxy.x = x;
    _hitboxProxy.y = y;
    _hitboxProxy.height = height;
    _hitboxProxy.width = width;

    if (velocity.y > 0) {
      _hitboxProxy.y = y;
    } else {
      _hitboxProxy.y = y + velocity.y * dt;
    }
    _hitboxProxy.height = height + velocity.y.abs() * dt;

    if (velocity.x > 0) {
      _hitboxProxy.x = x;
    } else {
      _hitboxProxy.x = x + velocity.x * dt;
    }
    _hitboxProxy.width = width + velocity.x.abs() * dt;
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

  void _proxyHitboxForNonSolidHits() {
    _hitboxProxy.x = x;
    _hitboxProxy.y = y;
    _hitboxProxy.width = width;
    _hitboxProxy.height = height;

    // This is intended to run after solid collision detection.
    // So, up/down/left/right will only be set if this is moving
    // in that direction and collided with something.

    if (collisionInfo.up) {
      _hitboxProxy.top = collisionInfo.upCollision!.bottom;
    }
    if (collisionInfo.down) {
      _hitboxProxy.bottom = collisionInfo.downCollision!.top;
    }
    if (collisionInfo.left) {
      _hitboxProxy.left = collisionInfo.leftCollision!.right;
    }
    if (collisionInfo.right) {
      _hitboxProxy.right = collisionInfo.rightCollision!.left;
    }
  }

  /// Calculates the solid hits into [_tmpHits] given [filter]
  void _calculateSolidHits(bool Function(PhysicalEntity) filter) {
    _tmpHits.clear();

    for (final other in _potentialHits) {
      if (parent.isOtherSolid(other) &&
          intersectsOther(_hitboxProxy, other) &&
          filter(other)) {
        _tmpHits.add(other);
      }
    }
  }

  /// populates [_potentialHits]
  void _calculatePotentialHits(double dt) {
    _potentialHits.clear();

    // 1.
    // Find the world phyiscal entity potential hits.

    _proxyHitboxForPotentialHits(dt);
    final physicals = world.physicals.where(
      (p) =>
          p != parent &&
          p.statuses
              .where((s) => s is IgnoredByWorld || s is IgnoredByCollisions)
              .isEmpty,
    );
    for (final other in physicals) {
      if (!other.isRemoving && intersectsOther(_hitboxProxy, other)) {
        _potentialHits.add(other);
      }
    }

    // 2.
    // Find the tile map potential hits,
    // tile map entities are handled specially and not added to the world
    // because there can be A LOT of tiles.

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
        if (tile != null) {
          _potentialHits.add(tile);
        }
      }
    }
  }

  static bool intersectsOther(PhysicalEntity a, PhysicalEntity b) {
    // https://github.com/kurtome/leap/issues/30
    // Collision detection math here assumes top left anchor.
    if (a.anchor != Anchor.topLeft || b.anchor != Anchor.topLeft) {
      throw AssertionError('Collision detection requires Anchor.topLeft');
    }

    final bHeight = b.bottom - b.relativeTop(a);
    // This works by checking if the distance between the objects is less than
    // their combined width (meaning they must overlap).
    return ((a.centerX - b.centerX).abs() * 2 < (a.width + b.width)) &&
        ((a.centerY - (b.bottom - (bHeight / 2))).abs() * 2 <
            (a.height + bHeight));
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

  @override
  LeapGame get game => overrideGameRef;
}
