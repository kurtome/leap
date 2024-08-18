import 'package:leap/src/entities/behaviors/physical_behavior.dart';
import 'package:leap/src/entities/mixins/has_health.dart';

class RemoveOnDeathBehavior extends PhysicalBehavior<HasHealth> {
  RemoveOnDeathBehavior({super.priority});

  @override
  void update(double dt) {
    if (parent.isDead) {
      parent.removeFromParent();
    }
  }
}
