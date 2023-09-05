import 'package:flame/components.dart';
import 'package:leap/src/characters/jumper_behavior.dart';
import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_game.dart';

class JumperCharacter<TGame extends LeapGame> extends PhysicalEntity<TGame> {
  JumperCharacter({
    super.health = 10,
  }) : super(behaviors: [JumperBehavior()]);

  bool faceLeft = false;
  bool jumping = false;
  bool walking = false;

  /// The walking speed of the character.
  double walkSpeed = 0;

  /// The minimum impulse applied when jumping.
  double minJumpImpulse = 1;

  /// The maximum hold time when jumping.
  double maxJumpHoldTime = 0.35;

  /// The last ground velocity of the character on the horizontal axis.
  double lastGroundXVelocity = 0;

  /// The animation position component of the character.
  PositionComponent? spriteAnimation;

  void stand() => walking = false;

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
      spriteAnimation!.transform.offset = Vector2(
        spriteAnimation!.width - width,
        0,
      );
      spriteAnimation!.scale.x = -1;
    } else if (velocity.x > 0) {
      spriteAnimation!.transform.offset = Vector2(0, 0);
      spriteAnimation!.scale.x = 1;
    }
  }
}
