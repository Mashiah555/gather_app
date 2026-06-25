import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gather_app/games/simon_says/engine/simon_says_controller.dart';

class SimonSaysScreen extends StatefulWidget {
  final Map<String, dynamic> configs;
  const SimonSaysScreen({super.key, required this.configs});

  @override
  State<SimonSaysScreen> createState() => _SimonSaysScreenState();
}

class _SimonSaysScreenState extends State<SimonSaysScreen> {
  late final SimonSaysController _controller;

  final List<Color> _padColors = [
    const Color(0xFFFF416C), // 0: Rose Red
    const Color(0xFF00C9FF), // 1: Cyan
    const Color(0xFF8E2DE2), // 2: Purple
    const Color(0xFFFFB75E), // 3: Amber
    const Color(0xFF11998E), // 4: Mint Green
    const Color(0xFFFFD700), // 5: Neon Gold
  ];

  @override
  void initState() {
    super.initState();
    _controller = SimonSaysController(configs: widget.configs);
    Future.delayed(const Duration(milliseconds: 500), _controller.startGame);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF12121A),
          appBar: AppBar(
            title: const Text(
              'Simon Says',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildScoreBoard(),
                    // The Expanded area hands its exact dimensions to the LayoutBuilder
                    Expanded(child: _buildGameGrid()),
                    _buildStatusText(),
                  ],
                ),
                if (_controller.phase == SimonPhase.gameOver)
                  _buildGameOverOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white12, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(75),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Text(
              'SCORE: ${_controller.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameGrid() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int count = _controller.colorCount;

          // Determine optimal columns: 2 columns for 2-4 pads, 3 columns for 5-6 pads
          int columns = count <= 4 ? 2 : 3;
          int rows = (count / columns).ceil();

          // Account for the spacing (16px) between the pads
          double hSpace = (columns - 1) * 16.0;
          double vSpace = (rows - 1) * 16.0;

          // Calculate the absolute maximum width and height a single pad can take
          double maxPadWidth = (constraints.maxWidth - hSpace) / columns;
          double maxPadHeight = (constraints.maxHeight - vSpace) / rows;

          // Force the pads to be perfectly square by taking the smallest limiting dimension
          double padSize = min(maxPadWidth, maxPadHeight);

          return Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: List.generate(count, (index) {
                return SizedBox(
                  width: padSize,
                  height: padSize,
                  child: _buildPad(index),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPad(int index) {
    final bool isActive = _controller.activePad == index;
    final Color baseColor = _padColors[index % _padColors.length];
    final double scale = isActive ? 0.95 : 1.0;

    return GestureDetector(
      onTapDown: (_) => _controller.handlePadTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scaleByDouble(scale, scale, scale, 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? baseColor : baseColor.withAlpha(75),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isActive ? Colors.white : baseColor.withAlpha(128),
            width: isActive ? 4 : 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: baseColor.withAlpha(205),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    String status = '';
    Color color = Colors.white54;

    switch (_controller.phase) {
      case SimonPhase.idle:
        status = 'GET READY...';
        color = Colors.amberAccent;
        break;
      case SimonPhase.playingSequence:
        status = 'WATCH CLOSELY';
        color = Colors.cyanAccent;
        break;
      case SimonPhase.waitingForInput:
        status = 'YOUR TURN';
        color = Colors.greenAccent;
        break;
      case SimonPhase.gameOver:
        status = 'GAME OVER';
        color = Colors.redAccent;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withAlpha(205),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SEQUENCE FAILED',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'FINAL SCORE: ${_controller.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'TRY AGAIN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _controller.startGame(),
                ),
                const SizedBox(width: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    side: const BorderSide(color: Colors.white30, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.menu_rounded),
                  label: const Text(
                    'MENU',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
