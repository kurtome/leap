import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

/// Interface for creating components from Tiled Objects.
mixin TiledObjectFactory<T extends Component> {
  /// Returns a Flame [Component] from a Tiled Object. Implementers
  /// can use the [TiledObject.x], [TiledObject.y], [TiledObject.properties],
  /// etc. to customize the component.
  T createComponent(TiledObject tiledObject);
}
