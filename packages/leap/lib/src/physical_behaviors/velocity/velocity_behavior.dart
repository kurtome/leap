import 'dart:math' as math;

import 'package:leap/src/physical_behaviors/physical_behavior.dart';

class VelocityBehavior extends PhysicalBehavior {
  @override
  void update(double dt) {
    super.update(dt);

    if (collisionInfo.up) {
      // Set the top of this to the bottom of the collision on top.
      velocity.y = 0;
      top = collisionInfo.upCollision!.bottom;
    }
    if (collisionInfo.down) {
      // Set the bottom of this to the top of the collision underneath.
      velocity.y = 0;
      bottom = collisionInfo.downCollision!.relativeTop(parent);
    }
    if (collisionInfo.right) {
      if (collisionInfo.rightCollision!.isSlopeFromLeft) {
        // Special handling for jumping while walking uphill.
        bottom = math.min(
          bottom,
          collisionInfo.rightCollision!.relativeTop(parent),
        );
      } else {
        velocity.x = 0;
        right = collisionInfo.rightCollision!.left;
      }
    }
    if (collisionInfo.left) {
      if (collisionInfo.leftCollision!.isSlopeFromRight) {
        // Special handling for jumping while walking uphill.
        bottom = math.min(
          bottom,
          collisionInfo.leftCollision!.relativeTop(parent),
        );
      } else {
        velocity.x = 0;
        left = collisionInfo.leftCollision!.right;
      }
    }

    // Velocity has been updated by collision detection,
    // so it's ok to apply it now.
    x += velocity.x * dt;
    y += velocity.y * dt;
  }
}
