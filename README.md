# Leap

An opinionated toolkit for creating 2D platformers on top of the
[Flame engine](https://flame-engine.org/).

## WARNING library under development

Be aware that this is still under development and is likely to change
frequently, every release could introduce breaking changes up until a `v1.0.0`
release (which may never happen as this is a solo endeavour currently).

## Features

### Level creation via Tiled

Leap uses Tiled tile maps not just for visually rendering the level, but also
for imbuing behavior and terrain in the level by creating corresponding Flame
components automatically from the map's layers.

### Physics

The crux of this physics engine is based on this post The guide to implementing
2D platformers:
http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/

The "Type #2: Tile Based (Smooth)" section outlines the overall algorithm.

Note that Leap doesn't use Flame's collision detection system in favor of one
that is more specialized and efficient for tile based platformers where every
hitbox is an axis-aligned bounding box, and special handling can be done for
tile grid aligned components (such as ground terrain).

#### Efficient collision detection

![image](docs/images/megaman_tile_grid.png)

Essentially all physical objects (`PhsyicalComponent`) in the game have
axis-aligned bounding boxes (AABBs) for hitboxes, determined by their `size` and
`position`. The hitbox doesn't necessarily need to match the visual size of the
component.

✅ Supported tile platformer features:

- Ground terrain
- One way platforms
- Slopes
- Moving platforms
- Ladders

🚧 Future tile platformer features:

- Friction control for ground tiles (for ice, etc.)
- Interactive ground tiles
- Removable ground tiles
- One way walls

#### Simple physics designed for 2D platformers

Long story short: physics engines like `box2d` are great for emulating realistic
physics and terrible for implementing retro-style 2d platformers which are not
remotely realistic. In order to get the snappy jumps and controls required for a
responsive platformer a much more rudimentary physics engine is required.

In Leap, physical entities have a `velocity` attribute for storing the current
`x` and `y` velocity, which will automatically update the entity's position. A
moving entity colliding with the level terrain will automatically have its
velocity set to `0` and position updated to be kept outside the terrain to
prevent overlap. There is also a global `gravity` rate applied to the `y`
velocity every game tick. Static entities will never be moved by velocity or
gravity.

## Getting started

Before using Leap, you should be familiar with the following Flame components:

- FlameGame
- CameraComponent
- PositionComponent
- TiledComponent

## Usage

### LeapGame

To use Leap, your game instance must extend `LeapGame` (which in turn extends
`FlameGame`). It's recommended to use `game.loadWorldAndMap` to initialize the
game's `world` and `map`.

### LeapWorld

Accessible via `LeapGame.world`, this component manages any global logic
necessary for the physics engine.

### LeapMap

Accessible via `LeapGame.map`, this component manages the Tiled map and
automatically constructs the tiles with proper collision detection for the
ground terrain. See [Tiled map integration](#Tiled map integration) below

### Game code snippet

See [the standard_platformer example](examples/standard_platformer) for complete
game code.

```dart
void main() {
  runApp(GameWidget(game: MyLeapGame()));
}

class MyLeapGame extends LeapGame with HasTappables, HasKeyboardHandlerComponents {
  late final Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // "map.tmx" should be a Tiled map the meets the Leap requirements defined below
    await loadWorldAndMap('map.tmx', 16);
    setFixedViewportInTiles(32, 16);

    player = Player();
    add(player);
    camera.followComponent(player);
  }
}
```

### PhyiscalEntity physics system

The physics system for Leap requires that every `Component` that interacts with
the game's phyical world extend `PhysicalEntity` and be added to the `LeapWorld`
component which is accessible via `LeapGame.world`.

#### Status effect system

`PhysicalEntity` components can have statuses (`StatusComponent`) which modify
their behavior. Statuses affect the component they are added to. For example,
you could implement a `StarPowerStatus` which when added to your player
component makes them flash colors become invincible.

Since statuses are themselves components, they can maintain their own state and
handle updating themselves or their parent `PhysicalEntity` components. See
`OnLadderStatus` for an example of this.

There are mixins on `StatusComponent` which affect the Leap engine's handling of
the parent `PhysicalEntity`. See:

- `IgnoresGravity`
- `IgnoresSolidCollisions`

You can implement your own mixins on `StatusComponent` which control pieces of
logic in your own game.

### Tiled map integration

Leap automatically parses specific features out of specific Tiled layers.

#### Ground layer

Layer must be a Tile Layer named "Ground", by default all tiles placed in this
layer are assumed to be ground terrain in the physics of the game. This means
these tiles will be statically positioned and have a hitbox that matches the
width and height of the tile.

Specialized ground tiles:

- **Slopes** for terrain the physical can walk up/down like a hill. These tiles
  must have their `class` property set to `"Slope"` and two custom `int`
  properties `LeftTop` and `RightTop`. For example, a 16x16 pixel tile with
  `LeftTop = 0` and `RightTop = 8` indicates slope that is ascending when moving
  from left-to-right.
- **One Way Platforms** for terrain the physical entities can move up (e.g.
  jump) through from all but one direction. These are implemented via
  `GroundTileHandler` classes, and can therefore use and `class` you want via
  passing in a map of custom `groundTileHandlers` when loading the map (see
  below). The most used is `OneWayTopPlatformHandler` which modifies the tile to
  be phased through from below and the sides, but solid from the top.

##### Custom ground tile handling

To have complete control over individual tiles in the ground layer, you can use
the `class` property in the Tiled editor tileset to hook into the
`groundTileHandlers` you pass in when loading your map.

In your `LeapGame`:

```dart
await loadWorldAndMap(
  camera: camera,
  tiledMapPath: 'map.tmx',
  groundTileHandlers: {
    'OneWayTopPlatform': OneWayTopPlatformHandler(),
    'MyCustomTile': MyCustomTileHandler(),
  },
);
```

And your `MyCustomTileHandler`:

```dart
class MyCustomTileHandler implements GroundTileHandler {
  @override
  LeapMapGroundTile handleGroundTile(LeapMapGroundTile groundTile, LeapMap map) {
    tile.tags.add('PowerUpTile');

    // Add some extra rendering on top of your special tile.
    map.add(PowerUpTileAnimationComponent(x: groundTile.x, y: groundTile.y));

    // use the provided tile instance in the map
    return tile;
  }
}

// OR

class MyCustomTileHandler implements GroundTileHandler {
  @override
  LeapMapGroundTile handleGroundTile(LeapMapGroundTile groundTile, LeapMap map) {
    // MyCustomTile constructor must call the super constructor to initialize
    // the the LeapMapGroundTile properties
    return MyCustomTile(
      groundTile,
      myCustomProperty: groundTile.tile.properties.getValue<int>('PowerValue'),
    );
  }
}
```

Note that the `class` property is **always** added to each tile's
`PhysicalEntity.tags`. So, you can check if your player is walking into a
special type of wall with something like this:

```dart
class Player extends PhysicalEntity {

  @override
  void update(double dt) {
    super.update(dt);

    if (collisionInfo.right && // hitting solid entity on the right
        input.actionButtonPressed && // custom input handling
        collisionInfo.rightCollision!.tags.contains('MySpecialTile')) {
      // right collision has a tag we set from Tiled's tileset `class` property
      // (tag could also be added by your own custom handling)
      specialInteraction(collisionInfo.rightCollision!);
    }
  }

}
```

#### Metadata layer

Layer must be an Object Group named "Metadata", used to place any objects to be
used in your game like level start/end, enemy spawn points, anything you want.

#### Object Group layers

Any Object Group layer (including the Metadata layer) can include arbitrary
objects in them, if you wish to automatically create Flame Components for some
of those objects you can do so based on the Class string in Tiled. All that is
required is implementing the `TiledObjectFactory` interface and mapping each
Class string you care about to a factory instance when loading the `LeapMap`,
for example...

In your `LeapGame`:

```dart
await loadWorldAndMap(
  camera: camera,
  tiledMapPath: 'map.tmx',
  tiledObjectHandlers: {
    'Coin': await CoinFactory.createFactory(),
  },
);
```

Your custom factory:

```dart
class CoinFactory implements TiledObjectFactory<Coin> {
  late final SpriteAnimation spriteAnimation;

  CoinFactory(this.spriteAnimation);

  @override
  void handleObject(TiledObject object, Layer layer, LeapMap map) {
    final coin = Coin(object, spriteAnimation);
    map.add(coin);
  }

  static Future<CoinFactory> createFactory() async {
    final tileset = await Flame.images.load('my_animated_coin.png');
    final spriteAnimation = SpriteAnimation.fromFrameData(
      tileset,
      SpriteAnimationData.sequenced(...),
    );
    return CoinFactory(spriteAnimation);
  }
}

class Coin extends PhysicalEntity {
  Coin(TiledObject object, this.animation)
      : super(static: true) {
    anchor = Anchor.center;

    // Use the position from your Tiled map
    position = Vector2(object.x, object.y);

    // Use custom properties from your Tiled object
    value = tiledObject.properties.getValue<int>('CoinValue');
  }

  ...
}
```

#### Other layers

Any other layers will be rendered visually but have no impact on the game
automatically. You can add additional custom behavior by accessing the layers
via `LeapGame.map.tiledMap` and integrating your own special behavior for tiles
or objects.

#### Moving platforms

To create a moving platform, you need to implement your own component which
extends `MovingPlatform` and provides a Sprite (or some other rendering).

If you choose to implement this component with a Tiled object (recommended),
many of the fields can be directly read from the object's custom properties:

- `MoveSpeedX` (double), speed in tiles per second on the X axis
- `MoveSpeedY` (double), speed in tiles per second on the y axis
- `LoopMode` (string), one of `resetAndLoop`, `reverseAndLoop`, `none`
- `TilePath` (string), a list of grid offsets to define the platforms path of
  movement. For example, `0,-3;2,0` means the platform will move up 3 tiles and
  then move right 2 tiles.

#### Ladders

To create a ladder, you need to implement your own component which extends
`Ladder` and provides a Sprite (or some other rendering).

Ladders also require custom integration with your components which are able to
climb the ladder. This is accomplished by adding an `OnLadderStatus` as a child
component, removing the child component will remove the component from the
ladder.

For example:

```dart
class Player extends PhyiscalEntity {

    void update(double dt) {
        // These booleans are fabricated for this example,
        // implement what makes senes for your own system.
        if (isNearLadder && actionButton.isPressed) {
            add(OnLadderStatus(ladder));
        } else if (hasStatus<OnLadderStatus>() && jumpButton.isPressed) {
            remove(getStatus<OnLadderStatus>());
        }
    }

}
```

To see a fully working example, see `Player` in `examples/standard_platformer`.

#### Customizing layer names and classes

Even though the structure explained above should always be followed, the
developer can ask Leap to use different classes, types, names.

In order to do so, a custom `LeapConfiguration` can be passed to the game.

Example:

```dart
class MyLeapGame extends LeapGame {
  MyLeapGame() : super(
    configuration: LeapConfiguration(
      tiled: const TiledOptions(
        groundLayerName: 'Ground',
        metadataLayerName: 'Metadata',
        playerSpawnClass: 'PlayerSpawn',
        damageProperty: 'Damage',
        platformClass: 'Platform',
        slopeType: 'Slope',
        slopeRightTopProperty: 'RightTop',
        slopeLeftTopProperty: 'LeftTop',
      ),
    ),
  );
}
```

## Debugging

### Slow motion

`LeapWorld` includes
[`HasTimeScale`](https://pub.dev/documentation/flame/latest/components/HasTimeScale-mixin.html),
so you can set `world.timeScale = 0.5` to slow your whole game down to 50% speed
to make it easier to play test nuanced bugs. (You can use this as slow motion
for your game too.)

### Render hitbox

`PhysicalEntity` includes a `debugHitbox` property you can override which will
automatically draw a box indicating the exact hitbox the collision detection
system is using for your entity.

```dart
class MyPlayer extends PhysicalEntity {

  @override
  void update(double dt) {
    // Draw entity's hitbox
    debugHitbox = true;
  }

}
```

## Roadmap 🚧

- Improved collision detection API.
  - The current API is fairly awkward, see `CollisionInfo`.
  - There is no great way to detect collision start or collision end.
- Add more robust and reusable base class for players/enemies/etc. (`Character`
  class).
  - Integrated with sprite animations based on character state
- Improved API for `PhysicalEntity`, `addImpulse` etc.
- Lots of code clean-up to make usage of Leap more ergonomic and configurable.

## Contributing

1. Ensure any changes pass:
   - `melos format`
   - `melos analyze`
   - `melos test`
2. Start your PR title with a
   [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/) type
   (feat:, fix: etc).
