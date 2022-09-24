import 'dart:ui';

import 'package:flame/game.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/utils/has_tracked_components.dart';
import 'package:leap/src/utils/lifecycle_state_aware.dart';

/// A Flame game with all the Leap built-ins
class LeapGame extends FlameGame with HasTrackedComponents {
  late LeapMap map;
  late LeapWorld world;

  AppLifecycleState appState = AppLifecycleState.resumed;

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);

    final oldAppState = appState;
    appState = state;
    for (final c in children.query<AppLifecycleAware>()) {
      c.appLifecycleStateChanged(oldAppState, state);
    }
  }

  /// Tile size (width and height) in pixels
  double get tileSize => world.tileSize;

  /// All the physical entities in the world
  Iterable<PhysicalEntity> get physicals => world.physicals;

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
