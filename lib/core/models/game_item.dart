import 'package:flutter/material.dart';

// Model to define each game in the Gather App catalog
class GameItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Widget destination;

  GameItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.destination,
  });
}
