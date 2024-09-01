import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/entities/physical_entity.dart';

/// A base for building status effects pertaining to [PhysicalEntity]. Effects
/// could be implemented as mixins (see [IgnoresGravity]), whereas fully custom
/// statuses may simply extend this and have no mixins.
///
/// It is the responsibility of code affected by these status effects to check
/// if the entity has any relevant status before exucuting relevant logic.
class EntityStatus extends Component {
  // The entity this was added to, only valid when mounted
  late PhysicalEntity entity;

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(parent is PhysicalEntity, 'parent must be PhysicalEntity');
    entity = parent! as PhysicalEntity;
    entity.onStatusMount(this);
  }

  @override
  @mustCallSuper
  void onRemove() {
    entity.onStatusRemove(this);
    super.onRemove();
  }
}

/// A status mixin which indicates the parent entity should not
/// be considered part of the physical world anymore. This means
/// it will not be moved by gravity or velocity (unless you manually
/// update the position) and it will be completely ignored by the collision
/// system so nothing else will collide with it.
mixin IgnoredByWorld on EntityStatus {}

/// A status mixin which indicates the parent entity should not
/// be affected by gravity while the status is present.
mixin IgnoresGravity on EntityStatus {}

/// A status mixin which indicates the parent entity should not
/// be automatically moved by its velocity.
mixin IgnoresVelocity on EntityStatus {}

/// A status mixin which indicates the parent entity should not
/// be eligible to collide with by others.
mixin IgnoredByCollisions on EntityStatus {}

/// A status mixin which indicates the parent entity should not
/// collide attempt to collide with other things.
mixin IgnoresCollisions on EntityStatus {}

/// A status mixin which indicates the parent entity should not
/// collide with solids (ground).
mixin IgnoresSolidCollisions on EntityStatus {}

/// A status mixin which indicates the parent entity should not
/// collide with non-solids.
mixin IgnoresNonSolidCollisions on EntityStatus {}

/// A status mixin which indicates the parent entity should not
/// collide with any other entities which have a tag in [ignoreTags]
mixin IgnoresCollisionTags on EntityStatus {
  final ignoreTags = <String>{};
}
