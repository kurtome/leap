import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/coin.dart';
import 'package:leap_standard_platformer/hud.dart';
import 'package:leap_standard_platformer/player.dart';
import 'package:leap_standard_platformer/welcome_dialog.dart';

void main() {
  runApp(GameWidget(game: ExamplePlatformerLeapGame()));
}

class ExamplePlatformerLeapGame extends LeapGame
    with HasTappables, HasKeyboardHandlerComponents {
  late final Player player;
  late final SimpleCombinedInput input;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await loadWorldAndMap('map.tmx', 16);
    setFixedViewportInTiles(32, 16);

    input = SimpleCombinedInput();
    add(input);
    player = Player();
    add(player);
    camera.followComponent(player);
    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('village_music.mp3');
    }

    add(Hud());
    add(WelcomeDialog(camera));
    await Coin.loadAllInMap(map);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // on web we need to wait for a user interaction before playing any sound
    if (input.justPressed && !FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('village_music.mp3');
    }
  }
}
