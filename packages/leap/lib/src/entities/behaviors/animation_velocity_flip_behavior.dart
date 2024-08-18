import 'package:leap/leap.dart';

/// Flips a [AnchoredAnimationGroup] based on the parent entity's current
/// velocity so that it is facing the correct direction.
class AnimationVelocityFlipBehavior
    extends PhysicalBehavior<HasAnimationGroup> {
  @override
  void update(double dt) {
    final animationFacesLeft = parent.animationFacesLeft;
    final animationGroup = parent.animationGroup;

    // Update sprite for direction
    if ((!animationFacesLeft && velocity.x < 0) ||
        (animationFacesLeft && velocity.x > 0)) {
      animationGroup.scale.x = -animationGroup.scale.x.abs();
    } else if ((!animationFacesLeft && velocity.x > 0) ||
        (animationFacesLeft && velocity.x < 0)) {
      animationGroup.scale.x = animationGroup.scale.x.abs();
    }
  }
}
