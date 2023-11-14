import 'package:leap/leap.dart';

/// A base for building status effects pertaining to [PhysicalEntity]. Effects
/// which could are reusable are typically implemented as mixins
/// (see [IgnoresGravity]), whereas fully custom statuses may simply extend this
/// and have no mixins.
///
/// It is the responsibility of code affected by these status effects to check
/// if the entity has any relevant status before exucuting relevant logic.
abstract class EntityStatus {}

mixin IgnoresGravity on EntityStatus {}

mixin IgnoresGroundCollisions on EntityStatus {}
