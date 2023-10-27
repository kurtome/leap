import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/mixins/mixins.dart';

/// A [FlameGame] with all the Leap built-ins.
class LeapGame extends FlameGame with HasTrackedComponents {
  LeapGame({
    required this.tileSize,
    this.appState = AppLifecycleState.resumed,
    this.configuration = const LeapConfiguration(),
  }) : super(world: LeapWorld(tileSize: tileSize));

  final double tileSize;

  late final LeapMap leapMap;

  AppLifecycleState appState;

  final LeapConfiguration configuration;

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
    String prefix = 'assets/tiles/',
    AssetBundle? bundle,
    Images? images,
    LeapConfiguration configuration = const LeapConfiguration(),
    Map<String, TiledObjectHandler> tiledObjectHandlers = const {},
  }) async {
    // These two classes reference each other, so the order matters here to
    // load properly.
    leapMap = await LeapMap.load(
      tileSize: tileSize,
      tiledMapPath: tiledMapPath,
      prefix: prefix,
      bundle: bundle,
      images: images,
      tiledOptions: configuration.tiled,
      tiledObjectHandlers: tiledObjectHandlers,
    );

    await world.add(leapMap);
  }
}
