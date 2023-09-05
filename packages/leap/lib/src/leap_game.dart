import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_map.dart';
import 'package:leap/src/leap_world.dart';

import 'package:leap/src/mixins/mixins.dart';

/// A [FlameGame] with all the Leap built-ins.
class LeapGame extends FlameGame with HasTrackedComponents {
  LeapGame() : appState = AppLifecycleState.resumed;

  late final LeapMap map;
  late final LeapWorld world;
  late final CameraComponent cameraComponent;
  AppLifecycleState appState;

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    final oldAppState = appState;
    appState = state;
    for (final c in children.query<AppLifecycleAware>()) {
      c.appLifecycleStateChanged(oldAppState, state);
    }
  }

  /// Tile size (width and height) in pixels.
  double get tileSize => world.tileSize;

  /// All the physical entities in the world.
  Iterable<PhysicalEntity> get physicals => world.physicals;

  /// Initializes and loads the [world] and [map] components with a Tiled map,
  /// the map file is loaded from "assets/tiled/[tiledMapPath]", and should
  /// use tile size [tileSize].
  Future<void> loadWorldAndMap({
    required String tiledMapPath,
    required double tileSize,
  }) async {
    // These two classes reference each other, so the order matters here to
    // load properly.
    world = LeapWorld(tileSize: tileSize);
    map = await LeapMap.load('map.tmx', tileSize);

    // Default the camera size to the bounds of the Tiled map.
    cameraComponent = CameraComponent.withFixedResolution(
      width: tileSize * map.width,
      height: tileSize * map.height,
    );

    await addAll([map, world, cameraComponent]);
  }
}
