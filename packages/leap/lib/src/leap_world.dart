import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:leap/leap.dart';

/// Component that manages all of the [PhysicalEntity] for applying
/// gravity, etc.
class LeapWorld extends PositionComponent with HasGameRef<LeapGame> {
  double tileSize;
  double gravity = 0;
  double maxVelocity = 0;

  // TODO(kurtome): Remove this from the world object so it can be configured
  //                per-game.
  late final SimpleCombinedInput input;

  LeapWorld({
    this.tileSize = 16,
  });

  LeapMap get map => gameRef.map;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    width = map.width;
    height = map.height;

    input = SimpleCombinedInput();
    add(input);

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
