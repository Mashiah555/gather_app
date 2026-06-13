import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/engine/game_state.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/engine/search_engine.dart';

// Top-level function for the Isolate
int? _calculateAI(GameState stateClone) {
  final engine = SearchEngine(maxDepth: 6, timeout: const Duration(seconds: 4));
  return engine.getBestMove(stateClone);
}

class UltimateTicTacToeScreen extends StatefulWidget {
  const UltimateTicTacToeScreen({super.key});

  @override
  State<UltimateTicTacToeScreen> createState() =>
      _UltimateTicTacToeScreenState();
}

class _UltimateTicTacToeScreenState extends State<UltimateTicTacToeScreen> {
  final GameState _gameState = GameState();
  bool _isComputerThinking = false;

  void _handleTap(int index) async {
    if (_gameState.isFinished ||
        _isComputerThinking ||
        _gameState.turn == computer) {
      return;
    }
    if (!_gameState.getLegalMoves().contains(index)) return;

    setState(() {
      _gameState.makeMove(index);
    });

    if (!_gameState.isFinished) {
      _triggerAI();
    }
  }

  Future<void> _triggerAI() async {
    setState(() => _isComputerThinking = true);

    // Clone state so we safely pass primitive lists to the Isolate
    final clone = GameState.clone(_gameState);
    final bestMove = await compute(_calculateAI, clone);

    if (bestMove != null) {
      setState(() {
        _gameState.makeMove(bestMove);
        _isComputerThinking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24),
      appBar: AppBar(
        title: const Text(
          'Ultimate Tic-Tac-Toe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: 9,
                    itemBuilder: (context, macroIndex) =>
                        _buildMacroBoard(macroIndex),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    String statusText;
    if (_gameState.isFinished) {
      statusText = _gameState.value == victory
          ? "Computer Wins!"
          : _gameState.value == loss
          ? "You Win!"
          : "It's a Tie!";
    } else {
      statusText = _isComputerThinking
          ? "Computer is thinking..."
          : "Your Turn";
    }

    return Text(
      statusText,
      style: const TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMacroBoard(int macroIndex) {
    bool isActive =
        (_gameState.nextMacro == -1 || _gameState.nextMacro == macroIndex) &&
        !_gameState.isFinished;
    int macroStatus = _gameState.macroBoard[macroIndex];

    // Modern concave UI gradient wrapper
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isActive && macroStatus == empty
            ? const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: const Color(0xFF2B2B36),
        boxShadow: isActive
            ? [
                const BoxShadow(
                  color: Color(0x668E2DE2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.all(4),
      child: macroStatus != empty
          ? _buildMacroWinnerIndicator(macroStatus)
          : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, localIndex) {
                int globalRow = (macroIndex ~/ 3) * 3 + (localIndex ~/ 3);
                int globalCol = (macroIndex % 3) * 3 + (localIndex % 3);
                int globalIndex = globalRow * 9 + globalCol;
                return _buildCell(globalIndex, isActive);
              },
            ),
    );
  }

  Widget _buildCell(int globalIndex, bool isMacroActive) {
    int cellValue = _gameState.board[globalIndex];
    //bool isLegalMove = isMacroActive && cellValue == empty && !_isComputerThinking;

    return GestureDetector(
      onTap: () => _handleTap(globalIndex),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(
          child: Text(
            cellValue == computer
                ? 'X'
                : cellValue == human
                ? 'O'
                : '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cellValue == computer
                  ? Colors.redAccent
                  : Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroWinnerIndicator(int status) {
    return Center(
      child: Text(
        status == computer
            ? 'X'
            : status == human
            ? 'O'
            : '-',
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w900,
          color: status == computer
              ? Colors.redAccent.withAlpha(200)
              : status == human
              ? Colors.blueAccent.withAlpha(200)
              : Colors.grey,
        ),
      ),
    );
  }
}
