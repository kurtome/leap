import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:leap/leap.dart';

@Deprecated('no longer in use')
mixin HasTrackedComponents<W extends LeapWorld> on FlameGame<W> {
  final Map<Type, dynamic> allTrackedComponents = <Type, dynamic>{};

  List<T> trackedComponents<T>() {
    allTrackedComponents.putIfAbsent(
      T.runtimeType,
      () => List<T>.empty(growable: true),
    );
    return allTrackedComponents[T.runtimeType] as List<T>;
  }
}

@Deprecated('no longer in use')
mixin TrackedComponent<K, T extends HasTrackedComponents>
    on HasGameReference<T> {
  @override
  void onMount() {
    super.onMount();
    game.allTrackedComponents
        .putIfAbsent(K.runtimeType, () => List<K>.empty(growable: true));
    (game.allTrackedComponents[K.runtimeType]! as List).add(this);
  }

  @override
  void onRemove() {
    super.onRemove();
    (game.allTrackedComponents[K.runtimeType]! as List).remove(this);
  }
}
