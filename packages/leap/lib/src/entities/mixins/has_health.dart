import 'package:leap/leap.dart';

mixin HasHealth on PhysicalEntity {
  /// The health of this character, when positive this is "alive".
  int health = 1;

  /// Whether or not this is "alive" (or not destroyed) in the game
  bool get isAlive => health > 0;

  /// Whether or not this is "dead" (or destroyed) in the game.
  bool get isDead => !isAlive;

  /// Indicates that this was alive on the previous game tick
  bool wasAlive = true;

  /// Indicates that this is taking damge this tick
  bool takingDamage = false;

  /// Other entities that have caused damage since the last tick
  final List<PhysicalEntity> incomingDamageSources = [];

  void takeDamage(PhysicalEntity other) {
    incomingDamageSources.add(other);
  }

  /// Duration to ignore incoming damage, has no effect when set to 0
  double ignoreDamageDuration = 0;
}
