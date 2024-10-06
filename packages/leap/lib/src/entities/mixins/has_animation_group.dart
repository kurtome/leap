import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/utils/direction.dart';

mixin HasAnimationGroup on PhysicalEntity {
  AnchoredAnimationGroup get animationGroup;

  /// Whether or not the sprite sheet is looking left
  bool spriteFacesLeft = false;

  /// Force the animation to face a particular direction, overriding default
  /// behavior, for example velocity based looking in
  /// [AnimationVelocityFlipBehavior]
  HorizontalDirection? forceSpriteLookDirection;

  /// Whether or not the animation should currently be looking left.
  /// null indicates direction should remain unchanged.
  HorizontalDirection? get spriteLookDirection {
    if (forceSpriteLookDirection != null) {
      return forceSpriteLookDirection!;
    }

    if (velocity.x == 0) {
      return null;
    } else if (velocity.x < 0) {
      return HorizontalDirection.left;
    } else {
      return HorizontalDirection.right;
    }
  }
}
