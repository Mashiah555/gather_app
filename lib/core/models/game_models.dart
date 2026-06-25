import 'package:flutter/material.dart';
import 'package:gather_app/l10n/generated/l10n.dart';

// Defines the UI components needed for the pre-game configs
abstract class GameConfigOption {
  final String key;
  final String Function(AppLocalizations l10n) titleBuilder; // Deferred string

  GameConfigOption({required this.key, required this.titleBuilder});
}

class SliderConfig extends GameConfigOption {
  final double min;
  final double max;
  final int divisions;
  final double defaultValue;

  SliderConfig({
    required super.key,
    required super.titleBuilder,
    required this.min,
    required this.max,
    required this.divisions,
    required this.defaultValue,
  });
}

class DropdownConfig extends GameConfigOption {
  final List<String> Function(AppLocalizations l10n) optionsBuilder;
  final String Function(AppLocalizations l10n) defaultValueBuilder;

  DropdownConfig({
    required super.key,
    required super.titleBuilder,
    required this.optionsBuilder,
    required this.defaultValueBuilder,
  });
}

// A builder function that injects the selected configs into your game screen
typedef GameBuilder = Widget Function(Map<String, dynamic> selectedConfigs);

class GameItem {
  final String id;
  final String Function(AppLocalizations l10n) titleBuilder;
  final String Function(AppLocalizations l10n) subtitleBuilder;
  final String Function(AppLocalizations l10n) descriptionBuilder;
  final String Function(AppLocalizations l10n) rulesBuilder;
  final IconData icon;
  final List<Color> gradient;
  final List<GameConfigOption> configs;
  final GameBuilder gameBuilder;

  GameItem({
    required this.id,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.descriptionBuilder,
    required this.rulesBuilder,
    required this.icon,
    required this.gradient,
    required this.configs,
    required this.gameBuilder,
  });
}
