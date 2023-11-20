import 'package:leap/leap.dart';

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
