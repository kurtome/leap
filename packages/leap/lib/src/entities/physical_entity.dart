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
abstract class PhysicalEntity<TGame extends LeapGame> extends PositionedEntity
    with HasGameRef<TGame>, TrackedComponent<PhysicalEntity, TGame> {
  /// Position object to store the x/y components.
  final bool static;

  /// Tags for custom logic, also used by [solidTags]
  final Set<String> tags = {};

  /// Which other entities should be considered solid as part of
  /// normal physics engine / collision detection calculations.
  final Set<String> solidTags = {};

  /// Status effects which can control aspects of the leap engine (gravity,
  /// collisions, etc.), or be used for fully custom handling.
  ///
  /// This is a list instead of a set for two reasons:
  ///  1. For some uses status order could be important
  ///  2. For some uses adding the same status twice could be valid
  List<StatusComponent> get statuses => _statuses;
  final List<StatusComponent> _statuses = [];

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
    super.priority,
    super.position,
    super.size,
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

  /// Defined so it can be overridden by slopes [LeapMapGroundTile]
  bool get isSlope => false;

  /// Defined so it can be overridden by slopes [LeapMapGroundTile]
  int? get rightTop => null;

  /// Defined so it can be overridden by slopes [LeapMapGroundTile]
  int? get leftTop => null;

  /// Defined so it can be overridden by slopes [LeapMapGroundTile]
  int get gridX => -1;

  /// Defined so it can be overridden by slopes [LeapMapGroundTile]
  int get gridY => -1;

  /// Defined so it can be overridden by slopes [LeapMapGroundTile]
  bool get isSlopeFromLeft => false;

  /// Defined so it can be overridden by slopes [LeapMapGroundTile]
  bool get isSlopeFromRight => false;

  /// How much damage this does as a hazard.
  int get hazardDamage => 0;

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

  /// Horizontal middle point.
  set centerX(double x) {
    this.x = x - width / 2;
  }

  /// Vertical middle point.
  double get centerY {
    return y + (height / 2);
  }

  bool isOtherSolid(PhysicalEntity other) {
    return solidTags.intersection(other.tags).isNotEmpty;
  }

  /// Invoked when a child [StatusComponent] is mounted, this is designed
  /// to be called only by [StatusComponent.onMount]
  void onStatusMount(StatusComponent status) {
    _statuses.add(status);
  }

  /// Invoked when a child [StatusComponent] is mounted, this is designed
  /// to be called only by [StatusComponent.onRemove]
  void onStatusRemove(StatusComponent status) {
    _statuses.remove(status);
  }

  bool hasStatus<TStatus extends StatusComponent>() {
    return statuses.whereType<TStatus>().isNotEmpty;
  }

  TStatus? getStatus<TStatus extends StatusComponent>() {
    return statuses.whereType<TStatus>().firstOrNull;
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
