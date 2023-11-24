import 'package:leap/leap.dart';

/// Stores collision data for [PhysicalEntity].
///
/// There are two types of collisions, solid and non-solid.
///
/// Solid collisions are only considered if their [PhysicalEntity.tags] overlaps
/// with this entity's [PhysicalEntity.solidTags].
/// These could be ground tiles, walls, ceilings or other characters, enememies
/// or movable obstacles.
/// Pretty much anything that normal physical entities can't phase through.
/// Any time an entity collides with another solid entity, the
/// [VelocityBehavior] handles properly updating the position so they never
/// overlap, but they will still be considered a collision.
///
/// Non-solid collisions are other entities which overlap with the
/// [PhysicalEntity], such as other moving characters, enemies, power-ups, etc.
///
/// The [upCollision], [downCollision], [leftCollision], and [rightCollision]
/// are the first solid collision in each direction.
///
/// [allCollisions] include all current solid and plus all non-solid entities
/// that currently overlap or phased through.
class CollisionInfo {
  PhysicalEntity? _upCollision;
  PhysicalEntity? _downCollision;
  PhysicalEntity? _leftCollision;
  PhysicalEntity? _rightCollision;

  /// Entity that this is colliding with on top.
  PhysicalEntity? get upCollision => _upCollision;

  set upCollision(PhysicalEntity? c) {
    if (_upCollision != null) {
      allCollisions?.remove(c);
    }
    if (c != null) {
      addCollision(c);
    }
    _upCollision = c;
  }

  /// Entity that this is colliding with on bottom.
  PhysicalEntity? get downCollision => _downCollision;

  set downCollision(PhysicalEntity? c) {
    if (_downCollision != null) {
      allCollisions?.remove(c);
    }
    if (c != null) {
      addCollision(c);
    }
    _downCollision = c;
  }

  /// Entity that this is colliding with on left
  PhysicalEntity? get leftCollision => _leftCollision;

  set leftCollision(PhysicalEntity? c) {
    if (_leftCollision != null) {
      allCollisions?.remove(c);
    }
    if (c != null) {
      addCollision(c);
    }
    _leftCollision = c;
  }

  /// Entity that this is colliding with on right.
  PhysicalEntity? get rightCollision => _rightCollision;

  set rightCollision(PhysicalEntity? c) {
    if (_rightCollision != null) {
      allCollisions?.remove(c);
    }
    if (c != null) {
      addCollision(c);
    }
    _rightCollision = c;
  }

  /// Non-solid collisions.
  List<PhysicalEntity>? allCollisions;

  void addCollision(PhysicalEntity collision) {
    allCollisions ??= [];
    allCollisions!.add(collision);
  }

  /// Is currently colliding on top
  bool get up => upCollision != null;

  /// Is currently colliding on bottom
  bool get down => downCollision != null;

  /// Is currently colliding on left
  bool get left => leftCollision != null;

  /// Is currently colliding on right
  bool get right => rightCollision != null;

  bool get empty {
    return !up && !down && !left && !right;
  }

  bool get onSlope {
    if (downCollision != null && downCollision is LeapMapGroundTile) {
      return (downCollision! as LeapMapGroundTile).isSlope;
    }
    return false;
  }

  void reset() {
    upCollision = null;
    downCollision = null;
    leftCollision = null;
    rightCollision = null;
    allCollisions = null;
  }

  void copyFrom(CollisionInfo other) {
    _upCollision = other.upCollision;
    _downCollision = other.downCollision;
    _leftCollision = other.leftCollision;
    _rightCollision = other.rightCollision;

    allCollisions?.clear();
    if (other.allCollisions != null) {
      allCollisions ??= [];
      allCollisions!.addAll(other.allCollisions!);
    }
  }
}
