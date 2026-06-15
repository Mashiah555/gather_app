import 'package:flutter/material.dart';
import 'package:gather_app/games/target_time/engine/target_time_controller.dart';

class TargetTimeResultScreen extends StatelessWidget {
  final double targetTime;
  final List<PlayerState> players;
  final List<PlayerState> winners;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  const TargetTimeResultScreen({
    super.key,
    required this.targetTime,
    required this.players,
    required this.winners,
    required this.onPlayAgain,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    String winnerText = winners.length > 1
        ? "IT'S A TIE!"
        : "PLAYER ${winners.first.id} WINS!";

    // Sort players by closest to target time
    final sortedPlayers = List<PlayerState>.from(players)
      ..sort(
        (a, b) => (a.stoppedTime! - targetTime).abs().compareTo(
          (b.stoppedTime! - targetTime).abs(),
        ),
      );

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'TARGET TIME',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatTargetTime(targetTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 32),

              // Winner Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: winners.first.themeColor,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: winners.first.themeColor.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  winnerText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Player Breakdown List
              Expanded(
                child: ListView.builder(
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final p = sortedPlayers[index];
                    final isWinner = winners.contains(p);
                    final diff = p.stoppedTime! - targetTime;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isWinner ? p.themeColor : Colors.white12,
                          width: isWinner ? 3 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: p.themeColor,
                                radius: 24,
                                child: Text(
                                  'P${p.id}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'STOPPED AT',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    formatTargetTime(p.stoppedTime!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'DIFFERENCE',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                '${diff > 0 ? "+" : ""}${formatTargetTime(diff)}s',
                                style: TextStyle(
                                  color: isWinner
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Action Buttons
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
                    onPressed: onPlayAgain,
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
                    onPressed: onMenu,
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
