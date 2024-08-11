import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';

/// A [SpriteAnimationGroupComponent] with extra funcationality to
/// automatically handle what most character components want. This
/// should be a direct child of a [Character].
///
/// 1. Positions the animation based on the parent character's hitbox.
///    By default this is bottom aligned and horizontally centered, but
///    can be changed with [hitboxAnchor].
///
/// 2. Resets the animation ticker anytime the [current] animation changes
///    to make sure the animation plays from the beginning.
///
/// Subclasses are typically override [update] to set the appropriate [TKey]
/// value to [current]. This will pick the animation keyed in [animations].
/// [animations] should be set in [onLoad] if they require asset loading.
/// It is also possible to use this without a subclass by simply setting
/// the [current] value in the character's [update].
class CharacterAnimation<TKey, TChar extends Character>
    extends SpriteAnimationGroupComponent<TKey> with HasAncestor<TChar> {
  CharacterAnimation({
    this.hitboxAnchor = Anchor.bottomCenter,
    super.animations,
    super.autoResize = true, // probably want to auto-resize
    super.autoResetTicker = true,
    super.removeOnFinish,
    super.playing,
    super.paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.children,
    super.priority,
    super.key,
  });

  /// Where the sprite should be in relation to the parent hitbox.
  /// For example, [Anchor.bottomCenter] means the parent hitbox should be
  /// flush with the bottom of the animation and centered horizontally.
  Anchor hitboxAnchor;

  /// The parent character this is added to.
  TChar get character => ancestor;

  @override
  @mustCallSuper
  void update(double dt) {
    if (character.anchor != Anchor.topLeft) {
      throw Exception(
        'Character must have topLeft anchor instead of ${character.anchor}.',
      );
    }
    // NOTE: anchor and hitboxAnchor are slightly different, we want people to
    //       use hitboxAnchor.
    if (anchor != Anchor.topLeft) {
      throw Exception(
        'This must have topLeft anchor instead of $anchor.',
      );
    }

    // Do this _after_ setting the animation since
    // that may have caused a resize.
    x = (character.width - width * scale.x) * hitboxAnchor.x;
    y = (character.height - height * scale.y) * hitboxAnchor.y;

    super.update(dt);
  }
}
