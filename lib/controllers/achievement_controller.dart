import '../services/database_service.dart';
import '../models/achievement.dart';
import '../models/user_achievement.dart';

//役割
//実績の条件をチェックし、達成状況を管理
//重複解除を防ぐ

class AchievementController {
  final DatabaseService _db = DatabaseService();

  //habit_count系の実績をチェック
  //習慣を作成したときに呼ぶ
  //処理の流れ
  //1.現在の習慣数を取得
  //2.habit_count系のすべての実績を取得
  //3.各実績について条件を満たしているか確認
  //4.未解除なら実績を解除
  //戻り値
  //List<Achievement> :新しく解除された実績のリスト

  Future<List<Achievement>> checkHabitCountAchievements() async {
    //新しく解除された実績を保存するリスト
    final newlyUnlocked = <Achievement>[];

    try {
      //現在の習慣数を取得
      final habits = await _db.getAllHabits();
      final habitCount = habits.length;

      //すべてのhabit_count系実績を取得
      final allAchievements = await _db.getAllAchievements();

      //condition_typeが'habit_count'の実績だけフィルタリング
      //where()について:リストの要素を条件でフィルタリング
      //条件に一致する要素だけを残す
      final habitCountAchievements = allAchievements
          .where((data) => data['coundition_type'] == 'habit_count')
          .map((data) => Achievement.fromMap(data))
          .toList();

      //各実績をチェック
      for (var achievement in habitCountAchievements) {
        //条件を満たしているか確認
        final isMet = habitCount >= achievement.conditionValue;

        if (!isMet) {
          //条件を満たしていない場合はスキップ
          continue;
        }

        //すでに解除されているか確認
        final isAlreadyUnlocked = await _db.isAchievementUnlocked(
          achievement.id,
        );

        if (isAlreadyUnlocked) {
          //すでに解除されている場合はスキップ
          continue;
        }

        //実績を解除
        await _unlockAchievement(achievement);

        //新しく解除されたリストに追加
        newlyUnlocked.add(achievement);
      }
    } catch (e) {
      //エラーが発生してもアプリはクラッシュしない
      //ignore: avoid_print
      print('実績エラーチェック $e');
    }
    return newlyUnlocked;
  }

  //total_days系の実績をチェック
  //習慣を達成したときに呼ぶ
  //処理の流れ
  //1.累計達成日数を計算
  //2.total_days系の実績を取得
  //3/条件を満たしているか確認
  //4.未解除なら実績を解除
  //戻り値
  //List<Achievement> :新しく解除された実績のリスト

  Future<List<Achievement>> checkTotalDaysAchievements() async {
    final newlyUnlocked = <Achievement>[];

    try {
      // 1. 累計達成日数を計算
      final totalDays = await _calculateTotalDays();

      // 2. total_days 系の実績をすべて取得
      final allAchievements = await _db.getAllAchievements();
      final totalDaysAchievements = allAchievements
          .where((data) => data['condition_type'] == 'total_days')
          .map((data) => Achievement.fromMap(data))
          .toList();

      // 3. 各実績をチェック
      for (var achievement in totalDaysAchievements) {
        final isMet = totalDays >= achievement.conditionValue;

        if (!isMet) continue;

        final isAlreadyUnlocked = await _db.isAchievementUnlocked(
          achievement.id,
        );

        if (isAlreadyUnlocked) continue;

        // 4. 解除
        await _unlockAchievement(achievement);
        newlyUnlocked.add(achievement);
      }
    } catch (e) {
      // ignore: avoid_print
      print('実績チェックエラー: $e');
    }

    return newlyUnlocked;
  }

  //streak系の実績をチェック
  //習慣を達成したときに呼ぶ
  //処理の流れ
  //1.現在の連続達成日数を計算
  //2.streak系の実績を取得
  //3.条件を満たしているかチェック
  //4.未解除なら解除
  //戻り値
  //List<Achievement>:新しく解除された実績のリスト
  Future<List<Achievement>> checkStreakAchievements() async {
    final newlyUnlocked = <Achievement>[];

    try {
      // 1. 現在の連続達成日数を計算
      final streak = await _calculateCurrentStreak();

      // 2. streak 系の実績をすべて取得
      final allAchievements = await _db.getAllAchievements();
      final streakAchievements = allAchievements
          .where((data) => data['condition_type'] == 'streak')
          .map((data) => Achievement.fromMap(data))
          .toList();

      // 3. 各実績をチェック
      for (var achievement in streakAchievements) {
        final isMet = streak >= achievement.conditionValue;

        if (!isMet) continue;

        final isAlreadyUnlocked = await _db.isAchievementUnlocked(
          achievement.id,
        );

        if (isAlreadyUnlocked) continue;

        // 4. 解除
        await _unlockAchievement(achievement);
        newlyUnlocked.add(achievement);
      }
    } catch (e) {
      // ignore: avoid_print
      print('実績チェックエラー: $e');
    }

    return newlyUnlocked;
  }

  //実績を解除する(内部用)
  //user_avhievementsテーブルに記録を追加
  //引数
  //achievement:解除する実績

  Future<void> _unlockAchievement(Achievement achievement) async {
    //UserAchievement:オブジェクト作成
    final userAchievement = UserAchievement(
      id: 'user_ach_${DateTime.now().millisecondsSinceEpoch}',
      achievementId: achievement.id,
      unlockedAt: DateTime.now(),
      themeReceived: false,
    );

    //データベースに保存
    await _db.insertUserAchievement(userAchievement);

    //ignore: avoid_print
    print('🎉 実績解除:${achievement.name}');
  }

  //累計達成日数を計算
  //すべての習慣を100%達成した日の日数
  //処理の流れ
  //1.すべての記録を取得
  //2.日付ごとにグループ化
  //3.各日で達成率を計算
  //4.100%達成の日数をカウント
  //戻り値：int :累計達成日数
  Future<int> _calculateTotalDays() async {
    try {
      //すべての実績を取得
      final habits = await _db.getAllHabits();

      if (habits.isEmpty) {
        return 0;
      }

      // すべての記録を取得
      final allRecords = <Map<String, dynamic>>[];
      for (var habit in habits) {
        final records = await _db.getRecordsByHabit(habit['id'] as String);
        allRecords.addAll(records);
      }

      // 日付ごとにグループ化
      // Map<日付, その日の記録のリスト>
      final Map<String, List<Map<String, dynamic>>> recordsByDate = {};
      for (var record in allRecords) {
        final date = record['date'] as String;
        recordsByDate[date] ??= [];
        recordsByDate[date]!.add(record);
      }

      // 100%達成の日数をカウント
      int totalDays = 0;
      for (var entry in recordsByDate.entries) {
        final date = entry.key;
        final records = entry.value;

        // その日が対象の習慣数
        final targetHabitsCount = _getTargetHabitsCountForDate(date, habits);

        if (targetHabitsCount == 0) continue;

        // その日に達成した習慣数
        // where() について:
        // - 条件に一致する要素だけをフィルタリング
        // - completed == 1 の記録だけを残す
        final completedCount = records.where((r) => r['completed'] == 1).length;

        // 達成率が100%なら
        if (completedCount >= targetHabitsCount) {
          totalDays++;
        }
      }

      return totalDays;
    } catch (e) {
      // ignore: avoid_print
      print('累計日数計算エラー: $e');
      return 0;
    }
  }

  // 現在の連続達成日数を計算
  // 今日から過去にさかのぼって、連続で100%達成している日数
  // 処理の流れ:
  // 1. 今日から過去にさかのぼる
  // 2. 各日で達成率をチェック
  // 3. 100%でない日が出たら終了
  // 戻り値:
  // - int: 連続達成日数
  Future<int> _calculateCurrentStreak() async {
    try {
      final habits = await _db.getAllHabits();

      if (habits.isEmpty) {
        return 0;
      }

      int streak = 0;
      DateTime date = DateTime.now();

      // 最大100日前までチェック（無限ループ防止）
      for (int i = 0; i < 100; i++) {
        final dateStr = _formatDate(date);

        // その日の達成率を計算
        final rate = await _getAchievementRateForDate(dateStr, habits);

        // 100%達成でない、またはデータがない
        if (rate == null || rate < 1.0) {
          break;
        }

        streak++;
        // 1日前に移動
        date = date.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (e) {
      // ignore: avoid_print
      print('連続日数計算エラー: $e');
      return 0;
    }
  }

  // 特定の日の達成率を計算
  // 引数:
  // - dateStr: 日付文字列（YYYY-MM-DD）
  // - habits: すべての習慣
  // 戻り値:
  // - double: 達成率（0.0〜1.0）
  // - null: データなし
  Future<double?> _getAchievementRateForDate(
    String dateStr,
    List<Map<String, dynamic>> habits,
  ) async {
    // その日が対象の習慣数
    final targetCount = _getTargetHabitsCountForDate(dateStr, habits);

    if (targetCount == 0) {
      return null;
    }

    // その日の記録を取得
    final records = await _db.getRecordsByDate(dateStr);

    // 達成した習慣数
    final completedCount = records.where((r) => r['completed'] == 1).length;

    // 達成率を計算
    return completedCount / targetCount;
  }

  // 特定の日が対象の習慣数を取得
  //
  // 引数:
  // - dateStr: 日付文字列（YYYY-MM-DD）
  // - habits: すべての習慣
  //
  // 戻り値:
  // - int: その日が対象の習慣数
  int _getTargetHabitsCountForDate(
    String dateStr,
    List<Map<String, dynamic>> habits,
  ) {
    // 日付から曜日を取得
    final date = DateTime.parse(dateStr);
    final weekday = date.weekday; // 1=月, 2=火, ..., 7=日

    int count = 0;
    for (var habit in habits) {
      final daysOfWeek = habit['days_of_week'] as String?;

      if (daysOfWeek == null) {
        // 毎日が対象
        count++;
      } else {
        // 曜日指定
        final days = daysOfWeek.split(',').map(int.parse).toList();
        if (days.contains(weekday)) {
          count++;
        }
      }
    }

    return count;
  }

  // 日付を YYYY-MM-DD 形式に変換
  //
  // 引数:
  // - date: DateTime オブジェクト
  //
  // 戻り値:
  // - String: YYYY-MM-DD 形式の文字列
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
