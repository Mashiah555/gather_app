import 'package:flutter/material.dart';
import 'package:gather_app/games/crocodile_roulette/engine/crocodile_roulette_controller.dart';

class CrocodileRouletteScreen extends StatefulWidget {
  final Map<String, dynamic> configs;
  const CrocodileRouletteScreen({super.key, required this.configs});

  @override
  State<CrocodileRouletteScreen> createState() =>
      _CrocodileRouletteScreenState();
}

class _CrocodileRouletteScreenState extends State<CrocodileRouletteScreen> {
  late final CrocodileRouletteController _controller;

  // A vibrant palette to distinguish whose turn it is
  final List<Color> _playerColors = [
    const Color(0xFF00C9FF), // P1: Cyan
    const Color(0xFFFF416C), // P2: Rose
    const Color(0xFFFFB75E), // P3: Amber
    const Color(0xFF8E2DE2), // P4: Purple
    const Color(0xFF11998E), // P5: Mint
    const Color(0xFFFFD700), // P6: Gold
  ];

  @override
  void initState() {
    super.initState();
    _controller = CrocodileRouletteController(configs: widget.configs);
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
        final isChomp = _controller.phase == CrocPhase.chomp;

        return Scaffold(
          // Flash the background red if the crocodile bites
          backgroundColor: isChomp
              ? const Color(0xFF3E0000)
              : const Color(0xFF12121A),
          appBar: AppBar(
            title: const Text(
              'Crocodile Roulette',
              style: TextStyle(fontWeight: FontWeight.w900),
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
                    _buildTurnIndicator(),
                    Expanded(
                      child: Center(child: _buildCrocodileMouth(isChomp)),
                    ),
                  ],
                ),
                if (isChomp) _buildGameOverOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurnIndicator() {
    final playerColor =
        _playerColors[(_controller.currentPlayer - 1) % _playerColors.length];
    final isChomp = _controller.phase == CrocPhase.chomp;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: isChomp
              ? Colors.redAccent.withAlpha(50)
              : playerColor.withAlpha(25),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isChomp ? Colors.redAccent : playerColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isChomp
                  ? Colors.redAccent.withAlpha(75)
                  : playerColor.withAlpha(50),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          isChomp
              ? 'PLAYER ${_controller.losingPlayer} BITTEN!'
              : "PLAYER ${_controller.currentPlayer}'S TURN",
          style: TextStyle(
            color: isChomp ? Colors.redAccent : playerColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCrocodileMouth(bool isChomp) {
    int topCount = _controller.teethCount ~/ 2;
    int bottomCount = _controller.teethCount - topCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20), // Dark green crocodile skin
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(150),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upper Jaw
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align to top gums
                children: List.generate(
                  topCount,
                  (i) => Expanded(child: _buildTooth(i, isTop: true)),
                ),
              ),
            ),

            // The Dark Mouth Cavity (Animates to 0 height on CHOMP)
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInExpo, // Snappy close
              height: isChomp ? 0 : 120, // <-- The core biting mechanic
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(220),
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            // Lower Jaw
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align to bottom gums
                children: List.generate(
                  bottomCount,
                  (i) =>
                      Expanded(child: _buildTooth(topCount + i, isTop: false)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooth(int index, {required bool isTop}) {
    bool isPressed = _controller.pressedTeeth[index];
    bool isBadTooth =
        _controller.phase == CrocPhase.chomp &&
        _controller.badToothIndex == index;

    return GestureDetector(
      onTapDown: (_) => _controller.pressTooth(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        // If pressed, the tooth's height shrinks, making it look pushed into the gums
        height: isPressed ? 20 : 60,
        decoration: BoxDecoration(
          color: isBadTooth
              ? Colors.redAccent
              : isPressed
              ? const Color(0xFFBDBDBD) // Greyish white
              : Colors.white,
          borderRadius: isTop
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(75),
                    blurRadius: 4,
                    offset: Offset(0, isTop ? 2 : -2),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final playerColor =
        _playerColors[(_controller.losingPlayer! - 1) % _playerColors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        // Using scaleByDouble instead of the deprecated scale
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scaleByDouble(value, value, value, 1.0),
          child: child,
        );
      },
      child: Container(
        color: Colors.black.withAlpha(200),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, color: playerColor, size: 80),
              const SizedBox(height: 16),
              Text(
                'CHOMP!',
                style: TextStyle(
                  color: playerColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'YOU PRESSED THE TRAP TOOTH',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
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
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _controller.restart(),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
