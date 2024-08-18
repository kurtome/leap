import 'dart:math';

import 'package:leap/leap.dart';

/// Health behavior that takes 1 damage per incomingDamageSources
class SimpleDamageBevhavior extends PhysicalBehavior<HasHealth> {
  SimpleDamageBevhavior({super.priority});

  @override
  void update(double dt) {
    parent.ignoreDamageDuration = max(0, parent.ignoreDamageDuration - dt);

    parent.wasAlive = parent.isAlive;

    var damage = parent.incomingDamageSources.length;
    parent.takingDamage = damage > 0;
    if (parent.ignoreDamageDuration > 0) {
      damage = 0;
    }

    parent.incomingDamageSources.clear();
    parent.health = max(0, parent.health - damage);
  }
}
