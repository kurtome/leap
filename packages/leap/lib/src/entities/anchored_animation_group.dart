import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/foundation.dart';

/// A [SpriteAnimationGroupComponent] with extra funcationality to
/// automatically handle what common positioning. Should be a direct
/// child of a [PositionedEntity].
///
/// 1. Positions the animation based on the parent's size and position.
///    By default this is bottom aligned and horizontally centered, but
///    can be changed with [spriteAnchor].
///
/// 2. Resets the animation ticker anytime the [current] animation changes
///    to make sure the animation plays from the beginning.
///
/// Subclasses are typically override [update] to set the appropriate [TKey]
/// value to [current]. This will pick the animation keyed in [animations].
/// [animations] should be set in [onLoad] if they require asset loading.
/// It is also possible to use this without a subclass by simply setting
/// the [current] value in the parent's [update].
class AnchoredAnimationGroup<TKey, TChar extends PositionedEntity>
    extends SpriteAnimationGroupComponent<TKey> with ParentIsA<TChar> {
  AnchoredAnimationGroup({
    this.spriteAnchor = Anchor.bottomCenter,
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

  /// Where the sprite should be in relation to the parent.
  /// For example, [Anchor.bottomCenter] means the parent should be
  /// flush with the bottom of the animation and centered horizontally.
  Anchor spriteAnchor;

  @override
  @mustCallSuper
  void update(double dt) {
    if (parent.anchor != Anchor.topLeft) {
      throw Exception(
        'Parent must have topLeft anchor instead of ${parent.anchor}.',
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
    x = (parent.width - width * scale.x) * spriteAnchor.x;
    y = (parent.height - height * scale.y) * spriteAnchor.y;

    super.update(dt);
  }
}
