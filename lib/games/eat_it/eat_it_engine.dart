import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'components/black_hole.dart';
import 'components/consumable.dart';

class EatItEngine extends FlameGame
    with HasCollisionDetection, MouseMovementDetector {
  late BlackHole player;
  late final World gameWorld;
  late final CameraComponent cam;
  JoystickComponent? joystick;

  final bool isDesktop =
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  Vector2? _mouseTarget;
  final Random _random = Random();

  // Define the boundaries of our level
  final double mapWidth = 5000;
  final double mapHeight = 5000;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Initialize the World
    gameWorld = World();
    add(gameWorld);

    // 2. Initialize the Player and add it to the WORLD
    player = BlackHole(position: Vector2.zero());
    gameWorld.add(player);

    // 3. Initialize the Camera, point it at the World, and tell it to follow the player
    cam = CameraComponent(world: gameWorld);
    cam.follow(player);
    add(cam);

    // 4. Generate the map
    _generateCityMap();

    // 5. Setup the UI/Input on the VIEWPORT (so it doesn't move away when the camera pans)
    if (!isDesktop) {
      joystick = JoystickComponent(
        knob: CircleComponent(
          radius: 20,
          paint: Paint()..color = Colors.white70,
        ),
        background: CircleComponent(
          radius: 60,
          paint: Paint()..color = Colors.white24,
        ),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );
      cam.viewport.add(joystick!); // Added to viewport, not the world!
    }
  }

  void _generateCityMap() {
    // Randomly scatter objects across the map bounds
    _spawnObjects(150, Vector2(80, 80), 1, 'apple.png'); // Apples / Small trash
    _spawnObjects(80, Vector2(100, 100), 5, 'car.png'); // Cars
    _spawnObjects(50, Vector2(250, 300), 20, 'building.png'); // Buildings
  }

  void _spawnObjects(int count, Vector2 size, int points, String sprite) {
    for (int i = 0; i < count; i++) {
      // Generate a random position within -1000 to +1000 on both X and Y axes
      final randomX = (_random.nextDouble() - 0.5) * mapWidth;
      final randomY = (_random.nextDouble() - 0.5) * mapHeight;

      final consumable = Consumable(
        position: Vector2(randomX, randomY),
        size: size,
        pointValue: points,
        spritePath: sprite,
      );

      // Crucial: Add objects to the World, not directly to the game
      gameWorld.add(consumable);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDesktop && _mouseTarget != null) {
      // Adjust mouse target to world coordinates based on camera position
      final worldMousePosition = cam.globalToLocal(_mouseTarget!);
      player.position.lerp(worldMousePosition, dt * 2);
    } else if (joystick != null &&
        joystick!.direction != JoystickDirection.idle) {
      const double moveSpeed = 100.0;
      player.position.add(joystick!.relativeDelta * moveSpeed * dt);
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (isDesktop) {
      // Store the global screen position of the mouse
      _mouseTarget = info.eventPosition.global;
    }
  }
}
