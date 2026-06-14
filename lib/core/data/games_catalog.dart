import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/core/models/game_models.dart';
import 'package:gather_app/games/narrow_down/ui/setup_screen.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/ui/ultimate_tic_tac_toe_screen.dart';

final List<GameItem> gamesCatalog = [
  GameItem(
    title: 'Ultimate Tic-Tac-Toe',
    subtitle: 'Strategic grid warfare',
    description:
        'A deeply strategic variant of classic Tic-Tac-Toe where every move dictates where your opponent can play next.',
    rules:
        '1. The board is a 9x9 grid divided into 9 local 3x3 boards.\n2. Winning a local board claims it for the macro-board.\n3. Your move coordinates determine which local board your opponent must play in next.\n4. Win 3 local boards in a row to win the game.',
    icon: Icons.grid_4x4_rounded,
    gradient: const [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
    configs: [
      SliderConfig(
        key: 'ai_depth',
        title: 'AI Difficulty (Search Depth)',
        min: 0,
        max: 9,
        divisions: 9,
        defaultValue: 6,
      ),
      DropdownConfig(
        key: 'time_limit',
        title: 'Max Time Per Turn',
        options: ['10 seconds', '30 seconds', '60 seconds', 'Unlimited'],
        defaultValue: '30 seconds',
      ),
    ],
    gameBuilder: (configs) => UltimateTicTacToeScreen(configs: configs),
  ),
  GameItem(
    title: 'The Road to CEO',
    subtitle: 'Corporate simulation & strategy',
    description:
        'A deeply strategic variant of classic Tic-Tac-Toe where every move dictates where your opponent can play next.',
    rules:
        '1. The board is a 9x9 grid divided into 9 local 3x3 boards.\n2. Winning a local board claims it for the macro-board.\n3. Your move coordinates determine which local board your opponent must play in next.\n4. Win 3 local boards in a row to win the game.',
    icon: Icons.business_center_rounded,
    gradient: const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    configs: [
      SliderConfig(
        key: 'ai_depth',
        title: 'AI Search Depth (Difficulty)',
        min: 1,
        max: 8,
        divisions: 7,
        defaultValue: 6,
      ),
      DropdownConfig(
        key: 'time_limit',
        title: 'Max Time Per Turn',
        options: ['3 seconds', '5 seconds', '10 seconds', 'Unlimited'],
        defaultValue: '5 seconds',
      ),
    ],
    gameBuilder: (configs) => UltimateTicTacToeScreen(configs: configs),
  ),
  GameItem(
    title: 'Narrow Down',
    subtitle: 'Social logic board game',
    description:
        'A deeply strategic variant of classic Tic-Tac-Toe where every move dictates where your opponent can play next.',
    rules:
        '1. The board is a 9x9 grid divided into 9 local 3x3 boards.\n2. Winning a local board claims it for the macro-board.\n3. Your move coordinates determine which local board your opponent must play in next.\n4. Win 3 local boards in a row to win the game.',
    icon: Icons.batch_prediction_rounded,
    gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    configs: [
      SliderConfig(
        key: 'ai_depth',
        title: 'AI Search Depth (Difficulty)',
        min: 1,
        max: 8,
        divisions: 7,
        defaultValue: 6,
      ),
      DropdownConfig(
        key: 'time_limit',
        title: 'Max Time Per Turn',
        options: ['3 seconds', '5 seconds', '10 seconds', 'Unlimited'],
        defaultValue: '5 seconds',
      ),
    ],
    gameBuilder: (configs) => ProviderScope(
      child: SetupScreen(configs: configs),
    ), // Pass configs to your game
  ),
];
