import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:leap/leap.dart';

/// Interface for custom handling of a [TiledObject], used by [LeapMap].
abstract interface class TiledObjectHandler {
  /// Callback to handle a specific [object] which was found in a [layer] while
  /// parsing the Tiled contents to build the [map].
  ///
  /// Implementers have full flexibility, but generally want to create a
  /// [Component] to add to the [LeapMap] and use the [TiledObject.x],
  /// [TiledObject.y], [TiledObject.properties], etc. to customize the
  /// component.
  void handleObject(TiledObject object, Layer layer, LeapMap map);
}
