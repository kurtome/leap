import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/mixins/mixins.dart';
import 'package:leap/src/physical_behaviors/physical_behaviors.dart';

/// See full implementation in [CollisionDetectionBehavior].
enum CollisionType {
  /// Ignored by collision detection.
  none,

  /// Processed as part of the [LeapMap], must be a [LeapMapGroundTile].
  ///
  /// The collision detection implementation is much more efficient than
  /// [standard] because it only looks at tiles adjacent to the entity being
  /// processed.
  tilemapGround,

  /// Any non-static entity will check if it collides with this on every game
  /// loop. Since the collision detection system is all axis-aligned bounding
  /// boxes, this is still pretty efficient.
  standard,
}

/// A component which has a physical representation in the world, with
/// collision detection, movement, etc.
///
/// [static] components can be collided with but never move and have a much
/// smaller performance impact on the game loop.
class PhysicalEntity<TGame extends LeapGame> extends PositionedEntity
    with HasGameRef<TGame>, TrackedComponent<PhysicalEntity, TGame> {
  /// Position object to store the x/y components.
  final bool static;

  /// Collision detection tags.
  final CollisionType collisionType;

  /// Position object to store the x/y components.
  final Vector2 velocity = Vector2.zero();

  /// Collision detection status from the latest [update].
  final CollisionInfo collisionInfo = CollisionInfo();

  /// Multiplier on standard gravity, see [LeapWorld].
  double gravityRate = 1;

  /// When health reaches 0, [isDead] will be true.
  /// This needs to be used by child classes to have any effect.
  int health;

  PhysicalEntity({
    this.health = 10,
    this.static = false,
    this.collisionType = CollisionType.none,
    Iterable<Behavior<PhysicalEntity>>? behaviors,
  }) : super(
          behaviors: _physicalBehaviors(
            static: static,
            extra: behaviors,
          ),
        );

  /// Can only be accessed after component tree has been to the [LeapGame].
  LeapMap get map => gameRef.leapMap;

  LeapWorld get world => gameRef.world as LeapWorld;

  /// Tile size (width and height) in pixels
  double get tileSize => gameRef.tileSize;

  /// Whether or not this is "alive" (or not destroyed) in the game
  bool get isAlive => health > 0;

  /// Whether or not this is "dead" (or destroyed) in the game.
  bool get isDead => !isAlive;

  /// Leftmost point.
  double get left {
    return x;
  }

  set left(double newLeft) {
    x = newLeft;
  }

  /// Rightmost point.
  double get right {
    return x + width;
  }

  set right(double newRight) {
    x = newRight - width;
  }

  /// Defined so it can be overridden by slopes, relative top takes into
  /// account the topmost point that could intersect [other] based on its
  /// horizontal position.
  double relativeTop(PhysicalEntity other) => top;

  /// Topmost point.
  double get top {
    return y;
  }

  set top(double newTop) {
    y = newTop;
  }

  /// Bottommost point.
  double get bottom {
    return y + height;
  }

  set bottom(double newBottom) {
    y = newBottom - height;
  }

  /// Horizontal grid coordinate of the leftmost point on this.
  int get gridLeft {
    return (left / tileSize).floor();
  }

  /// Horizontal coordinate of the rightmost point on this.
  int get gridRight {
    return (right / tileSize).ceil();
  }

  /// Vertical grid coordinate of the topmost point on this.
  int get gridTop {
    return (top / tileSize).floor();
  }

  /// Vertical grid coordinate of the bottommost point on this.
  int get gridBottom {
    return (bottom / tileSize).ceil();
  }

  /// Horizontal middle point.
  double get centerX {
    return x + (width / 2);
  }

  /// Vertical middle point.
  double get centerY {
    return y + (height / 2);
  }
}

Iterable<Behavior>? _physicalBehaviors({
  required bool static,
  required Iterable<Behavior<PositionedEntity>>? extra,
}) {
  final behaviors = <Behavior<PositionedEntity>>[];
  if (!static) {
    behaviors.addAll([CollisionDetectionBehavior(), VelocityBehavior()]);
  }
  if (extra != null) {
    behaviors.addAll(extra);
  }
  return behaviors;
}
