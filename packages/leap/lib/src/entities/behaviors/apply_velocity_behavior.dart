import 'dart:math' as math;

import 'package:leap/leap.dart';

class ApplyVelocityBehavior extends PhysicalBehavior {
  ApplyVelocityBehavior({super.priority});

  @override
  void update(double dt) {
    parent.prevPosition.setFrom(position);

    if (parent.statuses
        .where((s) => s is IgnoredByWorld || s is IgnoresVelocity)
        .isNotEmpty) {
      return;
    }

    if (collisionInfo.up && velocity.y < 0) {
      // Set the top of this to the bottom of the collision on top.
      velocity.y = 0;
      parent.top = collisionInfo.upCollision!.relativeBottom(parent);
    }
    if (collisionInfo.down && velocity.y > 0) {
      // Set the bottom of this to the top of the collision underneath.
      velocity.y = 0;
      parent.bottom = collisionInfo.downCollision!.relativeTop(parent);
    }
    if (collisionInfo.right && velocity.x > 0) {
      if (collisionInfo.rightCollision!.isSlopeFromLeft) {
        parent.bottom = math.min(
          bottom,
          collisionInfo.rightCollision!.relativeTop(parent),
        );
      } else if (collisionInfo.rightCollision!.isPitchFromRight) {
        parent.top = math.max(
          top,
          collisionInfo.rightCollision!.relativeBottom(parent),
        );
      } else {
        velocity.x = 0;
        parent.right = collisionInfo.rightCollision!.left;
      }
    }
    if (collisionInfo.left && velocity.x < 0) {
      if (collisionInfo.leftCollision!.isSlopeFromRight) {
        parent.bottom = math.min(
          bottom,
          collisionInfo.leftCollision!.relativeTop(parent),
        );
      } else if (collisionInfo.leftCollision!.isPitchFromLeft) {
        parent.top = math.max(
          top,
          collisionInfo.leftCollision!.relativeBottom(parent),
        );
      } else {
        velocity.x = 0;
        parent.left = collisionInfo.leftCollision!.right;
      }
    }

    // Velocity has been updated by collision detection,
    // so it's ok to apply it now.
    parent.x += velocity.x * dt;
    parent.y += velocity.y * dt;
  }
}
