import 'package:flutter/material.dart';
import 'package:gather_app/core/widgets/line_painter.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/engine/game_state.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/engine/game_controller.dart';

class UltimateTicTacToeScreen extends StatefulWidget {
  final Map<String, dynamic> configs;
  const UltimateTicTacToeScreen({super.key, required this.configs});

  @override
  State<UltimateTicTacToeScreen> createState() =>
      _UltimateTicTacToeScreenState();
}

class _UltimateTicTacToeScreenState extends State<UltimateTicTacToeScreen> {
  late final UltimateTicTacToeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UltimateTicTacToeController(configs: widget.configs);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder rebuilds the UI automatically when notifyListeners() is called
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
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
                      // THE FIX: Stack bundles the grid and the painter in the same coordinate space
                      child: Stack(
                        children: [
                          GridView.builder(
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

                          if (_controller.winningLine != null)
                            Positioned.fill(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOut,
                                builder: (context, progress, child) {
                                  return CustomPaint(
                                    painter: LinePainter(
                                      linePoints: _controller.winningLine!,
                                      progress: progress,
                                      color:
                                          _controller.gameState.value == victory
                                          ? Colors.redAccent
                                          : Colors.blueAccent,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (_controller.gameState.isFinished) _buildEndGameActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader() {
    String statusText;
    if (_controller.gameState.isFinished) {
      statusText = _controller.gameState.value == victory
          ? "Computer Wins!"
          : _controller.gameState.value == loss
          ? "You Win!"
          : "It's a Tie!";
    } else if (_controller.isComputerThinking) {
      statusText = "Computer is thinking...";
    } else {
      statusText = _controller.humanMaxSeconds == -1
          ? "Your Turn"
          : "Your Turn - ${_controller.humanSecondsLeft}s";
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 24,
        color:
            _controller.humanSecondsLeft <= 5 &&
                _controller.humanMaxSeconds != -1 &&
                !_controller.isComputerThinking
            ? Colors.redAccent
            : Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMacroBoard(int macroIndex) {
    bool isActive =
        (_controller.gameState.nextMacro == -1 ||
            _controller.gameState.nextMacro == macroIndex) &&
        !_controller.gameState.isFinished;
    int macroStatus = _controller.gameState.macroBoard[macroIndex];

    LinearGradient activeGradient = _controller.isComputerThinking
        ? const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isActive && macroStatus == empty ? activeGradient : null,
        color: isActive && macroStatus == empty
            ? null
            : const Color(0xFF2B2B36),
        boxShadow: isActive && macroStatus == empty
            ? [
                BoxShadow(
                  color: _controller.isComputerThinking
                      ? Colors.redAccent.withAlpha(100)
                      : const Color(0x668E2DE2),
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
                int globalIndex =
                    (macroIndex ~/ 3) * 27 +
                    (macroIndex % 3) * 3 +
                    (localIndex ~/ 3) * 9 +
                    (localIndex % 3);
                return _buildCell(globalIndex, isActive);
              },
            ),
    );
  }

  Widget _buildCell(int globalIndex, bool isMacroActive) {
    int cellValue = _controller.gameState.board[globalIndex];

    Widget mark = Text(
      cellValue == computer
          ? 'X'
          : cellValue == human
          ? 'O'
          : '',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: cellValue == computer ? Colors.redAccent : Colors.blueAccent,
      ),
    );

    if (globalIndex == _controller.lastMoveIndex) {
      mark = TweenAnimationBuilder<double>(
        key: ValueKey(_controller.lastMoveIndex),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: mark,
      );
    }

    return GestureDetector(
      onTap: () => _controller.handleTap(globalIndex),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(child: mark),
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
              ? Colors.redAccent.withAlpha(205)
              : status == human
              ? Colors.blueAccent.withAlpha(205)
              : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEndGameActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(
            'PLAY AGAIN',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => _controller.initGame(),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            side: const BorderSide(color: Colors.white30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.menu_rounded),
          label: const Text('MENU'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
