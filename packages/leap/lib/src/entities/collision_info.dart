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
/// [ApplyVelocityBehavior] handles properly updating the position so they never
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
  List<PhysicalEntity>? _upCollisions;
  List<PhysicalEntity>? _downCollisions;
  List<PhysicalEntity>? _leftCollisions;
  List<PhysicalEntity>? _rightCollisions;

  /// First solid entity that this is colliding with on top.
  PhysicalEntity? get upCollision => _upCollisions?.firstOrNull;

  /// All solid entities that this is colliding with on top.
  List<PhysicalEntity> get upCollisions => _upCollisions ?? const [];

  /// Order will be maintained, and the first up collision will
  /// become the [upCollision] property
  void addUpCollision(PhysicalEntity c) {
    _upCollisions ??= [];
    _upCollisions!.add(c);
    _addCollision(c);
  }

  /// First solid entity that this is colliding with on bottom.
  PhysicalEntity? get downCollision => _downCollisions?.firstOrNull;

  /// All solid entities that this is colliding with on bottom.
  List<PhysicalEntity> get downCollisions => _downCollisions ?? const [];

  void addDownCollision(PhysicalEntity c) {
    _downCollisions ??= [];
    _downCollisions!.add(c);
    _addCollision(c);
  }

  /// First solid entity that this is colliding with on left.
  PhysicalEntity? get leftCollision => _leftCollisions?.firstOrNull;

  /// All solid entities that this is colliding with on left.
  List<PhysicalEntity> get leftCollisions => _leftCollisions ?? const [];

  void addLeftCollision(PhysicalEntity c) {
    _leftCollisions ??= [];
    _leftCollisions!.add(c);
    _addCollision(c);
  }

  /// First solid entity that this is colliding with on right.
  PhysicalEntity? get rightCollision => _rightCollisions?.firstOrNull;

  /// All solid entities that this is colliding with on right.
  List<PhysicalEntity> get rightCollisions => _rightCollisions ?? const [];

  void addRightCollision(PhysicalEntity c) {
    _rightCollisions ??= [];
    _rightCollisions!.add(c);
    _addCollision(c);
  }

  List<PhysicalEntity>? _nonSolidCollisions;

  /// Non-solid collisions, overlapping.
  List<PhysicalEntity> get nonSolidCollisions =>
      _nonSolidCollisions ?? const [];

  List<PhysicalEntity>? _allCollisions;

  /// Both solid & non-solid collisions. The solid collisions will be
  /// touching but not overlapping.
  List<PhysicalEntity> get allCollisions => _allCollisions ?? const [];

  void addNonSolidCollision(PhysicalEntity c) {
    _nonSolidCollisions ??= [];
    _nonSolidCollisions!.add(c);
    _addCollision(c);
  }

  void _addCollision(PhysicalEntity collision) {
    _allCollisions ??= [];
    _allCollisions!.add(collision);
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

  bool get onPitch {
    if (upCollision != null && upCollision is LeapMapGroundTile) {
      return (upCollision! as LeapMapGroundTile).isPitch;
    }
    return false;
  }

  bool get onSlope {
    if (downCollision != null && downCollision is LeapMapGroundTile) {
      return (downCollision! as LeapMapGroundTile).isSlope;
    }
    return false;
  }

  void reset() {
    _upCollisions?.clear();
    _downCollisions?.clear();
    _leftCollisions?.clear();
    _rightCollisions?.clear();
    _nonSolidCollisions?.clear();
    _allCollisions?.clear();
  }

  void copyFrom(CollisionInfo other) {
    _upCollisions?.clear();
    if (other.upCollisions.isNotEmpty) {
      _upCollisions ??= [];
      _upCollisions!.addAll(other.upCollisions);
    }

    _downCollisions?.clear();
    if (other.downCollisions.isNotEmpty) {
      _downCollisions ??= [];
      _downCollisions!.addAll(other.downCollisions);
    }

    _leftCollisions?.clear();
    if (other.leftCollisions.isNotEmpty) {
      _leftCollisions ??= [];
      _leftCollisions!.addAll(other.leftCollisions);
    }

    _rightCollisions?.clear();
    if (other.rightCollisions.isNotEmpty) {
      _rightCollisions ??= [];
      _rightCollisions!.addAll(other.rightCollisions);
    }

    _nonSolidCollisions?.clear();
    if (other.nonSolidCollisions.isNotEmpty) {
      _nonSolidCollisions ??= [];
      _nonSolidCollisions!.addAll(other.nonSolidCollisions);
    }

    _allCollisions?.clear();
    if (other.allCollisions.isNotEmpty) {
      _allCollisions ??= [];
      _allCollisions!.addAll(other.allCollisions);
    }
  }
}
