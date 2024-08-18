mixin HasJumps {
  /// Indicates the character is actively jumping (not just in the air).
  /// Typically this means the jump button is being held down.
  bool jumping = false;

  /// Was [jumping] in previous game tick
  bool wasJumping = false;

  /// The minimum impulse applied when jumping.
  double minJumpImpulse = 1;

  /// The maximum hold time when jumping.
  double maxJumpHoldTime = 0.35;

  /// The last ground velocity of the character on the horizontal axis.
  double airXVelocity = 0;
}
