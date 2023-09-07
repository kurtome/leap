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
      game: ExamplePlatformerLeapGame(),
    ),
  );
}

class ExamplePlatformerLeapGame extends LeapGame
    with TapCallbacks, HasKeyboardHandlerComponents {
  late final Player player;
  late final SimpleCombinedInput input;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadWorldAndMap(
      tileSize: 16,
      tiledMapPath: 'map.tmx',
    );

    input = SimpleCombinedInput();
    add(input);

    player = Player();
    add(player);

    cameraComponent.follow(player);

    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('village_music.mp3');
    }

    cameraComponent.viewport.add(Hud());
    cameraComponent.viewport.add(
      WelcomeDialog(
        position: Vector2(
          cameraComponent.viewport.size.x * 0.5,
          cameraComponent.viewport.size.y * 0.9,
        ),
      ),
    );

    await Coin.loadAllInMap(map);
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
