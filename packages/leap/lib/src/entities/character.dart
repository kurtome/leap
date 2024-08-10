import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';

/// A type of [PhysicalEntity] which is typically used as the base class
/// for players, enemies, etc.
/// Characters have health, and usually a removed on death.
///
class Character<T extends LeapGame> extends PhysicalEntity<T> {
  Character({
    this.health = 1,
    this.removeOnDeath = true,
    this.finishAnimationBeforeRemove = false,
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

  bool _removingFromDeath = false;

  /// Indicates if this finish the current [characterAnimation] before
  /// auto-removing (i.e. [removeOnDeath]).
  bool finishAnimationBeforeRemove = false;

  /// Whether or not this is "alive" (or not destroyed) in the game
  bool get isAlive => health > 0;

  /// Whether or not this is "dead" (or destroyed) in the game.
  bool get isDead => !isAlive;

  bool _wasAlive = true;

  /// Indicates that this was alive on the previous [update] loop
  bool get wasAlive => _wasAlive;

  CharacterAnimation? _characterAnimation;
  CharacterAnimation? get characterAnimation => _characterAnimation;
  set characterAnimation(CharacterAnimation? newAnimation) {
    if (_characterAnimation != null) {
      remove(_characterAnimation!);
    }
    _characterAnimation = newAnimation;
    if (_characterAnimation != null) {
      add(_characterAnimation!);
    }
  }

  /// Removes health without going below 0. [amount] must be positive.
  ///
  /// Can be overriden to have more fine grained control over health mechanics.
  void damage(int amount) {
    assert(amount > 0);
    health = (health - amount).clamp(0, health);
  }

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
        _removingFromDeath = true;
      }
      onDeath();
    }
    if (_removingFromDeath &&
        (!finishAnimationBeforeRemove ||
            (characterAnimation == null ||
                (characterAnimation!.animationTicker?.done() ?? false)))) {
      _removingFromDeath = false;
      removeFromParent();
    }

    _wasAlive = isAlive;
  }
}
