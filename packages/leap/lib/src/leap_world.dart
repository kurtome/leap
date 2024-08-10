import 'dart:collection';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';

/// The world component encapsulates the physics engine
/// and all of the [World] components.
///
/// Any [PhysicalEntity] added anywhere in the [LeapGame] component tree
/// will automatically be part of the world via [physicals].
class LeapWorld extends World with HasGameRef<LeapGame>, HasTimeScale {
  LeapWorld();

  /// Tile size (width and height) in pixels.
  double get tileSize => game.tileSize;

  /// Gravity to apply to physical components per-second.
  late double gravity;

  /// Maximum velocity from gravity of physical components per-second.
  late double maxGravityVelocity;

  LeapMap get map => gameRef.leapMap;

  /// Called as soon as the [LeapGame.tileSize] is known, and any time it
  /// changes.
  @mustCallSuper
  void onTileSize(double tileSize) {
    // Setup default physics constants
    gravity = tileSize * 32;
    maxGravityVelocity = tileSize * 20;
  }

  @override
  @mustCallSuper
  void onLoad() {
    super.onLoad();
  }

  @override
  void update(double dt) {
    final gAccel = gravity * dt;
    for (final physical in physicals.where(
      (p) =>
          !p.static &&
          p.statuses
              .where((s) => s is IgnoresGravity || s is IgnoredByWorld)
              .isEmpty,
    )) {
      final y = physical.velocity.y;
      final desiredVelocity = (gAccel * physical.gravityRate) + y;
      physical.velocity.y = math.min(desiredVelocity, maxGravityVelocity);
    }
    super.update(dt);
  }

  final List<PhysicalEntity> _physicals = [];
  late final _physicalsView = UnmodifiableListView(_physicals);

  /// Called by [PhysicalEntity.onMount]
  void physicalEntityMounted(PhysicalEntity entity) {
    _physicals.add(entity);
  }

  /// Called by [PhysicalEntity.onRemove]
  void physicalEntityRemoved(PhysicalEntity entity) {
    _physicals.remove(entity);
  }

  /// Returns all the physical entities in the game.
  Iterable<PhysicalEntity> get physicals => _physicalsView;

  /// Whether or not [other] is outside of the world bounds.
  bool isOutside(PhysicalEntity other) {
    if (other.right < 0 || other.left > map.width) {
      return true;
    }
    if (other.bottom < 0 || other.top > map.height) {
      return true;
    }
    return false;
  }

  /// Whether or not [other] is inside of the world bounds.
  bool isInside(PhysicalEntity other) => !isOutside(other);
}
