import 'dart:math';
import 'dart:typed_data';

const int computer = 1;
const int human = -1;
const int empty = 0;
const int tieBoard = 2;

const double victory = 1000000000.0;
const double loss = -victory;
const double tie = 0.0;

final List<List<int>> winLines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
  [0, 4, 8], [2, 4, 6], // Diagonals
];

class MoveRecord {
  final int move;
  final int prevNextMacro;
  final int prevMacroVal;
  final bool prevFinished;
  final double prevValue;
  final int prevHash;

  MoveRecord(
    this.move,
    this.prevNextMacro,
    this.prevMacroVal,
    this.prevFinished,
    this.prevValue,
    this.prevHash,
  );
}

class Zobrist {
  static final Random _rand = Random(42);
  static int _get32BitRand() => _rand.nextInt(0xFFFFFFFF);

  static final Map<int, Map<int, int>> board = {};
  static final Map<int, Map<int, int>> macro = {};
  static final int turn = _get32BitRand();
  static final Map<int, int> nextMacro = {};

  static void initialize() {
    if (board.isNotEmpty) return;
    for (int i = 0; i < 81; i++) {
      board[i] = {computer: _get32BitRand(), human: _get32BitRand()};
    }
    for (int i = 0; i < 9; i++) {
      macro[i] = {
        computer: _get32BitRand(),
        human: _get32BitRand(),
        tieBoard: _get32BitRand(),
      };
    }
    for (int i = -1; i < 9; i++) {
      nextMacro[i] = _get32BitRand();
    }
  }
}

class GameState {
  final Int8List board = Int8List(81);
  final Int8List macroBoard = Int8List(9);

  int turn = human;
  int nextMacro = -1;
  int emptyCells = 81;
  bool isFinished = false;
  double value = 0.00001;
  int zobristKey = 0;

  final List<MoveRecord> history = [];

  GameState() {
    Zobrist.initialize();
    zobristKey = Zobrist.nextMacro[-1]!;
  }

  // Deep copy constructor for Isolate spawning
  GameState.clone(GameState other) {
    Zobrist.initialize();
    for (int i = 0; i < 81; i++) {
      board[i] = other.board[i];
    }
    for (int i = 0; i < 9; i++) {
      macroBoard[i] = other.macroBoard[i];
    }
    turn = other.turn;
    nextMacro = other.nextMacro;
    emptyCells = other.emptyCells;
    isFinished = other.isFinished;
    value = other.value;
    zobristKey = other.zobristKey;
  }

  List<int> getLegalMoves() {
    if (isFinished) return [];
    List<int> moves = [];
    int macroStart = nextMacro == -1 ? 0 : nextMacro;
    int macroEnd = nextMacro == -1 ? 9 : nextMacro + 1;

    for (int m = macroStart; m < macroEnd; m++) {
      if (macroBoard[m] == empty) {
        int startR = (m ~/ 3) * 3;
        int startC = (m % 3) * 3;
        for (int r = startR; r < startR + 3; r++) {
          for (int c = startC; c < startC + 3; c++) {
            int idx = r * 9 + c;
            if (board[idx] == empty) moves.add(idx);
          }
        }
      }
    }
    return moves;
  }

  void makeMove(int move) {
    int mIdx = (move ~/ 27) * 3 + (move % 9) ~/ 3;

    history.add(
      MoveRecord(
        move,
        nextMacro,
        macroBoard[mIdx],
        isFinished,
        value,
        zobristKey,
      ),
    );

    board[move] = turn;
    emptyCells--;
    zobristKey ^= Zobrist.board[move]![turn]!;

    int localResult = _evaluate3x3(board, mIdx);
    if (localResult != empty) {
      macroBoard[mIdx] = localResult;
      zobristKey ^= Zobrist.macro[mIdx]![localResult]!;

      int globalResult = _evaluateMacro();
      if (globalResult == computer) {
        isFinished = true;
        value = victory;
      } else if (globalResult == human) {
        isFinished = true;
        value = loss;
      } else if (emptyCells == 0 || globalResult == tieBoard) {
        isFinished = true;
        value = tie;
      }
    }

    zobristKey ^= Zobrist.nextMacro[nextMacro]!;
    int nextM = (move ~/ 9 % 3) * 3 + (move % 3);
    nextMacro = macroBoard[nextM] != empty ? -1 : nextM;
    zobristKey ^= Zobrist.nextMacro[nextMacro]!;

    if (!isFinished) value = _calculateHeuristic();

    turn = turn == human ? computer : human;
    zobristKey ^= Zobrist.turn;
  }

  void unmakeMove() {
    MoveRecord rec = history.removeLast();
    int mIdx = (rec.move ~/ 27) * 3 + (rec.move % 9) ~/ 3;

    turn = turn == human ? computer : human;
    board[rec.move] = empty;
    emptyCells++;
    macroBoard[mIdx] = rec.prevMacroVal;
    nextMacro = rec.prevNextMacro;
    isFinished = rec.prevFinished;
    value = rec.prevValue;
    zobristKey = rec.prevHash;
  }

  int _evaluate3x3(Int8List grid, int mIdx) {
    int startR = (mIdx ~/ 3) * 3, startC = (mIdx % 3) * 3;
    List<int> indices = List.generate(
      9,
      (i) => startR * 9 + startC + (i ~/ 3) * 9 + (i % 3),
    );

    for (var l in winLines) {
      if (grid[indices[l[0]]] != empty &&
          grid[indices[l[0]]] == grid[indices[l[1]]] &&
          grid[indices[l[1]]] == grid[indices[l[2]]]) {
        return grid[indices[l[0]]];
      }
    }
    return indices.every((i) => grid[i] != empty) ? tieBoard : empty;
  }

  int _evaluateMacro() {
    for (List<int> l in winLines) {
      if (macroBoard[l[0]] != empty &&
          macroBoard[l[0]] != tieBoard &&
          macroBoard[l[0]] == macroBoard[l[1]] &&
          macroBoard[l[1]] == macroBoard[l[2]]) {
        return macroBoard[l[0]];
      }
    }
    return macroBoard.every((m) => m != empty) ? tieBoard : empty;
  }

  double _calculateHeuristic() {
    double h = _scoreGrid(macroBoard, List.generate(9, (i) => i)) * 100;
    for (int m = 0; m < 9; m++) {
      if (macroBoard[m] == empty) {
        int startR = (m ~/ 3) * 3, startC = (m % 3) * 3;
        List<int> indices = List.generate(
          9,
          (i) => startR * 9 + startC + (i ~/ 3) * 9 + (i % 3),
        );
        h += _scoreGrid(board, indices);
      }
    }
    return h != 0 ? h : 0.00001;
  }

  double _scoreGrid(Int8List grid, List<int> indices) {
    double score = 0;
    for (var l in winLines) {
      int c1 = grid[indices[l[0]]],
          c2 = grid[indices[l[1]]],
          c3 = grid[indices[l[2]]];
      int comp =
          (c1 == computer ? 1 : 0) +
          (c2 == computer ? 1 : 0) +
          (c3 == computer ? 1 : 0);
      int hum =
          (c1 == human ? 1 : 0) + (c2 == human ? 1 : 0) + (c3 == human ? 1 : 0);
      int tie =
          (c1 == tieBoard ? 1 : 0) +
          (c2 == tieBoard ? 1 : 0) +
          (c3 == tieBoard ? 1 : 0);

      if (tie > 0 || (comp > 0 && hum > 0)) continue;
      if (comp == 3) {
        score += 1000;
      } else if (hum == 3) {
        score -= 1000;
      } else if (comp == 2) {
        score += 10;
      } else if (hum == 2) {
        score -= 10;
      } else if (comp == 1) {
        score += 1;
      } else if (hum == 1) {
        score -= 1;
      }
    }
    return score;
  }
}
