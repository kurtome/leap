import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:leap/src/entities/mixins/has_death_animation.dart';

class RemoveAfterDeathAnimationBehavior<T> extends Behavior<HasDeathAnimation> {
  RemoveAfterDeathAnimationBehavior({
    required this.deathAnimationKey,
    super.priority,
  });

  T deathAnimationKey;

  @override
  void update(double dt) {
    final inDeathAnimation = parent.animationGroup.current == deathAnimationKey;
    final animationDone =
        parent.animationGroup.animationTicker?.done() ?? false;

    if (inDeathAnimation && animationDone) {
      parent.removeFromParent();
    }
  }
}
