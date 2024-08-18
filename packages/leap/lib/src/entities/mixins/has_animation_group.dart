import 'package:leap/src/entities/anchored_animation_group.dart';
import 'package:leap/src/entities/physical_entity.dart';

mixin HasAnimationGroup on PhysicalEntity {
  AnchoredAnimationGroup get animationGroup;

  bool get animationFacesLeft => false;
}
