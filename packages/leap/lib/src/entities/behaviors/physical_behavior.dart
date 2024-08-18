import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:leap/leap.dart';

/// Base class for behaviors on [PhysicalEntity].
abstract class PhysicalBehavior<T extends PhysicalEntity> extends Behavior<T> {
  PhysicalBehavior({
    super.children,
    super.priority,
    super.key,
  });

  CollisionInfo get collisionInfo => parent.collisionInfo;
  CollisionInfo get prevCollisionInfo => parent.prevCollisionInfo;

  LeapMap get leapMap => parent.leapMap;
  LeapWorld get leapWorld => parent.leapWorld;

  Vector2 get position => parent.position;
  Vector2 get prevPosition => parent.prevPosition;

  double get x => parent.x;
  double get y => parent.y;

  double get left => parent.left;
  double get right => parent.right;
  double get top => parent.top;
  double get bottom => parent.bottom;

  double get width => parent.width;
  double get height => parent.height;

  double get centerX => parent.centerX;
  double get centerY => parent.centerY;

  int get tileTop => parent.gridTop;
  int get tileBottom => parent.gridBottom;
  int get tileLeft => parent.gridLeft;
  int get tileRight => parent.gridRight;

  Vector2 get velocity => parent.velocity;
}
