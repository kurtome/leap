import 'package:leap/src/entities/entities.dart';
import 'package:leap/src/leap_game.dart';

/// An example base class for a jumping player character.
///
/// Make your own version of this if needed or simply use a player
/// entity class with similar mixins and add the appropriate
/// behaviors.
class JumperCharacter<TGame extends LeapGame> extends PhysicalEntity
    with HasJumps, HasWalkSpeed, HasFaceLeft, HasHealth {
  // No behavior, just mixins and state
}
