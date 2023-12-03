import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';

abstract class CharacterAnimation<T, C extends Character>
    extends SpriteAnimationGroupComponent<T> with HasAncestor<C> {
  CharacterAnimation({
    this.hitboxAnchor = Anchor.bottomCenter,
    super.animations,
    super.autoResize = true, // probably want to auto-resize
    super.removeOnFinish,
    super.playing,
    super.paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  /// Where the sprite should be in relation to the parent hitbox.
  /// For example, [Anchor.bottomCenter] means the parent hitbox should be
  /// flush with the bottom of the animation and centered horizontally.
  Anchor hitboxAnchor;

  /// The parent character this is added to.
  C get character => ancestor;

  T? _prevCurrent;

  @override
  @mustCallSuper
  void update(double dt) {
    if (_prevCurrent != current) {
      // Assume that we want to start the new animation at the beginning,
      // not wherever it last left off.
      animationTicker?.reset();
    }
    _prevCurrent = current;

    // Do this _after_ setting the animation since
    // that may have caused a resize.
    x = (ancestor.width - width * scale.x) * hitboxAnchor.x;
    y = (ancestor.height - height * scale.y) * hitboxAnchor.y;

    super.update(dt);
  }
}
