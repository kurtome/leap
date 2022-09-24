import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/physical_behaviors/collision_detection_behavior.dart';
import 'package:leap/src/physical_behaviors/collision_info.dart';
import 'package:leap/src/physical_behaviors/velocity_behavior.dart';
import 'package:leap/src/utils/has_tracked_components.dart';

/// A component which has a physical representation in the world, with
/// collision detection, movement, etc.
///
/// [static] components can be collided with but never move and have a much
/// smaller performance impact on the game loop.
class PhysicalEntity<TGame extends LeapGame> extends Entity
    with HasGameRef<TGame>, TrackedComponent<PhysicalEntity, TGame> {
  /// Position object to store the x/y components
  final Vector2 velocity = Vector2.zero();

  /// Position object to store the x/y components
  final bool static;

  /// Collision detection tags
  final CollisionType collisionType;

  /// Collision detection status from the latest [update]
  CollisionInfo collisionInfo = CollisionInfo();

  /// Multiplier on standard gravity, see [LeapWorld]
  double gravityRate = 1;

  /// When health reaches 0, [isDead] will be true. This needs to be
  /// used by child classes to have any effect
  int health;

  PhysicalEntity({
    this.health = 10,
    this.static = false,
    this.collisionType = CollisionType.none,
    Iterable<Behavior>? behaviors,
  }) : super(behaviors: _physicalBehaviors(static, behaviors));

  /// NOTE: Can only be accessed after component tree has been to the [LeapGame]
  LeapMap get map => gameRef.map;

  LeapWorld get world => gameRef.world;

  /// Tile size (width and height) in pixels
  double get tileSize => gameRef.tileSize;

  /// Whether or not this is "alive" (or not destroyed) in the game
  bool get isAlive => health > 0;

  /// Whether or not this is "dead" (or destroyed) in the game
  bool get isDead => !isAlive;

  /// leftmost point
  double get left {
    return x;
  }

  /// set leftmost point
  set left(double newLeft) {
    x = newLeft;
  }

  /// rightmost point
  double get right {
    return x + width;
  }

  /// set rightmost point
  set right(double newRight) {
    x = newRight - width;
  }

  /// Defined so it can be overridden by slopes, relative top takes into
  /// account the topmost point that could intersect [other] based on its
  /// horizontal position
  double relativeTop(PhysicalEntity other) => top;

  /// topmost point
  double get top {
    return y;
  }

  /// set topmost point by setting [y]
  set top(double newTop) {
    y = newTop;
  }

  /// bottommost point
  double get bottom {
    return y + height;
  }

  /// set bottommost point by setting [y]
  set bottom(double newBottom) {
    y = newBottom - height;
  }

  /// horizontal grid coordinate of the leftmost point on this
  int get gridLeft {
    return (left / tileSize).floor();
  }

  /// horizontal coordinate of the rightmost point on this
  int get gridRight {
    return (right / tileSize).ceil();
  }

  /// vertical grid coordinate of the topmost point on this
  int get gridTop {
    return (top / tileSize).floor();
  }

  /// vertical grid coordinate of the bottommost point on this
  int get gridBottom {
    return (bottom / tileSize).ceil();
  }

  /// horizontal middle point
  double get centerX {
    return x + (width / 2);
  }

  /// vertical middle point
  double get centerY {
    return y + (height / 2);
  }
}

Iterable<Behavior>? _physicalBehaviors(bool static, Iterable<Behavior>? extra) {
  final List<Behavior<Entity>> behaviors;
  if (static) {
    behaviors = <Behavior>[];
  } else {
    behaviors = [CollisionDetectionBehavior(), VelocityBehavior()];
  }
  if (extra != null) {
    behaviors.addAll(extra);
  }
  return behaviors;
}

/// See full implementation in [CollisionDetectionBehavior]
enum CollisionType {
  /// Ignored by collision detection
  none,

  /// Processed as part of the [LeapMap], must be a [LeapMapGroundTile].
  /// The collision detection implementation is much more efficient than
  /// [standard] because it only looks at tiles adjacent to the entity being
  /// processed.
  tilemapGround,

  /// Any non-static entity will check if it collides with this on every game
  /// loop. Since the collision detection system is all axis-aligned bounding
  /// boxes, this is still pretty efficient.
  standard,
}
