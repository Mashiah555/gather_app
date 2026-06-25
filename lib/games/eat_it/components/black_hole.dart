import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'consumable.dart';

class BlackHole extends CircleComponent with CollisionCallbacks {
  BlackHole({required Vector2 position})
    : super(
        position: position,
        radius: 40.0,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.white,
        priority: 0,
      ) {
    // Make the hitbox slightly smaller than the visual hole
    // This forces objects to get closer to the center to be eaten
    add(CircleHitbox(radius: 30.0, position: Vector2(10, 10)));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Only eat it if it's a Consumable AND it isn't already being sucked in
    if (other is Consumable && !other.isBeingEaten) {
      // Check if the hole is large enough (radius vs object width)
      if (radius > other.size.x * 0.4) {
        eat(other);
      }
    }
  }

  void eat(Consumable consumable) {
    // 1. Mark as being eaten so the collision doesn't trigger again
    consumable.isBeingEaten = true;

    // 2. Grow the hole slightly
    radius += consumable.pointValue * 0.5;

    // 3. Update the hitbox size to scale with the new radius
    final hitbox = children.whereType<CircleHitbox>().first;
    hitbox.radius = radius * 0.75;
    hitbox.position = Vector2.all(radius * 0.25);

    // 4. Tell the consumable to play its death animation, pulling it to the hole's center
    consumable.suckIntoHole(position);
  }
}
