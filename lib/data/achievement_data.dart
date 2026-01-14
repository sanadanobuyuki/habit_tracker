import 'package:sqflite/sqflite.dart';

/// 初期実績データのリスト
final List<Map<String, dynamic>> initialAchievements = [
  // ========== 習慣作成系 ==========
  {
    'id': 'ach_first_habit',
    'name': '初めての一歩',
    'description': '初めて習慣を作成した',
    'condition_type': 'habit_count',
    'condition_value': 1,
    'rarity': null,
    'theme_id': 'dark',
  },
  {
    'id': 'ach_habit_5',
    'name': '習慣コレクター',
    'description': '5個の習慣を作成した',
    'condition_type': 'habit_count',
    'condition_value': 5,
    'rarity': null,
    'theme_id': 'green',
  },
  {
    'id': 'ach_habit_10',
    'name': '習慣マスター',
    'description': '10個の習慣を作成した',
    'condition_type': 'habit_count',
    'condition_value': 10,
    'rarity': null,
    'theme_id': 'dark_checkered',
  },

  // ========== 累計達成日数系 ==========
  {
    'id': 'ach_first_day',
    'name': '初日達成',
    'description': '初めてすべての習慣を達成した',
    'condition_type': 'total_days',
    'condition_value': 1,
    'rarity': null,
    'theme_id': 'blue',
  },
  {
    'id': 'ach_total_7',
    'name': '1週間の成果',
    'description': '累計7日すべての習慣を達成した',
    'condition_type': 'total_days',
    'condition_value': 7,
    'rarity': null,
    'theme_id': 'pink',
  },
  {
    'id': 'ach_total_30',
    'name': '1ヶ月の積み重ね',
    'description': '累計30日すべての習慣を達成した',
    'condition_type': 'total_days',
    'condition_value': 30,
    'rarity': null,
    'theme_id': 'blue_checkered',
  },
  {
    'id': 'ach_total_100',
    'name': '百日修行',
    'description': '累計100日すべての習慣を達成した',
    'condition_type': 'total_days',
    'condition_value': 100,
    'rarity': null,
    'theme_id': 'pink_dotted',
  },

  // ========== 連続達成日数系 ==========
  {
    'id': 'ach_streak_3',
    'name': '三日坊主克服',
    'description': '3日連続ですべての習慣を達成した',
    'condition_type': 'streak',
    'condition_value': 3,
    'rarity': null,
    'theme_id': 'red',
  },
  {
    'id': 'ach_streak_7',
    'name': '継続の達人',
    'description': '7日連続ですべての習慣を達成した',
    'condition_type': 'streak',
    'condition_value': 7,
    'rarity': null,
    'theme_id': 'green_striped',
  },
  {
    'id': 'ach_streak_30',
    'name': '習慣の鬼',
    'description': '30日連続ですべての習慣を達成した',
    'condition_type': 'streak',
    'condition_value': 30,
    'rarity': null,
    'theme_id': 'gradient_sunset',
  },
];

/// 実績データをデータベースに登録する関数
Future<void> insertInitialAchievements(dynamic db) async {
  try {
    // 既存の実績を取得
    final existingAchievements = await db.getAllAchievements();

    // 既存の実績IDのセットを作成
    final existingIds = existingAchievements
        .map((a) => a['id'] as String)
        .toSet();

    // 各実績をチェックして未登録なら追加
    for (var achievement in initialAchievements) {
      final id = achievement['id'] as String;

      // 既に登録済みならスキップ
      if (existingIds.contains(id)) {
        continue;
      }

      // 未登録ならデータベースに挿入
      await db.database.then((database) {
        return database.insert(
          'achievements',
          achievement,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      // ignore: avoid_print
      print('実績を登録: ${achievement['name']}');
    }

    // ignore: avoid_print
    print('初期実績の登録完了（全${initialAchievements.length}個）');
  } catch (e) {
    // ignore: avoid_print
    print('実績登録エラー: $e');
  }
}

/// 条件タイプに応じた絵文字を取得
String getEmojiByCondition(String conditionType) {
  switch (conditionType) {
    case 'habit_count':
      return '📝';
    case 'streak':
      return '🔥';
    case 'total_days':
      return '💪';
    default:
      return '🏆';
  }
}
