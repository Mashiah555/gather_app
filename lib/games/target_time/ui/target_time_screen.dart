import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gather_app/games/target_time/engine/target_time_controller.dart';
import 'package:gather_app/games/target_time/ui/target_time_result_screen.dart';

class TargetTimeScreen extends StatefulWidget {
  final Map<String, dynamic> configs;
  const TargetTimeScreen({super.key, required this.configs});

  @override
  State<TargetTimeScreen> createState() => _TargetTimeScreenState();
}

class _TargetTimeScreenState extends State<TargetTimeScreen> {
  late final TargetTimeController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TargetTimeController(
      configs: widget.configs,
      onGameFinished: _handleGameFinished,
    );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleGameFinished() async {
    final bool? playAgain = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TargetTimeResultScreen(
              targetTime: _controller.targetTime,
              players: _controller.players,
              winners: _controller.winners,
              onPlayAgain: () => Navigator.pop(context, true),
              onMenu: () => Navigator.pop(context, false),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (playAgain == true) {
      _controller.restart();
      _focusNode.requestFocus();
    } else if (playAgain == false) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (_controller.phase == GamePhase.preparation &&
          event.logicalKey == LogicalKeyboardKey.space) {
        _controller.startCountdown();
      } else if (_controller.phase == GamePhase.active) {
        final keyPressed = event.logicalKey.keyLabel.toUpperCase();
        for (var player in _controller.players) {
          if (player.keybind == keyPressed) {
            _controller.playerTap(player.id);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _handleKeyEvent,
          child: Scaffold(
            backgroundColor: const Color(0xFF12121A),
            body: SafeArea(
              child: Column(
                children: [
                  // Top Dashboard
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24.0,
                      horizontal: 16.0,
                    ),
                    child: _buildCenterHUD(),
                  ),

                  // Responsive Player Grid
                  Expanded(child: _buildPlayerZones()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerZones() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent:
            250, // Ensures elegant sizing on both mobile and desktop
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // Tailored aspect ratio for the card data
      ),
      itemCount: _controller.players.length,
      itemBuilder: (context, index) {
        final player = _controller.players[index];
        return GestureDetector(
          onTapDown: (_) => _controller.playerTap(player.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: player.hasStopped
                  ? player.themeColor.withOpacity(0.15)
                  : const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: player.hasStopped ? player.themeColor : Colors.white10,
                width: player.hasStopped ? 4 : 2,
              ),
              boxShadow: player.hasStopped
                  ? [
                      BoxShadow(
                        color: player.themeColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: _buildPlayerContent(player),
          ),
        );
      },
    );
  }

  Widget _buildPlayerContent(PlayerState player) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'P${player.id}',
          style: TextStyle(
            color: player.themeColor,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'KEY: ${player.keybind}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (player.hasStopped) ...[
          Icon(Icons.lock_rounded, color: player.themeColor, size: 36),
          const SizedBox(height: 8),
          Text(
            'LOCKED',
            style: TextStyle(
              color: player.themeColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCenterHUD() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24).withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.white12, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TARGET TIME',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formatTargetTime(_controller.targetTime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12, thickness: 2),
          ),
          _buildDynamicClock(),
        ],
      ),
    );
  }

  Widget _buildDynamicClock() {
    if (_controller.phase == GamePhase.preparation) {
      return Column(
        children: [
          const Text(
            'MEMORIZE TARGET',
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'START (SPACE)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            onPressed: () => _controller.startCountdown(),
          ),
        ],
      );
    }

    if (_controller.phase == GamePhase.countdown) {
      return Text(
        '${_controller.countdownNumber}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    if (!_controller.isCounterVisible &&
        _controller.phase == GamePhase.active) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_off_rounded, color: Colors.redAccent),
          SizedBox(width: 8),
          Text(
            'HIDDEN',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      );
    }

    return Text(
      formatTargetTime(_controller.currentTime),
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 40,
        fontWeight: FontWeight.w900,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
