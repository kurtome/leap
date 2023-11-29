import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';

/// A type of [PhysicalEntity] which is typically used as the base class
/// for players, enemies, etc.
/// Characters have health, and usually a removed on death.
///
// TODO(kurtome): add sprite animation and state helpers.
class Character<T extends LeapGame> extends PhysicalEntity<T> {
  Character({
    this.health = 1,
    this.removeOnDeath = true,
    super.static,
    super.behaviors,
    super.priority,
    super.position,
    super.size,
  }) : super() {
    _wasAlive = isAlive;
  }

  /// The health of this character, when positive this is "alive".
  int health;

  /// Indicates if this should [remove] itself on death.
  bool removeOnDeath;

  /// Whether or not this is "alive" (or not destroyed) in the game
  bool get isAlive => health > 0;

  /// Whether or not this is "dead" (or destroyed) in the game.
  bool get isDead => !isAlive;

  bool _wasAlive = true;

  /// Indicates that this was alive on the previous [update] loop
  bool get wasAlive => _wasAlive;

  /// Called when this entity dies, typically due to health dropping below one.
  ///
  /// This will be invoked after this has been marked for removal
  /// (if [removeOnDeath] is true) but before [onRemove].
  /// Entities can be removed without dying.
  @mustCallSuper
  void onDeath() {}

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    if (isDead && wasAlive) {
      if (removeOnDeath) {
        removeFromParent();
      }
      onDeath();
    }

    _wasAlive = isAlive;
  }
}
