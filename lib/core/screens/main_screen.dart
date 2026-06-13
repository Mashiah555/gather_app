import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/core/models/game_item.dart';
import 'package:gather_app/core/screens/settings_screen.dart';
import 'package:gather_app/core/widgets/game_card.dart';
import 'package:gather_app/games/narrow_down/ui/setup_screen.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/ui/ultimate_tic_tac_toe_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // The game catalog
  final List<GameItem> _games = [
    GameItem(
      title: 'Ultimate Tic-Tac-Toe',
      subtitle: 'Strategic grid warfare',
      icon: Icons.grid_4x4_rounded,
      gradient: const [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
      destination: const UltimateTicTacToeScreen(),
    ),
    GameItem(
      title: 'The Road to CEO',
      subtitle: 'Corporate simulation & strategy',
      icon: Icons.business_center_rounded,
      gradient: const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      destination: const Placeholder(),
    ),
    GameItem(
      title: 'Narrow Down',
      subtitle: 'Social logic board game',
      icon: Icons.batch_prediction_rounded,
      gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      destination: const ProviderScope(child: SetupScreen()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(theme),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      400, // Adapts nicely between Web/Desktop and Mobile
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio:
                      1.2, // Gives the cards a nice wide landscape feel
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GameCard(game: _games[index]),
                  childCount: _games.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 32.0, 16.0, 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gather App',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a game to play',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded, size: 28),
              splashRadius: 24,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
