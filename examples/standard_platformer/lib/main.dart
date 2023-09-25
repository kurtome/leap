import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/coin.dart';
import 'package:leap_standard_platformer/hud.dart';
import 'package:leap_standard_platformer/player.dart';
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
  ExamplePlatformerLeapGame({required super.tileSize});

  late final Player player;
  late final SimpleCombinedInput input;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadWorldAndMap(
      tiledMapPath: 'map.tmx',
      tileCameraWidth: 32,
      tileCameraHeight: 16,
    );

    input = SimpleCombinedInput();
    add(input);

    player = Player();
    camera.world!.add(player);
    camera.follow(player);

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

    await Coin.loadAllInMap(leapMap);
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
