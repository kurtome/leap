import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/coin.dart';
import 'package:leap_standard_platformer/main.dart';

class Player extends JumperCharacter<ExamplePlatformerLeapGame> {
  Player({super.health = initialHealth}) {
    solidTags.add('ground');
  }

  static const initialHealth = 1;

  late final Vector2 _spawn;
  late final SimpleCombinedInput _input;
  late final PlayerSpriteAnimation _playerAnimation;

  int coins = 0;
  double deadTime = 0;
  double timeHoldingJump = 0;
  bool didEnemyBop = false;

  /// Render on top of the map tiles.
  @override
  int get priority => 10;

  @override
  PositionComponent? get spriteAnimation => _playerAnimation;

  @override
  Future<void> onLoad() async {
    _input = gameRef.input;
    _spawn = map.playerSpawn;
    _playerAnimation = PlayerSpriteAnimation();
    // Size controls player hitbox, which should be slightly smaller than
    // visual size of the sprite.
    size = Vector2(10, 20);
    add(_playerAnimation);

    resetPosition();

    walkSpeed = map.tileSize * 7;
    minJumpImpulse = world.gravity * 0.6;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final wasAlive = isAlive;
    final wasJumping = jumping;

    updateHandleInput(dt);
    if (!_playerAnimation.isLoaded) {
      return;
    }

    updateCollisionInteractions(dt);

    if (isDead) {
      deadTime += dt;
      walking = false;
    }

    updateAnimation();

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
  }

  void resetPosition() {
    x = _spawn.x;
    y = _spawn.y;
    velocity.x = 0;
    velocity.y = 0;
    lastGroundXVelocity = 0;
    faceLeft = false;

    FlameAudio.play('spawn.wav');
  }

  void updateHandleInput(double dt) {
    if (isAlive) {
      // Keep jumping if started.
      if (jumping && _input.isPressed && timeHoldingJump < maxJumpHoldTime) {
        jumping = true;
        timeHoldingJump += dt;
      } else {
        jumping = false;
        timeHoldingJump = 0;
      }
    }

    if (_input.justPressed && _input.isPressedLeft) {
      // Tapped left.
      if (walking) {
        if (faceLeft) {
          // Already moving left.
          if (isOnGround) {
            jumping = true;
          }
        } else {
          // Moving right, stop.
          walking = false;
          faceLeft = true;
        }
      } else {
        // Standing still.
        walking = true;
        faceLeft = true;
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
          walking = false;
          faceLeft = false;
        }
      } else {
        // Standing still.
        walking = true;
        faceLeft = false;
      }
    }
  }

  void updateAnimation() {
    if (isDead) {
      _playerAnimation.die();
    } else {
      if (isOnGround) {
        // On the ground.
        if (velocity.x.abs() > 0) {
          _playerAnimation.walk();
        } else {
          _playerAnimation.idle();
        }
      } else {
        // In the air.
        if (velocity.y > (world.maxVelocity / 4)) {
          _playerAnimation.fall();
        } else if (velocity.y < 0) {
          _playerAnimation.jump();
        }
      }
    }
  }

  void updateCollisionInteractions(double dt) {
    if (collisionInfo.downCollision?.tags.contains('hazard') ?? false) {
      health -= collisionInfo.downCollision!.hazardDamage;
    }

    if (isDead) {
      return;
    }

    if (didEnemyBop) {
      didEnemyBop = false;
      velocity.y = -minJumpImpulse;
    }

    for (final other in collisionInfo.otherCollisions ?? const []) {
      if (other is Coin) {
        other.removeFromParent();
        coins++;
      }
    }
  }
}

class PlayerSpriteAnimation extends PositionComponent
    with HasGameRef<LeapGame> {
  late final SpriteAnimationTicker _ticker;
  late final SpriteAnimationComponent _animationComponent;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _walkAnimation;
  late final SpriteAnimation _jumpAnimation;
  late final SpriteAnimation _fallAnimation;
  late final SpriteAnimation _deathAnimation;

  @override
  Future<void>? onLoad() async {
    final spritesheet = await gameRef.images.load('player_spritesheet.png');

    _idleAnimation = SpriteAnimation.fromFrameData(
      spritesheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.4,
        textureSize: Vector2.all(16),
        amountPerRow: 2,
      ),
    );

    _walkAnimation = SpriteAnimation.fromFrameData(
      spritesheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(16),
        texturePosition: Vector2(0, 16),
        amountPerRow: 2,
      ),
    );

    _jumpAnimation = SpriteAnimation.fromFrameData(
      spritesheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(16),
        texturePosition: Vector2(16 * 4, 0),
        amountPerRow: 1,
        loop: false,
      ),
    );

    _fallAnimation = SpriteAnimation.fromFrameData(
      spritesheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(16),
        texturePosition: Vector2(16 * 2, 0),
        amountPerRow: 2,
      ),
    );

    _deathAnimation = SpriteAnimation.fromFrameData(
      spritesheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.15,
        textureSize: Vector2.all(16),
        texturePosition: Vector2(0, 16 * 2),
        amountPerRow: 6,
        loop: false,
      ),
    );

    _animationComponent = SpriteAnimationComponent(
      size: Vector2.all(32),
      // Reposition the animation relative to the parent's hitbox.
      // This should be visually x-axis centered over the parent, and y-axis
      // bottom aligned so the player's feet touch the ground.
      position: Vector2(-12, -12),
      animation: _idleAnimation,
    );

    _ticker = _animationComponent.animation!.createTicker();
    add(_animationComponent);

    return super.onLoad();
  }

  void idle() {
    if (_animationComponent.animation != _idleAnimation) {
      _animationComponent.animation = _idleAnimation;
      _ticker.reset();
    }
  }

  void walk() {
    if (_animationComponent.animation != _walkAnimation) {
      _animationComponent.animation = _walkAnimation;
      _ticker.reset();
    }
  }

  void jump() {
    if (_animationComponent.animation != _jumpAnimation) {
      _animationComponent.animation = _jumpAnimation;
      _ticker.reset();
    }
  }

  void fall() {
    if (_animationComponent.animation != _fallAnimation) {
      _animationComponent.animation = _fallAnimation;
      _ticker.reset();
    }
  }

  void die() {
    if (_animationComponent.animation != _deathAnimation) {
      _animationComponent.animation = _deathAnimation;
      _ticker.reset();
    }
  }
}
