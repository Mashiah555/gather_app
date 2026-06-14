import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/engine/game_state.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/engine/search_engine.dart';

typedef AIPayload = ({GameState state, int depth, Duration timeout});

int? _calculateAI(AIPayload payload) {
  final engine = SearchEngine(
    maxDepth: payload.depth,
    timeout: payload.timeout,
  );
  return engine.getBestMove(payload.state);
}

class UltimateTicTacToeController extends ChangeNotifier {
  final Map<String, dynamic> configs;

  late GameState gameState;
  bool isComputerThinking = false;
  int? lastMoveIndex;
  List<int>? winningLine;

  Timer? _humanTimer;
  int humanMaxSeconds = -1;
  int humanSecondsLeft = 0;

  UltimateTicTacToeController({required this.configs}) {
    initGame();
  }

  void initGame() {
    gameState = GameState();
    lastMoveIndex = null;
    winningLine = null;
    isComputerThinking = false;
    _parseHumanTimeout();

    if (gameState.turn == human) {
      _startHumanTimer();
    } else {
      _triggerAI();
    }
    notifyListeners();
  }

  void _parseHumanTimeout() {
    final String timeString = configs['time_limit'] as String? ?? 'Unlimited';
    switch (timeString) {
      case '10 seconds':
        humanMaxSeconds = 10;
        break;
      case '30 seconds':
        humanMaxSeconds = 30;
        break;
      case '60 seconds':
        humanMaxSeconds = 60;
        break;
      case 'Unlimited':
      default:
        humanMaxSeconds = -1;
        break;
    }
  }

  void _startHumanTimer() {
    _humanTimer?.cancel();
    if (humanMaxSeconds == -1 || gameState.isFinished) return;

    humanSecondsLeft = humanMaxSeconds;
    notifyListeners();

    _humanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (humanSecondsLeft > 0) {
        humanSecondsLeft--;
        notifyListeners();
      } else {
        _humanTimer?.cancel();
        final moves = gameState.getLegalMoves();
        if (moves.isNotEmpty) {
          moves.shuffle();
          handleTap(moves.first);
        }
      }
    });
  }

  void handleTap(int index) async {
    if (gameState.isFinished ||
        isComputerThinking ||
        gameState.turn == computer) {
      return;
    }
    if (!gameState.getLegalMoves().contains(index)) return;

    _humanTimer?.cancel();
    gameState.makeMove(index);
    lastMoveIndex = index;
    _checkGameEnd();
    notifyListeners();

    if (!gameState.isFinished) {
      _triggerAI();
    }
  }

  Future<void> _triggerAI() async {
    isComputerThinking = true;
    notifyListeners();

    final int aiDepth = (configs['ai_depth'] as double?)?.toInt() ?? 6;
    int? bestMove;
    final stopwatch = Stopwatch()..start();

    if (aiDepth == 0) {
      final moves = gameState.getLegalMoves();
      if (moves.isNotEmpty) {
        moves.shuffle();
        bestMove = moves.first;
      }
    } else {
      final Duration aiTimeout = aiDepth <= 5
          ? const Duration(seconds: 3)
          : (aiDepth <= 7
                ? const Duration(seconds: 5)
                : const Duration(seconds: 10));
      final clone = GameState.clone(gameState);
      bestMove = await compute(_calculateAI, (
        state: clone,
        depth: aiDepth,
        timeout: aiTimeout,
      ));
    }

    stopwatch.stop();
    if (stopwatch.elapsedMilliseconds < 1000) {
      await Future.delayed(
        Duration(milliseconds: 1000 - stopwatch.elapsedMilliseconds),
      );
    }

    if (bestMove != null) {
      gameState.makeMove(bestMove);
      lastMoveIndex = bestMove;
      isComputerThinking = false;
      _checkGameEnd();
      notifyListeners();

      if (!gameState.isFinished) {
        _startHumanTimer();
      }
    }
  }

  void _checkGameEnd() {
    if (gameState.isFinished) {
      _humanTimer?.cancel();
      for (List<int> l in winLines) {
        int m1 = gameState.macroBoard[l[0]];
        int m2 = gameState.macroBoard[l[1]];
        int m3 = gameState.macroBoard[l[2]];
        if (m1 != empty && m1 != tieBoard && m1 == m2 && m2 == m3) {
          winningLine = l;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _humanTimer?.cancel();
    super.dispose();
  }
}
