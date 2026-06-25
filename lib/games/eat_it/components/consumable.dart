import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class Consumable extends SpriteComponent {
  final int pointValue;
  final String spritePath;
  bool isBeingEaten = false;

  Consumable({
    required Vector2 position,
    required Vector2 size,
    required this.pointValue,
    required this.spritePath,
  }) : super(position: position, size: size, anchor: Anchor.center);

  void suckIntoHole(Vector2 holeCenter) {
    // 1. Immediately remove the hitbox so it doesn't block other objects
    children.whereType<CircleHitbox>().forEach(
      (hitbox) => hitbox.removeFromParent(),
    );

    // 2. Pull the object toward the center of the black hole
    add(
      MoveToEffect(
        holeCenter,
        EffectController(duration: 0.25, curve: Curves.easeIn),
      ),
    );

    // 3. Shrink the object to 0. When the effect completes, remove it from the game.
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.25, curve: Curves.easeIn),
        onComplete: () => removeFromParent(), // <--- DRY cleanup
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    // Flame automatically looks in the assets/images/ folder
    sprite = await Sprite.load(spritePath);

    // Shift the anchor to the bottom center so the object "stands" on the ground
    anchor = Anchor.bottomCenter;

    // The hitbox can be smaller than the image to make eating feel more forgiving
    add(
      CircleHitbox(
        radius: size.x / 2,
        anchor: Anchor.bottomCenter,
        position: Vector2(size.x / 2, size.y),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Y-SORTING: Objects further down the screen draw on top of objects higher up
    priority = position.y.toInt();
  }
}
