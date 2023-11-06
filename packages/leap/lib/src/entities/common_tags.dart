import 'package:leap/leap.dart';

/// Common [PhysicalEntity.tags]
class CommonTags {
  CommonTags._privateConstructor();

  static String ground = 'ground';
  static String hazard = 'hazard';
  static String platform = 'platform';

  /// Entities with this tag will not collide with ground.
  static String onLadder = 'onLadder';
}