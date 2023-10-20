import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:leap/leap.dart';
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

  final double tileSize;

  late final LeapMap leapMap;

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
  Iterable<PhysicalEntity> get physicals => (world as LeapWorld).physicals;

  /// Initializes and loads the [world] and [leapMap] components
  /// with a Tiled map.
  ///
  /// The map file should be loaded from "assets/tiles/[tiledMapPath]",
  /// and use tile size [tileSize].
  Future<void> loadWorldAndMap({
    required String tiledMapPath,
    required CameraComponent camera,
    String prefix = 'assets/tiles/',
    AssetBundle? bundle,
    Images? images,
    LeapConfiguration configuration = const LeapConfiguration(),
  }) async {
    camera.world = world;

    // These two classes reference each other, so the order matters here to
    // load properly.
    leapMap = await LeapMap.load(
      tileSize: tileSize,
      tiledMapPath: tiledMapPath,
      prefix: prefix,
      bundle: bundle,
      images: images,
      configuration: configuration,
    );

    await world.add(leapMap);
  }
}
