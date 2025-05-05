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

  final _intro = Completer<void>();
  final _outro = Completer<void>();

  void markIntroFinished() {
    _intro.complete();
  }

  void markFinished() {
    _outro.complete();
  }

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    await super.onLoad();
    intro();
  }

  Future<void> get introFinished => _intro.future;
  Future<void> get outroFinished => _outro.future;

  void intro();
  void outro();
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
  }

  @override
  void intro() {
    add(
      RectangleComponent(
        size: game.size.clone(),
        paint: Paint()..color = color.withValues(alpha: 0),
        children: [
          OpacityEffect.to(
            1,
            LinearEffectController(duration),
            onComplete: markIntroFinished,
          ),
        ],
      ),
    );
  }

  @override
  void outro() {
    firstChild<RectangleComponent>()?.add(
      OpacityEffect.to(
        0,
        LinearEffectController(duration),
        onComplete: markFinished,
      ),
    );
  }
}
