import 'package:leap/leap.dart';

/// Modifies a ground tile to be phased through from all directions
/// except the top.
class OneWayTopPlatformHandler implements GroundTileHandler {
  @override
  LeapMapGroundTile handleGroundTile(LeapMapGroundTile tile, LeapMap map) {
    tile.isSolidFromLeft = false;
    tile.isSolidFromRight = false;
    tile.isSolidFromBottom = false;
    return tile;
  }
}

/// Modifies a ground tile to be phased through from all directions
/// except the bottom.
class OneWayBottomPlatformHandler implements GroundTileHandler {
  @override
  LeapMapGroundTile handleGroundTile(LeapMapGroundTile tile, LeapMap map) {
    tile.isSolidFromLeft = false;
    tile.isSolidFromRight = false;
    tile.isSolidFromTop = false;
    return tile;
  }
}

/// Modifies a ground tile to be phased through from all directions
/// except the left.
class OneWayLeftPlatformHandler implements GroundTileHandler {
  @override
  LeapMapGroundTile handleGroundTile(LeapMapGroundTile tile, LeapMap map) {
    tile.isSolidFromRight = false;
    tile.isSolidFromBottom = false;
    tile.isSolidFromTop = false;
    return tile;
  }
}

/// Modifies a ground tile to be phased through from all directions
/// except the right.
class OneWayRightPlatformHandler implements GroundTileHandler {
  @override
  LeapMapGroundTile handleGroundTile(LeapMapGroundTile tile, LeapMap map) {
    tile.isSolidFromLeft = false;
    tile.isSolidFromBottom = false;
    tile.isSolidFromTop = false;
    return tile;
  }
}
