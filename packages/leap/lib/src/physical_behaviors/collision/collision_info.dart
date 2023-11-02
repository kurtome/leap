import 'package:leap/leap.dart';

/// Stores collision data for [PhysicalEntity].
class CollisionInfo {
  CollisionInfo({
    this.upCollision,
    this.downCollision,
    this.leftCollision,
    this.rightCollision,
    this.otherCollisions,
  });

  /// Component that this is colliding with on top.
  PhysicalEntity? upCollision;

  /// Component that this is colliding with on bottom.
  PhysicalEntity? downCollision;

  /// Component that this is colliding with on left
  PhysicalEntity? leftCollision;

  /// Component that this is colliding with on right.
  PhysicalEntity? rightCollision;

  /// Non-map collisions.
  List<PhysicalEntity>? otherCollisions;

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
    otherCollisions = null;
  }

  void copyFrom(CollisionInfo collisionInfo) {
    upCollision = collisionInfo.upCollision;
    downCollision = collisionInfo.downCollision;
    leftCollision = collisionInfo.leftCollision;
    rightCollision = collisionInfo.rightCollision;

    otherCollisions?.clear();
    otherCollisions?.addAll(collisionInfo.otherCollisions ?? []);
  }
}
