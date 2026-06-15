import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Global helper for the X:YY time format
String formatTargetTime(double time) {
  return time.toStringAsFixed(2).replaceAll('.', ':');
}

enum GamePhase { preparation, countdown, active, finished }

class PlayerState {
  final int id;
  final String keybind;
  final Color themeColor;
  double? stoppedTime;

  PlayerState({
    required this.id,
    required this.keybind,
    required this.themeColor,
  });

  bool get hasStopped => stoppedTime != null;
}

class TargetTimeController extends ChangeNotifier {
  final Map<String, dynamic> configs;
  final VoidCallback onGameFinished;

  late int maxTime;
  late int playerCount;
  late double targetTime;

  GamePhase phase = GamePhase.preparation;
  int countdownNumber = 3;
  bool isCounterVisible = true;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _uiTimer;
  Timer? _phaseTimer;

  List<PlayerState> players = [];
  List<PlayerState> winners = [];

  TargetTimeController({required this.configs, required this.onGameFinished}) {
    _initGame();
  }

  void _initGame() {
    maxTime = (configs['max_time'] as double?)?.toInt() ?? 10;
    // Safely cap at 6 players just in case
    playerCount = min((configs['players'] as double?)?.toInt() ?? 2, 6);

    targetTime = Random().nextDouble() * (maxTime - 3) + 3;
    _setupPlayers();
    _startPreparation();
  }

  void _setupPlayers() {
    final colors = [
      const Color(0xFF4A00E0), // Royal Blue
      const Color(0xFFFF416C), // Rose
      const Color(0xFF00C9FF), // Teal
      const Color(0xFFFFB75E), // Amber
      const Color(0xFF8E2DE2), // Purple
      const Color(0xFF11998E), // Neon Mint
    ];
    final keys = ['A', 'L', 'V', 'M', 'Q', 'P'];

    players = List.generate(
      playerCount,
      (i) => PlayerState(
        id: i + 1,
        keybind: keys[i],
        themeColor: colors[i % colors.length],
      ),
    );
  }

  void _startPreparation() {
    phase = GamePhase.preparation;
    notifyListeners();
  }

  void startCountdown() {
    if (phase != GamePhase.preparation) return;

    phase = GamePhase.countdown;
    countdownNumber = 3;
    notifyListeners();

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownNumber > 1) {
        countdownNumber--;
        notifyListeners();
      } else {
        timer.cancel();
        _startGameplay();
      }
    });
  }

  void _startGameplay() {
    phase = GamePhase.active;
    isCounterVisible = true;
    _stopwatch.reset();
    _stopwatch.start();

    _uiTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => notifyListeners(),
    );

    _phaseTimer = Timer(const Duration(seconds: 2), () {
      isCounterVisible = false;
      notifyListeners();
    });
  }

  void playerTap(int playerId) {
    if (phase != GamePhase.active) return;

    final player = players.firstWhere((p) => p.id == playerId);
    if (player.hasStopped) return;

    player.stoppedTime = _stopwatch.elapsedMilliseconds / 1000.0;
    notifyListeners();

    if (players.every((p) => p.hasStopped)) {
      _endGame();
    }
  }

  void _endGame() {
    _stopwatch.stop();
    _uiTimer?.cancel();
    _phaseTimer?.cancel();
    phase = GamePhase.finished;

    _calculateWinners();
    notifyListeners();
    onGameFinished();
  }

  void _calculateWinners() {
    double minDifference = double.infinity;
    for (var player in players) {
      final diff = (player.stoppedTime! - targetTime).abs();
      if (diff < minDifference) {
        minDifference = diff;
      }
    }

    winners = players
        .where(
          (p) => (p.stoppedTime! - targetTime).abs() <= minDifference + 0.001,
        )
        .toList();
  }

  double get currentTime => _stopwatch.elapsedMilliseconds / 1000.0;

  void restart() {
    _stopwatch.stop();
    _uiTimer?.cancel();
    _phaseTimer?.cancel();

    for (var p in players) {
      p.stoppedTime = null;
    }

    targetTime = Random().nextDouble() * (maxTime - 3) + 3;
    _startPreparation();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _uiTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }
}
