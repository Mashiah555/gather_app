import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/core/models/game_models.dart';
import 'package:gather_app/games/crocodile_roulette/views/crocodile_roulette_screen.dart';
import 'package:gather_app/games/narrow_down/ui/setup_screen.dart';
import 'package:gather_app/games/simon_says/views/simon_says_screen.dart';
import 'package:gather_app/games/target_time/ui/target_time_screen.dart';
import 'package:gather_app/games/ultimate_tic_tac_toe/ui/ultimate_tic_tac_toe_screen.dart';

final gameRepositoryProvider = Provider<List<GameItem>>((ref) {
  return [
    GameItem(
      id: 'ultimate_tic_tac_toe',
      titleBuilder: (l10n) => l10n.ultimateTicTacToe,
      subtitleBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'לוחמת משבצות אסטרטגית',
        _ => 'Strategic grid warfare',
      },
      descriptionBuilder: (l10n) => switch (l10n.localeName) {
        'he' =>
          'גרסה מורחבת של משחק איקס-עיגול קלאסי שבה כל תור קובע היכן היריב יוכל לשחק את התור הבא שלו',
        _ =>
          'A deeply strategic variant of classic Tic-Tac-Toe where every move dictates where your opponent can play next.',
      },
      rulesBuilder: (l10n) => switch (l10n.localeName) {
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
          titleBuilder: (l10n) => switch (l10n.localeName) {
            'he' => 'רמת הקושי (עד כמה ה-AI חכם)',
            _ => 'Difficulty Level (How smart is the AI)',
          },
          min: 0,
          max: 8,
          divisions: 8,
          defaultValue: 5,
        ),
        DropdownConfig(
          key: 'time_limit',
          titleBuilder: (l10n) => switch (l10n.localeName) {
            'he' => 'זמן מקסימלי לתור',
            _ => 'Max Time Per Turn',
          },
          optionsBuilder: (l10n) => switch (l10n.localeName) {
            'he' => ['10 שניות', '30 שניות', '60 שניות', 'ללא הגבלה'],
            _ => ['10 seconds', '30 seconds', '60 seconds', 'Unlimited'],
          },
          defaultValueBuilder: (l10n) => switch (l10n.localeName) {
            'he' => '30 שניות',
            _ => '30 seconds',
          },
        ),
      ],
      gameBuilder: (configs) => UltimateTicTacToeScreen(configs: configs),
    ),
    GameItem(
      id: 'narrow_down',
      titleBuilder: (l10n) => l10n.narrowDown,
      subtitleBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'משחק מחשבה חברתי',
        _ => 'Social logic board game',
      },
      descriptionBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'משחק קבוצות תחרותי שבו הקבוצה צריכה לנחש תשובה לשאלה חלקית.',
        _ =>
          'A competitive group based game, where each group has to guess the answer to a partial question.',
      },
      rulesBuilder: (l10n) => switch (l10n.localeName) {
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
      id: 'target_time',
      titleBuilder: (l10n) => l10n.targetTime,
      subtitleBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'מבחן של דיוק',
        _ => 'A test of time precision',
      },
      descriptionBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'בזמן מטרה, השחקן הכי דייקן ינצח את השעון.',
        _ => 'In Target Time, the most precise players beats the clock.',
      },
      rulesBuilder: (l10n) => switch (l10n.localeName) {
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
          titleBuilder: (l10n) => switch (l10n.localeName) {
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
          titleBuilder: (l10n) => switch (l10n.localeName) {
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
      id: 'crocodile_roulette',
      titleBuilder: (l10n) => l10n.crocodileRoulette,
      subtitleBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'להחליט',
        _ => 'TBD',
      },
      descriptionBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'משחק הישרדות מבוסס מזל.',
        _ => 'A survival luck-based game.',
      },
      rulesBuilder: (l10n) => switch (l10n.localeName) {
        'he' =>
          '1. כל שחקן בתורו בוחר שן תנין.\n2. אם תיבחרו את השן הלא נכונה, התנין יאכל אתכם!\n3. השחקן האחרון ששורד - מנצח.',
        _ =>
          '1. Each player chooses a crocodile tooth at their turn.\n2. If you choose the wrong tooth, you will be eaten by the crocodile!\n3. The last player to survive - wins.',
      },
      icon: Icons.pets_rounded,
      gradient: const [
        Color.fromARGB(255, 20, 42, 52),
        Color(0xFF203A43),
        Color(0xFF2C5364),
      ],
      configs: [
        SliderConfig(
          key: 'players',
          titleBuilder: (l10n) => 'Number of Players',
          min: 2,
          max: 6,
          divisions: 4,
          defaultValue: 2,
        ),
        SliderConfig(
          key: 'tooth_count',
          titleBuilder: (l10n) => 'Amount of Teeth (Difficulty)',
          min: 8,
          max: 16,
          divisions: 8,
          defaultValue: 12,
        ),
      ],
      gameBuilder: (configs) => CrocodileRouletteScreen(configs: configs),
    ),
    GameItem(
      id: 'simon_says',
      titleBuilder: (l10n) => l10n.simonSays,
      subtitleBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'משחק של מיקוד וקשב',
        _ => 'A game of focus and attention',
      },
      descriptionBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'עקבו אחר האורות הזוהרים וחזרו על הסדר המדויק.',
        _ => 'Follow the glowing lights and repeat the exact sequence.',
      },
      rulesBuilder: (l10n) => switch (l10n.localeName) {
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
          key: 'speed',
          titleBuilder: (l10n) => switch (l10n.localeName) {
            'he' => 'מהירות',
            _ => 'Playback Speed',
          },
          min: 1,
          max: 8,
          divisions: 7,
          defaultValue: 5,
        ),
        SwitchConfig(
          key: 'strict_mode',
          titleBuilder: (l10n) => switch (l10n.localeName) {
            'he' => 'מצב קשוח',
            _ => 'Strict Mode',
          },
          defaultValue: true,
        ),
        SliderConfig(
          key: 'color_count',
          titleBuilder: (l10n) => switch (l10n.localeName) {
            'he' => 'מספר הצבעים',
            _ => 'Colors Amount',
          },
          min: 2,
          max: 6,
          divisions: 4,
          defaultValue: 4,
        ),
        SliderConfig(
          key: 'starting_difficulty',
          titleBuilder: (l10n) => switch (l10n.localeName) {
            'he' => 'דרגת קושי התחלתית',
            _ => 'Starting Difficulty',
          },
          min: 1,
          max: 5,
          divisions: 4,
          defaultValue: 1,
        ),
      ],
      gameBuilder: (configs) => SimonSaysScreen(configs: configs),
    ),
    GameItem(
      id: 'the_road_to_ceo',
      titleBuilder: (l10n) => l10n.theRoadToCeo,
      subtitleBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'הכנה לעולם התעסוקה',
        _ => 'Preparation for Employment',
      },
      descriptionBuilder: (l10n) => switch (l10n.localeName) {
        'he' =>
          'משחק חשיבה קבוצתי שמשפר את מיומנויות התעסוקה עם סיטואציות מציאותיות מעולם העבודה.',
        _ =>
          'A social thinking game that improves the employment skills using realistic scenarios from the work world.',
      },
      rulesBuilder: (l10n) => switch (l10n.localeName) {
        'he' => 'פתחו את המשחק בדפדפן.',
        _ => 'Open the game in the browser.',
      },
      icon: Icons.work_rounded,
      gradient: const [
        Color.fromARGB(255, 17, 49, 153),
        Color.fromARGB(255, 56, 157, 239),
      ],
      externalUrl: 'https://the-road-to-ceo.web.app/',
    ),
  ];
});
