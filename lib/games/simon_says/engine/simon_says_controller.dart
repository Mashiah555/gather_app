import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum SimonPhase { idle, playingSequence, waitingForInput, gameOver }

class SimonSaysController extends ChangeNotifier {
  final Map<String, dynamic> configs;

  SimonPhase phase = SimonPhase.idle;

  List<int> sequence = [];
  int currentInputIndex = 0;
  int score = 0;
  int activePad = -1;

  late Duration playbackSpeed;
  late bool strictMode;
  late int colorCount;
  late int startingDifficulty;

  bool _isDisposed = false;

  SimonSaysController({required this.configs}) {
    _parseConfigs();
  }

  void _parseConfigs() {
    final double speedMultiplier = 9 - ((configs['speed'] as double?) ?? 5.0);
    playbackSpeed = Duration(milliseconds: (speedMultiplier * 150).toInt());

    strictMode = (configs['strict_mode'] as bool?) ?? true;
    colorCount = (configs['color_count'] as double?)?.toInt() ?? 4;
    startingDifficulty =
        (configs['starting_difficulty'] as double?)?.toInt() ?? 1;
  }

  void startGame() {
    _parseConfigs();
    score = 0;
    sequence.clear();
    phase = SimonPhase.idle;

    // Pre-populate the sequence based on the starting difficulty
    // Subtracts 1 because _nextRound() will immediately add 1 more.
    for (int i = 0; i < startingDifficulty - 1; i++) {
      sequence.add(Random().nextInt(colorCount));
    }

    _nextRound();
  }

  void _nextRound() {
    if (_isDisposed) return;

    sequence.add(Random().nextInt(colorCount));
    currentInputIndex = 0;
    _playSequence();
  }

  Future<void> _playSequence() async {
    phase = SimonPhase.playingSequence;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    for (int padIndex in sequence) {
      if (_isDisposed) return;

      activePad = padIndex;
      notifyListeners();

      await Future.delayed(playbackSpeed);
      if (_isDisposed) return;

      activePad = -1;
      notifyListeners();

      await Future.delayed(
        Duration(milliseconds: playbackSpeed.inMilliseconds ~/ 2),
      );
    }

    if (!_isDisposed) {
      phase = SimonPhase.waitingForInput;
      notifyListeners();
    }
  }

  void handlePadTap(int padIndex) async {
    if (phase != SimonPhase.waitingForInput) return;

    activePad = padIndex;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_isDisposed) {
        activePad = -1;
        notifyListeners();
      }
    });

    if (padIndex == sequence[currentInputIndex]) {
      currentInputIndex++;

      if (currentInputIndex >= sequence.length) {
        score++;
        phase = SimonPhase.idle;
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 800), _nextRound);
      }
    } else {
      if (strictMode) {
        phase = SimonPhase.gameOver;
      } else {
        phase = SimonPhase.idle;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 800), _playSequence);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
