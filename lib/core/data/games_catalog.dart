import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/core/models/game_models.dart';
import 'package:gather_app/games/narrow_down/ui/setup_screen.dart';
import 'package:gather_app/games/target_time/ui/target_time_screen.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/ui/ultimate_tic_tac_toe_screen.dart';
import 'package:gather_app/l10n/generated/l10n.dart';

List<GameItem> getGamesCatalog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final lang = l10n.localeName;

  return [
    GameItem(
      title: l10n.ultimateTicTacToe,
      subtitle: switch (lang) {
        'he' => 'לוחמת משבצות אסטרטגית',
        _ => 'Strategic grid warfare',
      },
      description: switch (lang) {
        'he' =>
          'גרסה מורחבת של משחק איקס-עיגול קלאסי שבה כל תור קובע היכן היריב יוכל לשחק את התור הבא שלו',
        _ =>
          'A deeply strategic variant of classic Tic-Tac-Toe where every move dictates where your opponent can play next.',
      },
      rules: switch (lang) {
        'he' =>
          '1. הלוח מורכב מרשת של 9 על 9 משבצות שמחולק ללוחות בסיסיים של 3 על 3 משבצות.\n2. ניצחון בלוח בסיסי מהווה משבצת יחידה בלוח המורחב.\n3.מיקום המשבצת שבה שיחקת קובעת באיזה לוח בסיסי היריב שלך מחויב לשחק בתור הבא.\n4. המשחק נגמר כאשר שחקן מנצח בטור של 3 לוחות.',
        _ =>
          '1. The board is a 9x9 grid divided into 9 local 3x3 boards.\n2. Winning a local board claims it for the macro-board.\n3. Your move coordinates determine which local board your opponent must play in next.\n4. Win 3 local boards in a row to win the game.',
      },
      icon: Icons.grid_4x4_rounded,
      gradient: const [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
      configs: [
        SliderConfig(
          key: 'ai_depth',
          title: switch (lang) {
            'he' => 'רמת הקושי (עד כמה ה-AI חכם)',
            _ => 'Difficulty Level (How smart is the AI)',
          },
          min: 0,
          max: 8,
          divisions: 8,
          defaultValue: 6,
        ),
        DropdownConfig(
          key: 'time_limit',
          title: switch (lang) {
            'he' => 'זמן מקסימלי לתור',
            _ => 'Max Time Per Turn',
          },
          options: switch (lang) {
            'he' => ['10 שניות', '30 שניות', '60 שניות', 'ללא הגבלה'],
            _ => ['10 seconds', '30 seconds', '60 seconds', 'Unlimited'],
          },
          defaultValue: switch (lang) {
            'he' => '30 שניות',
            _ => '30 seconds',
          },
        ),
      ],
      gameBuilder: (configs) => UltimateTicTacToeScreen(configs: configs),
    ),
    GameItem(
      title: l10n.narrowDown,
      subtitle: switch (lang) {
        'he' => 'משחק מחשבה חברתי',
        _ => 'Social logic board game',
      },
      description: switch (lang) {
        'he' => 'משחק קבוצות תחרותי שבו הקבוצה צריכה לנחש תשובה לשאלה חלקית.',
        _ =>
          'A competitive group based game, where each group has to guess the answer to a partial question.',
      },
      rules: switch (lang) {
        'he' => '',
        _ => '',
      },
      icon: Icons.batch_prediction_rounded,
      gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      configs: [],
      gameBuilder: (configs) => ProviderScope(
        child: SetupScreen(configs: configs),
      ), // Pass configs to your game
    ),
    GameItem(
      title: l10n.crocodileRoulette,
      subtitle: switch (lang) {
        'he' => 'להחליט',
        _ => 'TBD',
      },
      description: switch (lang) {
        'he' => 'משחק הישרדות מבוסס מזל.',
        _ => 'A survival luck-based game.',
      },
      rules: switch (lang) {
        'he' =>
          '1. כל שחקן בתורו בוחר שן תנין.\n2. אם תיבחרו את השן הלא נכונה, התנין יאכל אתכם!\n3. השחקן האחרון ששורד - מנצח.',
        _ =>
          '1. Each player chooses a crocodile tooth at their turn.\n2. If you choose the wrong tooth, you will be eaten by the crocodile!\n3. The last player to survive - wins.',
      },
      icon: Icons.pets_rounded,
      gradient: const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      configs: [],
      gameBuilder: (configs) => UltimateTicTacToeScreen(configs: configs),
    ),
    GameItem(
      title: l10n.targetTime,
      subtitle: switch (lang) {
        'he' => 'מבחן של דיוק',
        _ => 'A test of time precision',
      },
      description: switch (lang) {
        'he' => 'בזמן מטרה, השחקן הכי דייקן ינצח את השעון.',
        _ => 'In Target Time, the most precise players beats the clock.',
      },
      rules: switch (lang) {
        'he' =>
          '1. המשחק מתחיל עם זמן מטרה ספציפי.\n2. השעון מסתיר את הזמן האמיתי\n3. השחקן שעצר את השעון בזמן שקרוב ביותר לזמן המטרה - מנצח!',
        _ =>
          '1. The game starts with a specific goal time to get.\n2. The clock hides the true time.\n 3. The player that stoped the clock closest to the target time - wins!',
      },
      icon: Icons.access_alarm_rounded,
      gradient: const [Color(0xDD00C9FF), Color(0xBB92FEAD)],
      configs: [
        SliderConfig(
          key: 'players',
          title: switch (l10n.localeName) {
            'he' => 'מספר השחקנים',
            _ => 'Number of Players',
          },
          min: 1,
          max: 6,
          divisions: 5,
          defaultValue: 2,
        ),
        SliderConfig(
          key: 'time_limit',
          title: switch (l10n.localeName) {
            'he' => 'הגבלת זמן (שניות)',
            _ => 'Time Limit (seconds)',
          },
          min: 6,
          max: 20,
          divisions: 7,
          defaultValue: 12,
        ),
      ],
      gameBuilder: (configs) => TargetTimeScreen(configs: configs),
    ),
    GameItem(
      title: l10n.simonSays,
      subtitle: switch (lang) {
        'he' => 'משחק של מיקוד וקשב',
        _ => 'A game of focus and attention',
      },
      description: switch (lang) {
        'he' => 'עקבו אחר האורות הזוהרים וחזרו על הסדר המדויק.',
        _ => 'Follow the glowing lights and repeat the exact sequence.',
      },
      rules: switch (lang) {
        'he' =>
          '1. המשחק ידליק אורות בסדר ספציפי\n2. עליכם לחזור על האורות בסדר המדויק שבו נדלקו.\n3. המשחק יעשה קשה יותר בכל פעם - תשרדו כמה שיותר!',
        _ =>
          '1. The game will light up colors in a specific sequence.\n2. You have to repeat the colors in the exact order they were lit up.\n3. The game will get harder each time - survive for as long as you can!',
      },
      icon: Icons.traffic_rounded,
      gradient: const [
        Color.fromARGB(255, 23, 137, 63),
        Color.fromARGB(255, 0, 224, 0),
      ],
      configs: [
        SliderConfig(
          key: 'start_difficuly',
          title: switch (lang) {
            'he' => 'דרגת קושי התחלתית',
            _ => 'Starting Difficulty',
          },
          min: 1,
          max: 8,
          divisions: 7,
          defaultValue: 2,
        ),
        DropdownConfig(
          key: 'colors_amount',
          title: switch (lang) {
            'he' => 'מספר הצבעים',
            _ => 'Colors Amount',
          },
          options: switch (l10n.localeName) {
            'he' => ['4 צבעים', '6 צבעים', '8 צבעים'],
            _ => ['4 colors', '6 colors', '8 colors'],
          },
          defaultValue: '6 colors',
        ),
      ],
      gameBuilder: (configs) => UltimateTicTacToeScreen(configs: configs),
    ),
  ];
}
