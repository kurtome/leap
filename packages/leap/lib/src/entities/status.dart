import 'package:flame/components.dart';
import 'package:leap/leap.dart';

/// A base for building status effects pertaining to [PhysicalEntity]. Effects
/// which could are reusable are typically implemented as mixins
/// (see [IgnoresGravity]), whereas fully custom statuses may simply extend this
/// and have no mixins.
///
/// It is the responsibility of code affected by these status effects to check
/// if the entity has any relevant status before exucuting relevant logic.
class StatusComponent extends PositionComponent {
  @override
  void onMount() {
    (parent! as PhysicalEntity).onStatusMount(this);
  }

  @override
  void onRemove() {
    (parent! as PhysicalEntity).onStatusRemove(this);
  }
}

/// A status mixin which indicates the parent entity should not
/// be affected by gravity while the status is present.
mixin IgnoresGravity on StatusComponent {}

/// A status mixin which indicates the parent entity should not
/// collide with ground.
mixin IgnoresGroundCollisions on StatusComponent {}
