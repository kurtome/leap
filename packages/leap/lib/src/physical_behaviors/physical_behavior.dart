import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_map.dart';
import 'package:leap/src/leap_world.dart';
import 'package:leap/src/physical_behaviors/physical_behaviors.dart';

/// Base class for behaviors on [PhysicalEntity].
abstract class PhysicalBehavior<T extends PhysicalEntity> extends Behavior<T> {
  CollisionInfo get collisionInfo => parent.collisionInfo;

  double get x => parent.x;
  double get y => parent.y;

  set x(double value) {
    parent.x = value;
  }

  set y(double value) {
    parent.y = value;
  }

  double get left => parent.left;
  double get right => parent.right;
  double get top => parent.top;
  double get bottom => parent.bottom;

  set left(double value) {
    parent.left = value;
  }

  set right(double value) {
    parent.right = value;
  }

  set top(double value) {
    parent.top = value;
  }

  set bottom(double value) {
    parent.bottom = value;
  }

  LeapWorld get world => parent.world;

  double get width => parent.width;
  double get height => parent.height;

  double get centerX => parent.centerX;
  double get centerY => parent.centerY;

  int get tileTop => parent.gridTop;
  int get tileBottom => parent.gridBottom;
  int get tileLeft => parent.gridLeft;
  int get tileRight => parent.gridRight;

  Vector2 get velocity => parent.velocity;
  LeapMap get map => parent.map;
}
