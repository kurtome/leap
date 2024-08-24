mixin HasWalkSpeed {
  /// Wether or not this is currently facing left
  bool faceLeft = false;

  /// Wether or not walk speed should be applied
  bool isWalking = false;

  /// Base value for setting [walkSpeed]
  double baseWalkSpeed = 10;

  /// How many units to walk per second.
  double walkSpeed = 10;
}
