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
/// be considered part of the physical world anymore. This means
/// it will not be moved by gravity or velocity (unless you manually
/// update the position) and it will be completely ignored by the collision
/// system so nothing else will collide with it.
mixin IgnoredByWorld on StatusComponent {}

/// A status mixin which indicates the parent entity should not
/// be affected by gravity while the status is present.
mixin IgnoresGravity on StatusComponent {}

/// A status mixin which indicates the parent entity should not
/// be automatically moved by its velocity.
mixin IgnoresVelocity on StatusComponent {}

/// A status mixin which indicates the parent entity should not
/// be eligible to collide with by others.
mixin IgnoredByCollisions on StatusComponent {}

/// A status mixin which indicates the parent entity should not
/// collide attempt to collide with other things.
mixin IgnoresCollisions on StatusComponent {}

/// A status mixin which indicates the parent entity should not
/// collide with solids (ground).
mixin IgnoresSolidCollisions on StatusComponent {}

/// A status mixin which indicates the parent entity should not
/// collide with non-solids.
mixin IgnoresNonSolidCollisions on StatusComponent {}
