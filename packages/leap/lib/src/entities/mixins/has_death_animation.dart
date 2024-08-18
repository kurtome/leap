import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:leap/leap.dart';

mixin HasDeathAnimation on PositionedEntity {
  bool get isDead;
  AnchoredAnimationGroup get animationGroup;
}
