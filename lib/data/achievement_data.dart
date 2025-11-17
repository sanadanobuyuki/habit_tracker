//achievement_data.dart
//初期実績データを定義
//データベースに登録するための実績リスト

//アプリ起動時に一度だけ実行しすべての実績をデータベースに登録、登録済みの場合スキップ

//実績の説明
// - id: 実績の一意な識別子（'ach_' で始める）
// - name: 実績の名前（ユーザーに表示）
// - description: 実績の説明（達成条件を説明）
// - condition_type: 条件のタイプ
//   - 'habit_count': 習慣を作成した数
//   - 'total_days': 累計達成日数
//  - 'streak': 連続達成日数
// - condition_value: 達成に必要な値
//- rarity: null（使用しない）
// - theme_id: 報酬テーマ（null = テーマ報酬なし）
import 'package:sqflite/sqflite.dart';

final List<Map<String, dynamic>> initialAchievemnts = [
  // ========== 習慣作成系 ==========

  // 実績1: 初めての一歩
  // 最も簡単な実績
  // 習慣を1個作成するだけで達成
  {
    'id': 'ach_first_habit',
    'name': '初めての一歩',
    'description': '初めて習慣を作成した',
    'condition_type': 'habit_count', // 習慣の数
    'condition_value': 1, // 1個
    'rarity': null, // レアリティなし
    'theme_id': null, // テーマ報酬なし
  },

  // 実績2: 習慣コレクター
  // 複数の習慣を作成
  {
    'id': 'ach_habit_5',
    'name': '習慣コレクター',
    'description': '5個の習慣を作成した',
    'condition_type': 'habit_count',
    'condition_value': 5,
    'rarity': null,
    'theme_id': null,
  },

  // 実績3: 習慣マスター
  // 多くの習慣を管理
  {
    'id': 'ach_habit_10',
    'name': '習慣マスター',
    'description': '10個の習慣を作成した',
    'condition_type': 'habit_count',
    'condition_value': 10,
    'rarity': null,
    'theme_id': null,
  },

  // ========== 累計達成日数系 ==========

  // 実績4: 初日達成
  // 最初の達成
  // 1日でもすべての習慣を達成すれば解除
  {
    'id': 'ach_first_day',
    'name': '初日達成',
    'description': '初めてすべての習慣を達成した',
    'condition_type': 'total_days', // 累計達成日数
    'condition_value': 1, // 1日
    'rarity': null,
    'theme_id': null,
  },

  // 実績5: 1週間の成果
  // 累計7日達成
  {
    'id': 'ach_total_7',
    'name': '1週間の成果',
    'description': '累計7日すべての習慣を達成した',
    'condition_type': 'total_days',
    'condition_value': 7,
    'rarity': null,
    'theme_id': null,
  },

  // 実績6: 1ヶ月の積み重ね
  // 累計30日達成
  {
    'id': 'ach_total_30',
    'name': '1ヶ月の積み重ね',
    'description': '累計30日すべての習慣を達成した',
    'condition_type': 'total_days',
    'condition_value': 30,
    'rarity': null,
    'theme_id': null,
  },

  // 実績7: 百日修行
  // 累計100日達成
  {
    'id': 'ach_total_100',
    'name': '百日修行',
    'description': '累計100日すべての習慣を達成した',
    'condition_type': 'total_days',
    'condition_value': 100,
    'rarity': null,
    'theme_id': null,
  },

  // ========== 連続達成日数系 ==========

  // 実績8: 三日坊主克服
  // 3日連続ですべての習慣を達成
  {
    'id': 'ach_streak_3',
    'name': '三日坊主克服',
    'description': '3日連続ですべての習慣を達成した',
    'condition_type': 'streak', // 連続達成日数
    'condition_value': 3, // 3日
    'rarity': null,
    'theme_id': null,
  },

  // 実績9: 継続の達人
  // 7日連続達成
  {
    'id': 'ach_streak_7',
    'name': '継続の達人',
    'description': '7日連続ですべての習慣を達成した',
    'condition_type': 'streak',
    'condition_value': 7,
    'rarity': null,
    'theme_id': null,
  },

  // 実績10: 習慣の鬼
  // 30日連続達成は非常に難しい
  {
    'id': 'ach_streak_30',
    'name': '習慣の鬼',
    'description': '30日連続ですべての習慣を達成した',
    'condition_type': 'streak',
    'condition_value': 30,
    'rarity': null,
    'theme_id': null,
  },
];

//実績データをデータベースに登録する関数
Future<void> insertInitialAchievements(dynamic db) async {
  try {
    //既存の実績を取得
    final exisitngAchievements = await db.getAllAchievemnts();

    //既存の実績IDのセットを作成
    //Setについて
    //リストと似ているが、重複を許さない
    //contains() が高速に動作する
    final existingIds = exisitngAchievements
        .map((a) => a['id'] as String)
        .toSet();

    //各実績をチェックして未登録なら追加
    for (var achivement in initialAchievemnts) {
      final id = achivement['id'] as String;

      //既に登録済みならスキップ
      if (existingIds.contains(id)) {
        continue;
      }
      //未登録ならデータベースに挿入
      await db.database.then((database) {
        return database.insert(
          'achievements',
          achivement,
          confliactAlgorithm: ConflictAlgorithm.replace,
        );
      });
      // ignore: avoid_print
      print('実績を登録しました: $id');
    }
    // ignore: avoid_print
    print('実績の初期登録が完了しました');
  } catch (e) {
    //エラー処理
    // ignore: avoid_print
    print('実績登録エラー: $e');
  }
}

/// 条件タイプに応じた絵文字を取得
///
/// 使い方:
/// ```dart
/// String emoji = getEmojiByCondition('streak');  // '🔥'
/// ```
///
/// 条件タイプと絵文字の対応:
/// - habit_count: 📝（習慣を作成する）
/// - streak: 🔥（連続で達成する）
/// - total_days: 💪（累計で達成する）
String getEmojiByCondition(String conditionType) {
  switch (conditionType) {
    case 'habit_count':
      return '📝'; // メモ（習慣作成）
    case 'streak':
      return '🔥'; // 炎（連続達成）
    case 'total_days':
      return '💪'; // 筋肉（累計達成）
    default:
      return '🏆'; // デフォルト: トロフィー
  }
}
