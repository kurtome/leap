import 'dart:ui';

import 'package:flame/game.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/utils/has_tracked_components.dart';

class LeapGame extends FlameGame with HasTrackedComponents {
  late LeapMap map;
  late LeapWorld world;

  AppLifecycleState appState = AppLifecycleState.resumed;

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    appState = state;
    world.input.appStateChanged();
  }

  double get tileSize => world.tileSize;

  /// Initializes and loads the [world] and [map] components with a Tiled map,
  /// the map file is loaded from "assets/tiled/[tiledMapPath]", and should
  /// use tile size [tileSize]
  Future<void> loadWorldAndMap(String tiledMapPath, double tileSize) async {
    // These two classes reference each other, so the order matters here to
    // load properly
    world = LeapWorld(tileSize: tileSize);
    map = await LeapMap.load('map.tmx', tileSize);
    await add(map);
    await add(world);

    // default the camera bounds to the bounds of the Tiled map
    camera.worldBounds = Rect.fromLTRB(
      0,
      0,
      map.width,
      map.height,
    );
  }

  /// Sets the [camera]'s viewport to exact tile width and height
  void setFixedViewportInTiles(int width, int height) {
    camera.viewport = FixedResolutionViewport(
      Vector2(tileSize * width, tileSize * height),
    );
  }
}
