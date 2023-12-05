import 'package:leap/src/characters/jumper_behavior.dart';
import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_game.dart';

class JumperCharacter<TGame extends LeapGame> extends Character<TGame> {
  JumperCharacter({super.removeOnDeath, super.health})
      : super(behaviors: [JumperBehavior()]);

  /// When true the character is facing left, otherwise right.
  bool faceLeft = false;

  /// Indicates the character is actively jumping (not just in the air).
  /// Typically this means the jump button is being held down.
  bool jumping = false;

  /// When true moves at [walkSpeed] in the direction the
  /// character is facing.
  bool walking = false;

  /// The walking speed of the character.
  double walkSpeed = 0;

  /// The minimum impulse applied when jumping.
  double minJumpImpulse = 1;

  /// The maximum hold time when jumping.
  double maxJumpHoldTime = 0.35;

  /// The last ground velocity of the character on the horizontal axis.
  double airXVelocity = 0;

  /// Stop walking.
  void stand() => walking = false;

  /// Start walking.
  void walk() => walking = true;

  bool get faceRight => !faceLeft;

  bool get isOnGround => collisionInfo.down;

  @override
  void update(double dt) {
    super.update(dt);

    if (characterAnimation != null) {
      if (velocity.x < 0) {
        characterAnimation!.scale.x = -characterAnimation!.scale.x.abs();
      } else if (velocity.x > 0) {
        characterAnimation!.scale.x = characterAnimation!.scale.x.abs();
      }
    }
  }
}
