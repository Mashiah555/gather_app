import 'dart:math';
import 'package:flutter/material.dart';

enum CrocPhase { idle, playing, chomp }

class CrocodileRouletteController extends ChangeNotifier {
  final Map<String, dynamic> configs;

  late int teethCount;
  late int playerCount;

  CrocPhase phase = CrocPhase.idle;

  late int badToothIndex;
  late List<bool> pressedTeeth;

  int currentPlayer = 1;
  int? losingPlayer;

  CrocodileRouletteController({required this.configs}) {
    _initGame();
  }

  void _initGame() {
    // Parse configurations, safely falling back to defaults
    teethCount = (configs['tooth_count'] as double?)?.toInt() ?? 12;
    playerCount = (configs['players'] as double?)?.toInt() ?? 2;

    _startRound();
  }

  void _startRound() {
    // Pick the trap tooth for this round
    badToothIndex = Random().nextInt(teethCount);
    pressedTeeth = List.generate(teethCount, (_) => false);

    currentPlayer = 1;
    losingPlayer = null;
    phase = CrocPhase.playing;

    notifyListeners();
  }

  void restart() {
    _startRound();
  }

  void pressTooth(int index) {
    // Ignore taps if game over or tooth is already pushed down
    if (phase != CrocPhase.playing || pressedTeeth[index]) return;

    pressedTeeth[index] = true;

    if (index == badToothIndex) {
      // TRAP TRIGGERED!
      phase = CrocPhase.chomp;
      losingPlayer = currentPlayer;
    } else {
      // Safe! Move to the next player
      currentPlayer++;
      if (currentPlayer > playerCount) {
        currentPlayer = 1; // Wrap around back to player 1
      }
    }

    notifyListeners();
  }
}
