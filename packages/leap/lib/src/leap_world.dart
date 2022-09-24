import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:leap/leap.dart';

/// The world component encapsulates the physics engine
/// and all of the [PhysicalEntity] components.
///
/// Any [PhysicalEntity] added anywhere in the [LeapGame] component tree
/// will automatically be part of the world via [physicals]
class LeapWorld extends PositionComponent with HasGameRef<LeapGame> {
  /// Tile size (width and height) in pixels
  double tileSize;

  /// Gravity to apply to physical components per-second
  double gravity = 0;

  /// Maximum velocity of physical components per-second
  double maxVelocity = 0;

  LeapWorld({
    this.tileSize = 16,
  });

  LeapMap get map => gameRef.map;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    width = map.width;
    height = map.height;

    gravity = tileSize * 32;
    maxVelocity = tileSize * 20;
  }

  @override
  void update(double dt) {
    final gAccel = gravity * dt;
    for (final physical in physicals.where((p) => !p.static)) {
      final y = physical.velocity.y;
      final desiredVelocity = (gAccel * physical.gravityRate) + y;
      physical.velocity.y = math.min(desiredVelocity, maxVelocity);
    }
    super.update(dt);
  }

  /// All the physical entities in the game
  Iterable<PhysicalEntity> get physicals =>
      gameRef.trackedComponents<PhysicalEntity>().where((p) => !p.isRemoving);

  /// Whether or not [other] is outside of the world bounds
  bool isOutside(PhysicalEntity other) {
    if (other.right < 0 || other.left > map.width) {
      return true;
    }
    if (other.bottom < 0 || other.top > map.height) {
      return true;
    }
    return false;
  }

  /// Whether or not [other] is inside of the world bounds
  bool isInside(PhysicalEntity other) => !isOutside(other);
}
