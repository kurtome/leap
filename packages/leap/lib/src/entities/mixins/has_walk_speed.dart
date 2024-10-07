import 'package:leap/leap.dart';

mixin HasWalkSpeed on PhysicalEntity {
  /// Wether or not this is currently facing left
  HorizontalDirection walkDirection = HorizontalDirection.left;

  /// Wether or not walk speed should be applied
  bool isWalking = false;

  /// Base value for setting [walkSpeed]
  double baseWalkSpeed = 10;

  /// How many units to walk per second.
  double walkSpeed = 10;
}
