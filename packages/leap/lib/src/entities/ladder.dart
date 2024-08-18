import 'package:flame/components.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

/// A vertical ladder that entities (usually the player) can climb up/down.
abstract class Ladder extends PhysicalEntity {
  Ladder({
    super.position,
    super.size,
    this.topExtraHitbox = 0,
    this.tiledObject,
  }) : super(static: true) {
    y = y - topExtraHitbox;
    height = height + topExtraHitbox;
  }

  Ladder.fromTiledObject({
    required TiledObject tiledObject,
    double topExtraHitbox = 0,
  }) : this(
          position: Vector2(tiledObject.x, tiledObject.y),
          size: Vector2(
            tiledObject.width,
            tiledObject.height,
          ),
          topExtraHitbox: topExtraHitbox,
          tiledObject: tiledObject,
        );

  // Extra hitbox is to make it easier for the ladder hitbox to
  // collide with player walking over the ladder when on the ground
  // flush with the top of the ladder. So they can detect and enter it.
  final double topExtraHitbox;

  /// The actual top of the ladder
  double get logicalTop => top + topExtraHitbox;

  /// [TiledObject] this was built from
  final TiledObject? tiledObject;
}

/// The possible ladder movement states.
enum LadderMovement {
  up,
  down,
  stopped,
}

/// Status indicating the [PhysicalEntity] this is added to is
/// on a ladder.
class OnLadderStatus<T extends LeapGame> extends StatusComponent
    with HasGameReference<T>, IgnoresGravity, IgnoresSolidCollisions {
  OnLadderStatus(this.ladder);

  final Ladder ladder;
  LadderMovement _movement = LadderMovement.stopped;
  LadderMovement get movement => _movement;
  set movement(LadderMovement movement) {
    _prevDirection = _movement;
    _movement = movement;
  }

  LadderMovement _prevDirection = LadderMovement.stopped;
  LadderMovement get prevDirection => _prevDirection;
  double moveSpeed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    if (!parent.collisionInfo.allCollisions.contains(ladder)) {
      // No longer on the ladder
      removeFromParent();
      parent.velocity.y = 0;
      parent.velocity.x = 0;
    } else if (parent.centerY < ladder.logicalTop &&
        movement == LadderMovement.up) {
      // Over halfway off the top
      parent.bottom = ladder.logicalTop;
      removeFromParent();
    } else if (parent.centerY > ladder.bottom &&
        movement == LadderMovement.down) {
      // Over halfway off the bottom
      removeFromParent();
    } else {
      // Still on the ladder.

      // Center the parent and stop x movement
      parent.velocity.x = 0;
      parent.centerX = ladder.centerX;

      // Update ladder y movement.
      switch (movement) {
        case LadderMovement.up:
          parent.velocity.y = -moveSpeed;
          break;
        case LadderMovement.down:
          parent.velocity.y = moveSpeed;
          break;
        case LadderMovement.stopped:
          parent.velocity.y = 0;
          break;
        default:
      }
    }
  }

  @override
  void onMount() {
    super.onMount();
    moveSpeed = game.world.gravity / 10;

    // Update the y position to be fully on the ladder
    if (parent.centerY < ladder.logicalTop) {
      parent.centerY = ladder.logicalTop;
    } else if (parent.centerY > ladder.bottom) {
      parent.centerY = ladder.bottom;
    }
  }
}
