import 'package:flame/components.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

/// A vertical ladder that entities (usually the player) can climb up/down.
abstract class Ladder<T extends LeapGame> extends PhysicalEntity<T> {
  Ladder({
    super.position,
    super.size,
    this.topExtraHitbox = 0,
  }) : super(static: true, collisionType: CollisionType.standard) {
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
        );

  // Extra hitbox is to make it easier for the ladder hitbox to
  // collide with player walking over the ladder when on the ground
  // flush with the top of the ladder. So they can detect and enter it.
  final double topExtraHitbox;

  /// The actual top of the ladder
  double get logicalTop => top + topExtraHitbox;
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
    with HasGameReference<T>, IgnoresGravity, IgnoresGroundCollisions {
  OnLadderStatus(this.ladder);

  final Ladder<T> ladder;
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

    final parentEntity = parent! as PhysicalEntity;

    if (!(parentEntity.collisionInfo.otherCollisions?.contains(ladder) ??
        false)) {
      // No longer on the ladder
      removeFromParent();
      parentEntity.velocity.y = 0;
      parentEntity.velocity.x = 0;
    } else if (parentEntity.centerY < ladder.logicalTop &&
        movement == LadderMovement.up) {
      // Over halfway off the top
      parentEntity.bottom = ladder.logicalTop;
      removeFromParent();
    } else if (parentEntity.centerY > ladder.bottom &&
        movement == LadderMovement.down) {
      // Over halfway off the bottom
      removeFromParent();
    } else {
      // Still on the ladder.

      // Center the parent and stop x movement
      parentEntity.velocity.x = 0;
      parentEntity.centerX = ladder.centerX;

      // Update ladder y movement.
      switch (movement) {
        case LadderMovement.up:
          parentEntity.velocity.y = -moveSpeed;
          break;
        case LadderMovement.down:
          parentEntity.velocity.y = moveSpeed;
          break;
        case LadderMovement.stopped:
          parentEntity.velocity.y = 0;
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
    final parentEntity = parent! as PhysicalEntity;
    if (parentEntity.centerY < ladder.logicalTop) {
      parentEntity.centerY = ladder.logicalTop;
    } else if (parentEntity.centerY > ladder.bottom) {
      parentEntity.centerY = ladder.bottom;
    }
  }
}
