import 'dart:math';

import 'package:leap/leap.dart';

class GravityAccelerationBehavior extends PhysicalBehavior {
  @override
  void update(double dt) {
    if (parent.static ||
        parent.statuses
            .where((s) => s is IgnoresGravity || s is IgnoredByWorld)
            .isNotEmpty) {
      return;
    }

    final world = parent.leapWorld;
    final gAccel = world.gravity * dt;
    final y = parent.velocity.y;
    final desiredVelocity = (gAccel * parent.gravityRate) + y;
    parent.velocity.y = min(desiredVelocity, world.maxGravityVelocity);
  }
}
