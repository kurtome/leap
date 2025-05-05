import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:leap/leap.dart';

/// A component which has a physical representation in the world, with
/// collision detection, movement, etc.
///
/// Sub-classes should add [GravityAccelerationBehavior],
/// [CollisionDetectionBehavior], and [ApplyVelocityBehavior].
/// It is important for acceleration (velocity changes) from
/// gravity and the entity's own movement to be applied in behaviors before
/// collision detection since that is driven off of the entity velocity.
/// [ApplyVelocityBehavior] should come last when after velocty updates
/// due to acceleration and entity state. Example ordering:
///  1. Acceleration behaviors (including [GravityAccelerationBehavior])
///  2. [CollisionDetectionBehavior]
///  3. Entity's custom reactions to collisions and state changes
///  4. [ApplyVelocityBehavior]
///  5. Rendering related state changes (sprite positioning etc.)
abstract class PhysicalEntity extends PositionedEntity {
  /// Tags for custom logic, also used by [solidTags]
  final Set<String> tags = {};

  /// Which other entities should be considered solid as part of
  /// normal physics engine / collision detection calculations.
  final Set<String> solidTags = {};

  /// Which other entities to ignore during collision detection.
  final Set<String> ignoreTags = {};

  /// When this is considered solid, phase through from above
  bool isSolidFromTop = true;

  /// When this is considered solid, phase through from below
  bool isSolidFromBottom = true;

  /// When this is considered solid, phase through from left
  bool isSolidFromLeft = true;

  /// When this is considered solid, phase through from right
  bool isSolidFromRight = true;

  /// Status effects which can control aspects of the leap engine (gravity,
  /// collisions, etc.), or be used for fully custom handling.
  ///
  /// This is a list instead of a set for two reasons:
  ///  1. For some uses status order could be important
  ///  2. For some uses adding the same status twice could be valid
  List<EntityStatus> get statuses => _statuses;
  final List<EntityStatus> _statuses = [];

  /// Position object to store the x/y components.
  final Vector2 velocity = Vector2.zero();

  /// Collision detection status from the latest [update].
  final CollisionInfo collisionInfo = CollisionInfo();

  /// [collisionInfo] from last game tick
  final CollisionInfo prevCollisionInfo = CollisionInfo();

  /// [position] from last game tick.
  /// Typically set by [ApplyVelocityBehavior], but if an entity
  /// manages its own position state it should set this itself
  final Vector2 prevPosition = Vector2.zero();

  /// Multiplier on standard gravity, see [GravityAccelerationBehavior].
  double gravityRate = 1;

  /// Override the world [maxGravityVelocity] just for this entity
  double? maxGravityVelocityOverride;

  /// Capped downward velocity (positive y), see [GravityAccelerationBehavior]
  double get maxGravityVelocity =>
      maxGravityVelocityOverride ?? leapWorld.maxGravityVelocity;

  PhysicalEntity({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
    super.behaviors,
  });

  /// Draws a rect over the hitbox when this is true.
  bool debugHitbox = false;

  /// Draws a rect over the hitbox of collisions when is true.
  bool debugCollisions = false;

  /// Set in [onLoad], sub-classes can use [HasGameReference] as well if they
  /// want to specify the game type OR create a `game` getter that casts
  /// [leapGame] to the appropriate type.
  late LeapGame leapGame;

  /// Can only be accessed after [onLoad], sub-classes can use
  /// [HasWorldReference] if they prefer to specify the world type OR
  /// create a `game` getter that casts [leapGame] to the appropriate type.
  LeapWorld get leapWorld => leapGame.world;

  /// Can only be accessed after [onLoad]
  LeapMap get leapMap => leapGame.leapMap;

  _DebugHitboxComponent? _debugHitboxComponent;
  _DebugCollisionsComponent? _debugCollisionsComponent;

  @override
  @mustCallSuper
  void updateTree(double dt) {
    // `super.updateTree` calls `this.update` and then updates all children,
    // which is where collision detection and position updates happen
    super.updateTree(dt);
    // after [this.update] and children are updated
    updateAfter(dt);
  }

  /// Note that this is called BEFORE behaviors and other child components,
  /// therefore you may prefer to use [updateAfter] or add a [Behavior]
  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
  }

  /// after [update] and children are updated
  @mustCallSuper
  void updateAfter(double dt) {
    _updateDebugHitbox();
  }

  void _updateDebugHitbox() {
    // Adds a visualization for the entity's hitbox dynamically
    if (debugHitbox) {
      if (_debugHitboxComponent == null) {
        _debugHitboxComponent = _DebugHitboxComponent();
        add(_debugHitboxComponent!);
      }
      _debugHitboxComponent!.width = width;
      _debugHitboxComponent!.height = height;
    } else {
      if (_debugHitboxComponent != null) {
        _debugHitboxComponent!.removeFromParent();
        _debugHitboxComponent = null;
      }
    }

    // Adds a visualization for the entity's collisions dynamically
    if (debugCollisions) {
      if (_debugCollisionsComponent == null) {
        _debugCollisionsComponent = _DebugCollisionsComponent();
        add(_debugCollisionsComponent!);
      }
    } else {
      if (_debugCollisionsComponent != null) {
        _debugCollisionsComponent!.removeFromParent();
        _debugCollisionsComponent = null;
      }
    }
  }

  @override
  @mustCallSuper
  void onLoad() {
    super.onLoad();
    leapGame = findGame()! as LeapGame;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    leapWorld.physicalEntityMounted(this);
  }

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();
    leapGame.world.physicalEntityRemoved(this);
  }

  /// Tile size (width and height) in pixels
  double get tileSize => leapGame.tileSize;

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

  /// Defined so it can be overridden by vaulted ceilings, relative bottom takes
  /// into account the topmost point that could intersect [other] based on its
  /// horizontal position.
  double relativeBottom(PhysicalEntity other) => bottom;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  bool get isSlope => false;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  bool get isPitch => false;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  int? get rightTopOffset => null;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  int? get leftTopOffset => null;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  int? get rightBottomOffset => null;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  int? get leftBottomOffset => null;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  int get gridX => -1;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  int get gridY => -1;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  bool get isSlopeFromLeft => false;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  bool get isSlopeFromRight => false;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  bool get isPitchFromLeft => false;

  /// Defined so it can be overridden by [LeapMapGroundTile]
  bool get isPitchFromRight => false;

  /// How much damage this does by default to other entities.
  /// This property has no affect on its own, it is for custom logic.
  /// Typically this is applied as the result of a collision, if
  /// the colliding entity has a [tags] value that indicates it is
  /// a "Hazard" or "Spikes" or "Enemy" etc.
  int hazardDamage = 0;

  /// Topmost point.
  double get top {
    return y;
  }

  set top(double newTop) {
    y = newTop;
  }

  /// [top] from last game tick
  double get prevTop {
    return prevPosition.y;
  }

  /// Bottommost point.
  double get bottom {
    return y + height;
  }

  set bottom(double newBottom) {
    y = newBottom - height;
  }

  /// [bottom] from last game tick
  double get prevBottom {
    return prevPosition.y + height;
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

  /// Vertical middle point.
  set centerY(double y) {
    this.y = y - (height / 2);
  }

  /// Whether or [other] should be considered solid relative to this during
  /// collision detection.
  bool isOtherSolid(PhysicalEntity other) {
    return solidTags.intersection(other.tags).isNotEmpty;
  }

  /// Invoked when a child [EntityStatus] is mounted, this is designed
  /// to be called only by [EntityStatus.onMount]
  void onStatusMount(EntityStatus status) {
    _statuses.add(status);
  }

  /// Invoked when a child [EntityStatus] is mounted, this is designed
  /// to be called only by [EntityStatus.onRemove]
  void onStatusRemove(EntityStatus status) {
    _statuses.remove(status);
  }

  /// Whether or not this has a status of type [TStatus].
  bool hasStatus<TStatus extends EntityStatus>() {
    return statuses.whereType<TStatus>().isNotEmpty;
  }

  /// Gets the first status having type [TStatus] or null if there is none.
  TStatus? getStatus<TStatus extends EntityStatus>() {
    return statuses.whereType<TStatus>().firstOrNull;
  }
}

/// Component added as a child to ensure it is drawn on top of the
/// entity's standard rendering.
class _DebugHitboxComponent extends PositionComponent {
  final _paint = Paint()..color = Colors.green.withValues(alpha: 0.6);

  @override
  int get priority => 9998;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}

/// Component added as a child to ensure it is drawn on top of the
/// entity's standard rendering.
class _DebugCollisionsComponent extends PositionComponent
    with HasAncestor<PhysicalEntity> {
  final _paint = Paint()..color = Colors.red.withValues(alpha: 0.6);

  @override
  int get priority => 9999;

  @override
  void render(Canvas canvas) {
    for (final collision in ancestor.collisionInfo.allCollisions) {
      final left = collision.x - ancestor.x;
      final top = collision.y - ancestor.y;
      final rect = Rect.fromLTRB(
        left,
        top,
        left + collision.width,
        top + collision.height,
      );

      canvas.drawRect(rect, _paint);
    }
  }
}
