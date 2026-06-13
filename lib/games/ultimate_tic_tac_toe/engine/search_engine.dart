import 'dart:math';
import 'package:gather_app/games/ultimate_tic_tac_toe/engine/game_state.dart';

class TTEntry {
  final double value;
  final int depth;
  final String flag;
  final int bestMove;
  TTEntry(this.value, this.depth, this.flag, this.bestMove);
}

class SearchEngine {
  final int maxDepth;
  final Duration timeout;
  final Map<int, TTEntry> _tt = {};
  late DateTime _startTime;

  SearchEngine({this.maxDepth = 6, this.timeout = const Duration(seconds: 5)});

  int? getBestMove(GameState state) {
    _startTime = DateTime.now();
    int? bestMove;

    for (int depth = 1; depth <= maxDepth; depth++) {
      if (DateTime.now().difference(_startTime) > timeout && bestMove != null) {
        break; // Stop deepening if out of time
      }

      var result = _alphabeta(
        state,
        depth,
        double.negativeInfinity,
        double.infinity,
        state.turn == computer,
      );
      if (result.move != null) bestMove = result.move;

      if (result.value >= victory - 100 || result.value <= loss + 100) {
        break; // Forced end
      }
    }
    return bestMove;
  }

  ({double value, int? move}) _alphabeta(
    GameState state,
    int depth,
    double alpha,
    double beta,
    bool isMax,
  ) {
    TTEntry? ttEntry = _tt[state.zobristKey];
    if (ttEntry != null && ttEntry.depth >= depth) {
      if (ttEntry.flag == 'EXACT') {
        return (value: ttEntry.value, move: ttEntry.bestMove);
      }
      if (ttEntry.flag == 'LOWERBOUND') alpha = max(alpha, ttEntry.value);
      if (ttEntry.flag == 'UPPERBOUND') beta = min(beta, ttEntry.value);
      if (alpha >= beta) return (value: ttEntry.value, move: ttEntry.bestMove);
    }

    if (depth == 0 || state.isFinished) return (value: state.value, move: null);

    List<int> moves = state.getLegalMoves();
    if (moves.isEmpty) return (value: state.value, move: null);

    int? bestMoveSoFar = ttEntry?.bestMove;
    if (bestMoveSoFar != null && moves.contains(bestMoveSoFar)) {
      moves.remove(bestMoveSoFar);
      moves.insert(0, bestMoveSoFar);
    }

    int bestMove = moves[0];
    double originalAlpha = alpha;

    if (isMax) {
      double v = double.negativeInfinity;
      for (int move in moves) {
        state.makeMove(move);
        var result = _alphabeta(state, depth - 1, alpha, beta, false);
        state.unmakeMove();

        if (result.value > v) {
          v = result.value;
          bestMove = move;
        }
        alpha = max(alpha, v);
        if (alpha >= beta) break;
      }
      _saveTT(state.zobristKey, depth, v, originalAlpha, beta, bestMove);
      return (value: v, move: bestMove);
    } else {
      double v = double.infinity;
      for (int move in moves) {
        state.makeMove(move);
        var result = _alphabeta(state, depth - 1, alpha, beta, true);
        state.unmakeMove();

        if (result.value < v) {
          v = result.value;
          bestMove = move;
        }
        beta = min(beta, v);
        if (alpha >= beta) break;
      }
      _saveTT(state.zobristKey, depth, v, originalAlpha, beta, bestMove);
      return (value: v, move: bestMove);
    }
  }

  void _saveTT(
    int key,
    int depth,
    double v,
    double alpha,
    double beta,
    int move,
  ) {
    String flag = 'EXACT';
    if (v <= alpha) {
      flag = 'UPPERBOUND';
    } else if (v >= beta) {
      flag = 'LOWERBOUND';
    }
    _tt[key] = TTEntry(v, depth, flag, move);
  }
}
