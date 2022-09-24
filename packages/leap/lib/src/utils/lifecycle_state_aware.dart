import 'dart:ui';

import 'package:flame/components.dart';

/// Interface for opting into app lifecycle state changes
mixin AppLifecycleAware on Component {
  void appLifecycleStateChanged(
    AppLifecycleState previous,
    AppLifecycleState current,
  );
}
