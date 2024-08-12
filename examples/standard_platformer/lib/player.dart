import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/coin.dart';
import 'package:leap_standard_platformer/door.dart';
import 'package:leap_standard_platformer/info_text.dart';
import 'package:leap_standard_platformer/main.dart';

class Player extends JumperCharacter<ExamplePlatformerLeapGame> {
  Player({super.health = initialHealth}) : super(removeOnDeath: false) {
    solidTags.add(CommonTags.ground);
  }

  static const initialHealth = 1;

  late final Vector2 _spawn;
  late final ThreeButtonInput _input;

  int coins = 0;
  double deadTime = 0;
  double timeHoldingJump = 0;
  bool didEnemyBop = false;

  /// Render on top of the map tiles.
  @override
  int get priority => 10;

  @override
  Future<void> onLoad() async {
    _input = game.input;
    _spawn = map.playerSpawn;

    characterAnimation = PlayerSpriteAnimation();

    // Size controls player hitbox, which should be slightly smaller than
    // visual size of the sprite.
    size = Vector2(10, 24);

    resetPosition();

    walkSpeed = map.tileSize * 7;
    minJumpImpulse = world.gravity * 0.6;
  }

  @override
  void updateAfter(double dt) {
    updateHandleInput(dt);

    updateCollisionInteractions(dt);

    if (isDead) {
      deadTime += dt;
      walking = false;
    }

    if (world.isOutside(this) || (isDead && deadTime > 3)) {
      health = initialHealth;
      deadTime = 0;
      resetPosition();
    }

    if (wasAlive && !isAlive) {
      FlameAudio.play('die.wav');
    }
    if (!wasJumping && jumping) {
      FlameAudio.play('jump.wav');
    }

    super.updateAfter(dt);
  }

  void resetPosition() {
    x = _spawn.x;
    y = _spawn.y;
    velocity.x = 0;
    velocity.y = 0;
    airXVelocity = 0;
    faceLeft = false;
    jumping = false;

    FlameAudio.play('spawn.wav');
  }

  void updateHandleInput(double dt) {
    if (isAlive) {
      // Keep jumping if started.
      if (jumping &&
          _input.isPressed &&
          timeHoldingJump < maxJumpHoldTime &&
          // hitting a ceiling should behave the same
          // as letting go of the jump button
          !collisionInfo.up) {
        jumping = true;
        timeHoldingJump += dt;
      } else {
        jumping = false;
        timeHoldingJump = 0;
      }
    }

    final ladderCollision =
        collisionInfo.allCollisions.whereType<Ladder>().firstOrNull;
    final onLadderStatus = getStatus<OnLadderStatus>();
    if (_input.justPressed &&
        _input.isPressedCenter &&
        ladderCollision != null &&
        onLadderStatus == null) {
      final status = OnLadderStatus(ladderCollision);
      add(status);
      walking = false;
      airXVelocity = 0;
      if (isOnGround) {
        status.movement = LadderMovement.down;
      } else {
        status.movement = LadderMovement.up;
      }
    } else if (_input.justPressed && onLadderStatus != null) {
      if (_input.isPressedCenter) {
        if (onLadderStatus.movement != LadderMovement.stopped) {
          onLadderStatus.movement = LadderMovement.stopped;
        } else if (onLadderStatus.prevDirection == LadderMovement.up) {
          onLadderStatus.movement = LadderMovement.down;
        } else {
          onLadderStatus.movement = LadderMovement.up;
        }
      } else {
        // JumperBehavior will handle applying the jump and exiting the ladder
        jumping = true;
        airXVelocity = walkSpeed;
        walking = true;
        // Make sure the player exits the ladder facing the direction jumped
        faceLeft = _input.isPressedLeft;
      }
    } else if (_input.justPressed && _input.isPressedLeft) {
      // Tapped left.
      if (walking) {
        if (faceLeft) {
          // Already moving left.
          if (isOnGround) {
            jumping = true;
          }
        } else {
          // Moving right, stop.
          if (isOnGround) {
            walking = false;
          }
          faceLeft = true;
        }
      } else {
        // Standing still.
        walking = true;
        faceLeft = true;
        if (isOnGround) {
          airXVelocity = walkSpeed;
        }
      }
    } else if (_input.justPressed && _input.isPressedRight) {
      // Tapped right.
      if (walking) {
        if (!faceLeft) {
          // Already moving right.
          if (isOnGround) {
            jumping = true;
          }
        } else {
          // Moving left, stop.
          if (isOnGround) {
            walking = false;
          }
          faceLeft = false;
        }
      } else {
        // Standing still.
        walking = true;
        faceLeft = false;
        if (isOnGround) {
          airXVelocity = walkSpeed;
        }
      }
    }
  }

  void updateCollisionInteractions(double dt) {
    if (collisionInfo.downCollision?.tags.contains('Hazard') ?? false) {
      health -= collisionInfo.downCollision!.hazardDamage;
    }

    if (isDead) {
      return;
    }

    if (didEnemyBop) {
      didEnemyBop = false;
      velocity.y = -minJumpImpulse;
    }

    for (final other in collisionInfo.allCollisions) {
      if (other is Coin) {
        other.collect();
        coins++;
        _checkForLevelCompletion();
      }

      if (other is InfoText) {
        other.activateText();
      }

      if (other is Door && _input.justPressed && _input.isPressedCenter) {
        other.enter(this);
      }
    }
  }

  void _checkForLevelCompletion() {
    final coinsLeft = gameRef.leapMap.children.whereType<Coin>().length;
    if (coinsLeft <= 1) {
      gameRef.levelCleared();
    }
  }
}

enum _AnimationState { idle, walk, jump, fall, death, ladder }

class PlayerSpriteAnimation extends CharacterAnimation<_AnimationState, Player>
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

    if (character.isDead) {
      current = _AnimationState.death;
    } else if (character.hasStatus<OnLadderStatus>()) {
      if (character.getStatus<OnLadderStatus>()!.movement ==
          LadderMovement.stopped) {
        playing = false;
      } else {
        playing = true;
      }
      current = _AnimationState.ladder;
    } else {
      if (character.isOnGround) {
        // On the ground.
        if (character.velocity.x.abs() > 0) {
          current = _AnimationState.walk;
        } else {
          current = _AnimationState.idle;
        }
      } else {
        // In the air.
        if (character.velocity.y > (game.world.maxGravityVelocity / 4)) {
          current = _AnimationState.fall;
        } else if (character.velocity.y < 0) {
          current = _AnimationState.jump;
        }
      }
    }
    super.update(dt);
  }
}
