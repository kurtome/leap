import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_map.dart';
import 'package:leap/src/leap_world.dart';
import 'package:leap/src/mixins/mixins.dart';

/// A [FlameGame] with all the Leap built-ins.
class LeapGame extends FlameGame with HasTrackedComponents {
  LeapGame({
    required this.tileSize,
    this.appState = AppLifecycleState.resumed,
  }) : super(world: LeapWorld(tileSize: tileSize));

  late final LeapMap leapMap;

  late final LeapWorld leapWorld;

  final double tileSize;

  AppLifecycleState appState;

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    final oldAppState = appState;
    appState = state;
    for (final child in children.query<AppLifecycleAware>()) {
      child.appLifecycleStateChanged(oldAppState, state);
    }
  }

  /// All the physical entities in the world.
  Iterable<PhysicalEntity> get physicals => leapWorld.physicals;

  /// Initializes and loads the [leapWorld] and [leapMap] components
  /// with a Tiled map.
  ///
  /// The map file should be loaded from "assets/tiled/[tiledMapPath]",
  /// and use tile size [tileSize].
  Future<void> loadWorldAndMap({
    required String tiledMapPath,
    required int tileCameraWidth,
    required int tileCameraHeight,
  }) async {
    await add(world);

    // Default the camera size to the bounds of the Tiled map.
    camera = CameraComponent.withFixedResolution(
      width: tileSize * tileCameraWidth,
      height: tileSize * tileCameraHeight,
      world: world,
    );
    await add(camera);

    // These two classes reference each other, so the order matters here to
    // load properly.
    leapMap = await LeapMap.load(tiledMapPath, tileSize);

    await world.addAll([leapMap, leapWorld]);
  }
}
