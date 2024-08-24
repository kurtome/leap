import 'package:leap/leap.dart';

/// Flips a [AnchoredAnimationGroup] based on the parent entity's current
/// velocity so that it is facing the correct direction.
class AnimationVelocityFlipBehavior
    extends PhysicalBehavior<HasAnimationGroup> {
  @override
  void update(double dt) {
    final spriteFacesLeft = parent.spriteFacesLeft;
    final animationGroup = parent.animationGroup;

    // Update sprite for direction
    final lookDirection = parent.spriteLookDirection;
    if ((!spriteFacesLeft && lookDirection == SpriteLookDirection.left) ||
        (spriteFacesLeft && lookDirection == SpriteLookDirection.right)) {
      animationGroup.scale.x = -animationGroup.scale.x.abs();
    } else if ((!spriteFacesLeft &&
            lookDirection == SpriteLookDirection.right) ||
        (spriteFacesLeft && lookDirection == SpriteLookDirection.left)) {
      animationGroup.scale.x = animationGroup.scale.x.abs();
    }
  }
}
