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
class AnchoredAnimationGroup<TKey, TParent extends PositionComponent>
    extends SpriteAnimationGroupComponent<TKey>
    with ParentIsA<TParent>, EntityMixin {
  AnchoredAnimationGroup({
    this.spriteAnchor = Anchor.bottomCenter,
    Vector2? spriteOffset,
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
  }) {
    this.spriteOffset = spriteOffset ?? Vector2.zero();
  }

  /// Where the sprite should be in relation to the parent.
  /// For example, [Anchor.bottomCenter] means the parent should be
  /// flush with the bottom of the animation and centered horizontally.
  Anchor spriteAnchor;

  /// Adds an additional offset after the anchored positioning
  late Vector2 spriteOffset;

  /// Whether or not the current animation is done.
  bool get animationDone => animationTicker?.done() ?? false;

  @override
  @mustCallSuper
  void updateTree(double dt) {
    // The x, y calculations should happen after any children update the
    // anchor and offset.
    super.updateTree(dt);

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

    // apply the offset after the normal calculations
    x += spriteOffset.x;
    y += spriteOffset.y;
  }
}
