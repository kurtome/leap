import 'package:flame/components.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/characters/jumper_behavior.dart';

class JumperCharacter<TGame extends LeapGame> extends PhysicalEntity<TGame> {
  bool faceLeft = false;
  bool jumping = false;
  bool walking = false;
  late double walkSpeed = 0;

  /// This controls the min jump height
  double minJumpImpulse = 1;

  /// The number of seconds to
  double maxJumpHoldTime = 0.35;

  double lastGroundXVelocity = 0;

  PositionComponent? spriteAnimation;

  JumperCharacter({super.health = 10}) : super(behaviors: [JumperBehavior()]);

  @override
  void update(double dt) {
    super.update(dt);

    if (spriteAnimation != null) {
      if (velocity.x < 0) {
        spriteAnimation!.transform.offset =
            Vector2(spriteAnimation!.width - width, 0);
        spriteAnimation!.scale.x = -1;
      } else if (velocity.x > 0) {
        spriteAnimation!.transform.offset = Vector2(0, 0);
        spriteAnimation!.scale.x = 1;
      }
    }
  }

  void stand() => walking = false;

  void walk() => walking = true;

  bool get faceRight => !faceLeft;

  bool get isOnGround => collisionInfo.down;
}
