import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/basic_ladder.dart';
import 'package:leap_standard_platformer/coin.dart';
import 'package:leap_standard_platformer/door.dart';
import 'package:leap_standard_platformer/hud.dart';
import 'package:leap_standard_platformer/info_text.dart';
import 'package:leap_standard_platformer/player.dart';
import 'package:leap_standard_platformer/snowy_moving_platform.dart';
import 'package:leap_standard_platformer/welcome_dialog.dart';

void main() {
  runApp(
    GameWidget(
      game: ExamplePlatformerLeapGame(
        tileSize: 16,
      ),
    ),
  );
}

class ExamplePlatformerLeapGame extends LeapGame
    with TapCallbacks, HasKeyboardHandlerComponents {
  ExamplePlatformerLeapGame({
    required super.tileSize,
  });

  Player? player;
  late final ThreeButtonInput input;
  late final Map<String, TiledObjectHandler> tiledObjectHandlers;
  late final Map<String, GroundTileHandler> groundTileHandlers;

  static const _levels = [
    'map_menu.tmx',
    'map_everything.tmx',
    'map_ladders.tmx',
  ];

  var _currentLevel = 'map_menu.tmx';

  Future<void> _loadLevel() {
    return loadWorldAndMap(
      tiledMapPath: _currentLevel,
      tiledObjectHandlers: tiledObjectHandlers,
      groundTileHandlers: groundTileHandlers,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    tiledObjectHandlers = {
      'Coin': await CoinFactory.createFactory(),
      'SnowyMovingPlatform': await SnowyMovingPlatformFactory.createFactory(),
      'BasicLadder': await BasicLadderFactory.createFactory(),
      'InfoText': InfoTextFactory(),
      'Door': DoorFactory(),
    };

    groundTileHandlers = {
      'OneWayTopPlatform': OneWayTopPlatformHandler(),
    };

    // Default the camera size to the bounds of the Tiled map.
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: tileSize * 32,
      height: tileSize * 16,
    );

    input = ThreeButtonInput();
    add(input);

    await _loadLevel();

    // Don't let the camera move outside the bounds of the map, inset
    // by half the viewport size to the edge of the camera if flush with the
    // edge of the map.
    final inset = camera.viewport.virtualSize;
    camera.setBounds(
      Rectangle.fromLTWH(
        inset.x / 2,
        inset.y / 2,
        leapMap.width - inset.x,
        leapMap.height - inset.y,
      ),
    );

    player = Player();
    world.add(player!);
    camera.follow(player!);

    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('village_music.mp3');
    }

    camera.viewport.add(Hud());
    camera.viewport.add(
      WelcomeDialog(
        position: Vector2(
          camera.viewport.size.x * 0.5,
          camera.viewport.size.y * 0.9,
        ),
      ),
    );
  }

  @override
  void onMapUnload(LeapMap map) {
    player?.removeFromParent();
  }

  @override
  void onMapLoaded(LeapMap map) {
    if (player != null) {
      player = Player();
      world.add(player!);
      camera.follow(player!);
    }
  }

  Future<void> levelCleared() async {
    final i = _levels.indexOf(_currentLevel);
    _currentLevel = _levels[(i + 1) % _levels.length];

    await _loadLevel();
  }

  Future<void> goToLevel(String mapName) async {
    _currentLevel = mapName;
    await _loadLevel();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // On web, we need to wait for a user interaction before playing any sound.
    if (input.justPressed && !FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('village_music.mp3');
    }
  }
}
