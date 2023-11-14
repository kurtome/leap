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

  LeapMap get leapMap {
    if (_leapMap == null) {
      throw Exception('LeapMap not loaded yet');
    }
    return _leapMap!;
  }

  LeapMap? _leapMap;

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

  /// Called when a running is being unloaded due to it
  /// being replaced for a new one.
  ///
  /// Default implementation is a noop, override it if you need to
  /// execute logic when the map is unloaded.
  void onMapUnload(LeapMap map) {}

  /// Called when a new map is loaded.
  ///
  /// Default implementation is a noop, override it if you need to
  /// execute logic when the map is loaded.
  void onMapLoaded(LeapMap map) {}

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
    Map<String, TiledObjectHandler> tiledObjectHandlers = const {},
    LeapMapTransition? transitionComponent,
  }) async {
    final currentMap = _leapMap;
    LeapMapTransition? mapTransition;
    if (currentMap != null) {
      onMapUnload(currentMap);

      final transition = mapTransition =
          transitionComponent ?? LeapMapTransition.defaultFactory(this);
      camera.viewport.add(transition);
      await transition.introFinished;
      currentMap.removeFromParent();
    }

    // These two classes reference each other, so the order matters here to
    // load properly.
    _leapMap = await LeapMap.load(
      tileSize: tileSize,
      tiledMapPath: tiledMapPath,
      prefix: prefix,
      bundle: bundle,
      images: images,
      tiledOptions: configuration.tiled,
      tiledObjectHandlers: tiledObjectHandlers,
    );
    onMapLoaded(_leapMap!);

    await world.add(leapMap);

    if (mapTransition != null) {
      mapTransition.outro();
      await mapTransition.outroFinished;
      mapTransition.removeFromParent();
    }
  }
}
