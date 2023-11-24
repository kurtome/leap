import 'package:flame/components.dart';
import 'package:leap/src/characters/jumper_behavior.dart';
import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_game.dart';

class JumperCharacter<TGame extends LeapGame> extends PhysicalEntity<TGame> {
  JumperCharacter({
    super.health = 10,
  }) : super(behaviors: [JumperBehavior()]);

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

  /// The animation position component of the character.
  PositionComponent? spriteAnimation;

  /// Stop walking.
  void stand() => walking = false;

  /// Start walking.
  void walk() => walking = true;

  bool get faceRight => !faceLeft;

  bool get isOnGround => collisionInfo.down;

  @override
  void update(double dt) {
    super.update(dt);

    if (spriteAnimation == null) {
      return;
    }

    if (velocity.x < 0) {
      spriteAnimation!.transform.offset.x = spriteAnimation!.width - width;
      spriteAnimation!.scale.x = -1;
    } else if (velocity.x > 0) {
      spriteAnimation!.transform.offset.x = 0;
      spriteAnimation!.scale.x = 1;
    }
  }
}
