import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/coin.dart';
import 'package:leap_standard_platformer/door.dart';
import 'package:leap_standard_platformer/info_text.dart';
import 'package:leap_standard_platformer/main.dart';

class Player extends JumperCharacter
    with HasGameRef<ExamplePlatformerLeapGame>, HasHealth, HasAnimationGroup {
  Player() {
    // Behaviors, ordering is important for processing
    // collision detection and reacting to inputs
    //
    // Acceleration from movement should go before global collision detection
    add(JumperAccelerationBehavior());
    add(GravityAccelerationBehavior());
    // Global collision detection
    add(CollisionDetectionBehavior());
    // Other state based behaviors
    add(PlayerDamageBehavior());
    add(PlayerInputBehavior());
    add(PlayerCollisionBehavior());
    add(OnLadderMovementBehavior());
    add(PlayerDeathBehavior());
    // Apply velocity to position (respecting collisions)
    add(ApplyVelocityBehavior());
    // Cosemetic behaviors
    add(AnimationVelocityFlipBehavior());

    // Children
    add(animationGroup);

    health = 1;
    solidTags.add(CommonTags.ground);
  }

  int initialHealth = 1;

  late final Vector2 _spawn;
  late final ThreeButtonInput _input;

  int coins = 0;
  double deadTime = 0;
  double timeHoldingJump = 0;
  bool didEnemyBop = false;

  @override
  AnchoredAnimationGroup animationGroup = PlayerSpriteAnimation();

  /// Render on top of the map tiles.
  @override
  int get priority => 1;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _input = game.input;
    _spawn = leapMap.playerSpawn;

    // Size controls player hitbox, which should be slightly smaller than
    // visual size of the sprite.
    size = Vector2(10, 24);

    resetPosition();

    walkSpeed = leapMap.tileSize * 7;
    minJumpImpulse = leapWorld.gravity * 0.6;
  }

  void resetPosition() {
    x = _spawn.x;
    y = _spawn.y;
    velocity.x = 0;
    velocity.y = 0;
    airXVelocity = 0;
    walkDirection = HorizontalDirection.left;
    jumping = false;

    FlameAudio.play('spawn.wav');
  }

  void updateHandleInput(double dt) {}

  void updateCollisionInteractions(double dt) {}

  void _checkForLevelCompletion() {
    final coinsLeft = gameRef.leapMap.children.whereType<Coin>().length;
    if (coinsLeft <= 1) {
      gameRef.levelCleared();
    }
  }
}

class PlayerInputBehavior extends PhysicalBehavior<Player> {
  @override
  void update(double dt) {
    if (parent.isDead) {
      // ignore inputs
      parent.jumping = false;
      parent.isWalking = false;
      return;
    }

    parent.wasJumping = parent.jumping;
    if (parent.isAlive) {
      if (parent.jumping &&
          parent._input.isPressed &&
          parent.timeHoldingJump < parent.maxJumpHoldTime &&
          // hitting a ceiling should behave the same
          // as letting go of the jump button
          !collisionInfo.up) {
        parent.jumping = true;
        parent.timeHoldingJump += dt;
      } else {
        parent.jumping = false;
        parent.timeHoldingJump = 0;
      }
    }

    final ladderCollision =
        collisionInfo.allCollisions.whereType<Ladder>().firstOrNull;
    final onLadderStatus = parent.getStatus<OnLadderStatus>();
    if (parent._input.justPressed &&
        parent._input.isPressedCenter &&
        ladderCollision != null &&
        onLadderStatus == null) {
      // Grab onto ladder
      final status = OnLadderStatus(ladderCollision);
      parent.add(status);
      parent.isWalking = false;
      parent.airXVelocity = 0;
      if (parent.collisionInfo.down) {
        status.movement = LadderMovement.down;
      } else {
        status.movement = LadderMovement.up;
      }
    } else if (onLadderStatus != null) {
      updateOnLadder(dt, onLadderStatus);
    } else {
      updateNormal(dt);
    }

    if (!parent.wasJumping && parent.jumping) {
      FlameAudio.play('jump.wav');
    }
  }

  /// On ladder
  void updateOnLadder(double dt, OnLadderStatus onLadderStatus) {
    if (parent._input.justPressed) {
      if (parent._input.isPressedCenter) {
        if (onLadderStatus.movement != LadderMovement.stopped) {
          onLadderStatus.movement = LadderMovement.stopped;
        } else if (onLadderStatus.prevDirection == LadderMovement.up) {
          onLadderStatus.movement = LadderMovement.down;
        } else {
          onLadderStatus.movement = LadderMovement.up;
        }
      } else {
        // JumperBehavior will handle applying the jump and exiting the ladder
        parent.jumping = true;
        parent.airXVelocity = parent.walkSpeed;
        parent.isWalking = true;
        // Make sure the player exits the ladder facing the direction jumped
        if (parent._input.isPressedLeft) {
          parent.walkDirection = HorizontalDirection.left;
        } else {
          parent.walkDirection = HorizontalDirection.right;
        }
      }
    }
  }

  /// Not on ladder, this is the normal case
  void updateNormal(double dt) {
    if (parent._input.justPressed && parent._input.isPressedLeft) {
      // Tapped left.
      if (parent.isWalking) {
        if (parent.walkDirection == HorizontalDirection.left) {
          // Already moving left.
          if (parent.collisionInfo.down) {
            parent.jumping = true;
          }
        } else {
          // Moving right, stop.
          if (parent.collisionInfo.down) {
            parent.isWalking = false;
          }
          parent.walkDirection = HorizontalDirection.left;
        }
      } else {
        // Standing still.
        parent.isWalking = true;
        parent.walkDirection = HorizontalDirection.left;
        if (parent.collisionInfo.down) {
          parent.airXVelocity = parent.walkSpeed;
        }
      }
    } else if (parent._input.justPressed && parent._input.isPressedRight) {
      // Tapped right.
      if (parent.isWalking) {
        if (parent.walkDirection == HorizontalDirection.right) {
          // Already moving right.
          if (parent.collisionInfo.down) {
            parent.jumping = true;
          }
        } else {
          // Moving left, stop.
          if (parent.collisionInfo.down) {
            parent.isWalking = false;
          }
          parent.walkDirection = HorizontalDirection.right;
        }
      } else {
        // Standing still.
        parent.isWalking = true;
        parent.walkDirection = HorizontalDirection.right;
        if (parent.collisionInfo.down) {
          parent.airXVelocity = parent.walkSpeed;
        }
      }
    }
  }
}

class PlayerDamageBehavior extends PhysicalBehavior<Player> {
  @override
  void update(double dt) {
    parent.wasAlive = parent.isAlive;

    if (collisionInfo.downCollision?.tags.contains('Hazard') ?? false) {
      parent.health -= collisionInfo.downCollision!.hazardDamage;
    }
  }
}

class PlayerCollisionBehavior extends PhysicalBehavior<Player> {
  @override
  void update(double dt) {
    if (parent.isDead) {
      return;
    }

    if (parent.didEnemyBop) {
      parent.didEnemyBop = false;
      velocity.y = -parent.minJumpImpulse;
    }

    for (final other in collisionInfo.allCollisions) {
      if (other is Coin) {
        other.collect();
        parent.coins++;
        parent._checkForLevelCompletion();
      }

      if (other is InfoText) {
        other.activateText();
      }

      if (other is Door &&
          parent._input.justPressed &&
          parent._input.isPressedCenter) {
        other.enter(parent);
      }
    }
  }
}

class PlayerDeathBehavior extends PhysicalBehavior<Player> {
  @override
  void update(double dt) {
    if (parent.isDead) {
      parent.deadTime += dt;
      // Set zero on velocity again in case player died this tick
      parent.velocity.setZero();
    }

    if (leapWorld.isOutside(parent) || (parent.isDead && parent.deadTime > 3)) {
      parent.health = parent.initialHealth;
      parent.deadTime = 0;
      parent.resetPosition();
    }

    if (parent.wasAlive && !parent.isAlive) {
      FlameAudio.play('die.wav');
    }
  }
}

enum _AnimationState { idle, walk, jump, fall, death, ladder }

class PlayerSpriteAnimation
    extends AnchoredAnimationGroup<_AnimationState, Player>
    with HasGameRef<LeapGame> {
  PlayerSpriteAnimation() : super(scale: Vector2.all(2));

  @override
  Future<void>? onLoad() async {
    final spritesheet = await gameRef.images.load('player_spritesheet.png');

    animations = {
      _AnimationState.idle: SpriteAnimation.fromFrameData(
        spritesheet,
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.4,
          textureSize: Vector2.all(16),
          amountPerRow: 2,
        ),
      ),
      _AnimationState.walk: SpriteAnimation.fromFrameData(
        spritesheet,
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.2,
          textureSize: Vector2.all(16),
          texturePosition: Vector2(0, 16),
          amountPerRow: 2,
        ),
      ),
      _AnimationState.jump: SpriteAnimation.fromFrameData(
        spritesheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2.all(16),
          texturePosition: Vector2(16 * 4, 0),
          amountPerRow: 1,
          loop: false,
        ),
      ),
      _AnimationState.fall: SpriteAnimation.fromFrameData(
        spritesheet,
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.2,
          textureSize: Vector2.all(16),
          texturePosition: Vector2(16 * 2, 0),
          amountPerRow: 2,
        ),
      ),
      _AnimationState.death: SpriteAnimation.fromFrameData(
        spritesheet,
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.15,
          textureSize: Vector2.all(16),
          texturePosition: Vector2(0, 16 * 2),
          amountPerRow: 6,
          loop: false,
        ),
      ),
      _AnimationState.ladder: SpriteAnimation.fromFrameData(
        spritesheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2.all(16),
          texturePosition: Vector2(0, 16 * 6),
          amountPerRow: 4,
        ),
      ),
    };

    current = _AnimationState.idle;

    return super.onLoad();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    // Default to playing animations
    playing = true;

    if (parent.isDead) {
      current = _AnimationState.death;
    } else if (parent.hasStatus<OnLadderStatus>()) {
      if (parent.getStatus<OnLadderStatus>()!.movement ==
          LadderMovement.stopped) {
        playing = false;
      } else {
        playing = true;
      }
      current = _AnimationState.ladder;
    } else {
      if (parent.collisionInfo.down) {
        // On the ground.
        if (parent.velocity.x.abs() > 0) {
          current = _AnimationState.walk;
        } else {
          current = _AnimationState.idle;
        }
      } else {
        // In the air.
        if (parent.velocity.y > (parent.leapWorld.maxGravityVelocity / 4)) {
          current = _AnimationState.fall;
        } else if (parent.velocity.y < 0) {
          current = _AnimationState.jump;
        }
      }
    }
    super.update(dt);
  }
}
