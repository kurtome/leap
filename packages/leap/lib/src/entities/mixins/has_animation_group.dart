import 'package:leap/src/entities/anchored_animation_group.dart';
import 'package:leap/src/entities/physical_entity.dart';

mixin HasAnimationGroup on PhysicalEntity {
  AnchoredAnimationGroup get animationGroup;

  /// Whether or not the sprite sheet is looking left
  bool spriteFacesLeft = false;

  SpriteLookDirection? forceSpriteLookDirection;

  /// Whether or not the animation should currently be looking left
  SpriteLookDirection get spriteLookDirection {
    if (forceSpriteLookDirection != null) {
      return forceSpriteLookDirection!;
    }

    if (velocity.x == 0) {
      return SpriteLookDirection.previous;
    } else if (velocity.x < 0) {
      return SpriteLookDirection.left;
    } else {
      return SpriteLookDirection.right;
    }
  }
}

enum SpriteLookDirection {
  left,
  right,

  /// [previous] indicates leaving the sprite as is
  previous
}
