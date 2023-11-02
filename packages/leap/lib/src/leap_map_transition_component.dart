import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:leap/leap.dart';

abstract class LeapMapTransition extends PositionComponent {
  LeapMapTransition({required this.game});

  factory LeapMapTransition.defaultFactory(LeapGame game) {
    return LeapFadeInOutMapTransition(
      game: game,
      duration: .4,
      color: Colors.black,
    );
  }

  final LeapGame game;

  final _readyForNewMap = Completer<void>();
  final _finished = Completer<void>();

  void markReadyForNewMap() {
    _readyForNewMap.complete();
  }

  void markFinished() {
    _finished.complete();
  }

  Future<void> get newMapReadyToBeLoaded => _readyForNewMap.future;
  Future<void> get finished => _finished.future;

  void newMapLoaded();
}

class LeapFadeInOutMapTransition extends LeapMapTransition {
  LeapFadeInOutMapTransition({
    required super.game,
    required this.duration,
    required this.color,
  });

  final double duration;
  final Color color;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleComponent(
        size: game.size.clone(),
        paint: Paint()..color = color.withOpacity(0),
        children: [
          OpacityEffect.to(
            1,
            LinearEffectController(duration),
            onComplete: markReadyForNewMap,
          ),
        ],
      ),
    );
  }

  @override
  void newMapLoaded() {
    firstChild<RectangleComponent>()?.add(
      OpacityEffect.to(
        0,
        LinearEffectController(duration),
        onComplete: markFinished,
      ),
    );
  }
}
