import 'package:leap/leap.dart';

/// Interface for custom handling of a [LeapMapGroundTile], used by [LeapMap].
abstract interface class GroundTileHandler {
  /// Callback to handle a specific [LeapMapGroundTile] which was found in the
  /// ground layer while parsing the Tiled contents to build the [LeapMap].
  ///
  /// Returning the [tile] itself will mean it is used in the map as it would
  /// have been if there was no handler.
  ///
  /// Implementers have full flexibility,
  /// but generally want do one of the following:
  /// 1. Modify properties of [tile], add tags
  /// 2. Return a custom implementation of [LeapMapGroundTile]
  /// 3. Create an additional PhysicalEntity with custom behavior at the same
  ///    location as the tile.
  LeapMapGroundTile handleGroundTile(LeapMapGroundTile tile, LeapMap map);
}
