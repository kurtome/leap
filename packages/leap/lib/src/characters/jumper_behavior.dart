import 'dart:math';

import 'package:leap/src/characters/jumper_character.dart';
import 'package:leap/src/entities/ladder.dart';
import 'package:leap/src/physical_behaviors/physical_behavior.dart';

class JumperBehavior extends PhysicalBehavior<JumperCharacter> {
  double lastGroundXVelocity = 0;

  @override
  void update(double dt) {
    super.update(dt);

    final ladderStatus = parent.getStatus<OnLadderStatus>();
    if (ladderStatus != null) {
      updateClimbingLadder(dt, ladderStatus);
    } else {
      updateNormal(dt);
    }
  }

  void updateNormal(double dt) {
    if (parent.jumping) {
      if (parent.isOnGround) {
        velocity.y = -parent.minJumpImpulse;
        if (parent.walking) {
          parent.gravityRate = 1.0;
        } else {
          parent.gravityRate = 1.4;
        }
      } else {
        velocity.y = min(-parent.minJumpImpulse * 0.7, velocity.y);
      }
    } else if (!parent.isOnGround) {
      parent.gravityRate = 2.2;
    } else {
      parent.gravityRate = 1;
    }

    // Only apply walking acceleration when on ground
    if (parent.isOnGround) {
      if (parent.walking) {
        if (parent.faceLeft) {
          velocity.x = -parent.walkSpeed;
        } else {
          velocity.x = parent.walkSpeed;
        }
      } else {
        velocity.x = 0;
      }
      lastGroundXVelocity = velocity.x.abs();
    } else {
      // in the air
      if (parent.faceLeft) {
        velocity.x = -lastGroundXVelocity;
      } else {
        velocity.x = lastGroundXVelocity;
      }
    }
  }

  void updateClimbingLadder(double dt, OnLadderStatus ladderStatus) {
    if (parent.jumping) {
      OnLadderStatus.exitLadder(parent, ladderStatus);
      velocity.y = -parent.minJumpImpulse;
    }
  }
}
