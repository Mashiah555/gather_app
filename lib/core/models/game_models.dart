import 'package:flutter/material.dart';

// Defines the UI components needed for the pre-game configs
abstract class GameConfigOption {
  final String key;
  final String title;

  GameConfigOption({required this.key, required this.title});
}

class SliderConfig extends GameConfigOption {
  final double min;
  final double max;
  final int divisions;
  final double defaultValue;

  SliderConfig({
    required super.key,
    required super.title,
    required this.min,
    required this.max,
    required this.divisions,
    required this.defaultValue,
  });
}

class DropdownConfig extends GameConfigOption {
  final List<String> options;
  final String defaultValue;

  DropdownConfig({
    required super.key,
    required super.title,
    required this.options,
    required this.defaultValue,
  });
}

// A builder function that injects the selected configs into your game screen
typedef GameBuilder = Widget Function(Map<String, dynamic> selectedConfigs);

class GameItem {
  final String title;
  final String subtitle;
  final String description;
  final String rules;
  final IconData icon;
  final List<Color> gradient;
  final List<GameConfigOption> configs;
  final GameBuilder gameBuilder;

  GameItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.rules,
    required this.icon,
    required this.gradient,
    required this.configs,
    required this.gameBuilder,
  });
}
