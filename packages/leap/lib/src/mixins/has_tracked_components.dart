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
mixin TrackedComponent<K, T extends HasTrackedComponents> on HasGameRef<T> {
  @override
  void onMount() {
    super.onMount();
    gameRef.allTrackedComponents
        .putIfAbsent(K.runtimeType, () => List<K>.empty(growable: true));
    (gameRef.allTrackedComponents[K.runtimeType]! as List).add(this);
  }

  @override
  void onRemove() {
    super.onRemove();
    (gameRef.allTrackedComponents[K.runtimeType]! as List).remove(this);
  }
}
