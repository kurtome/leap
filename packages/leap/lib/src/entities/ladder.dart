import 'package:flame/extensions.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

/// A vertical ladder that entities (usually the player) can climb up/down.
abstract class Ladder<T extends LeapGame> extends PhysicalEntity<T> {
  Ladder({
    super.position,
    super.size,
  }) : super(static: true, collisionType: CollisionType.standard);

  Ladder.fromTiledObject(
    TiledObject tiledObject,
  ) : this(
          position: Vector2(tiledObject.x, tiledObject.y),
          size: Vector2(
            tiledObject.width,
            tiledObject.height,
          ),
        );
}

mixin CanClimbLadder<T extends LeapGame> on PhysicalEntity<T> {
  bool isClimbingLadder = false;
  Ladder<T>? ladderClimbing;

  void enterLadder(Ladder<T> ladder) {
    isClimbingLadder = true;
    ladderClimbing = ladder;
    velocity.x = 0;
    velocity.y = 0;
  }

  void exitLadder() {
    isClimbingLadder = false;
    ladderClimbing = null;
  }
}
