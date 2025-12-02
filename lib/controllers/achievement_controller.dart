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
          .where((data) => data['condition_type'] == 'habit_count')
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
      // ignore: avoid_print
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

      // ignore: avoid_print
      print('📊 累計達成日数: $totalDays 日');

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

    // ignore: avoid_print
    print('🎉 実績解除:${achievement.name}');
  }

  /// 累計達成日数を計算【完全版】
  ///
  /// すべての習慣を100%達成した日の日数
  ///
  /// 重要: 「その日時点で存在していた習慣」だけを対象にする
  ///
  /// 処理の流れ:
  /// 1. すべての日付を取得
  /// 2. 各日付で、その日に存在していた習慣を特定
  /// 3. その習慣がすべて達成されているかチェック
  /// 4. 100%達成の日数をカウント
  Future<int> _calculateTotalDays() async {
    try {
      // すべての記録がある日付を取得
      final db = await _db.database;
      final datesResult = await db.rawQuery('''
        SELECT DISTINCT date
        FROM habit_records
        ORDER BY date ASC
      ''');

      if (datesResult.isEmpty) {
        return 0;
      }

      int totalDays = 0;

      for (var row in datesResult) {
        final date = row['date'] as String;
        final isPerfect = await _isPerfectDay(date);

        if (isPerfect) {
          totalDays++;
          // ignore: avoid_print
          print('✅ $date: 完全達成!');
        }
      }

      return totalDays;
    } catch (e) {
      // ignore: avoid_print
      print('累計日数計算エラー: $e');
      return 0;
    }
  }

  /// 特定の日が「完全達成日」かチェック【修正版】
  ///
  /// 完全達成日の条件:
  /// - その日時点で存在していた習慣がすべて達成されている
  /// - 曜日指定で対象外の習慣は無視
  ///
  /// 重要ポイント:
  /// - 習慣の created_at を確認（その日より前に作られた習慣のみ対象）
  /// - 習慣の deleted_at を確認（その日にはまだ削除されていない習慣のみ対象）
  ///
  /// 引数:
  /// - date: 日付文字列（YYYY-MM-DD）
  ///
  /// 戻り値:
  /// - true: 完全達成
  /// - false: 未達成または記録なし
  Future<bool> _isPerfectDay(String date) async {
    try {
      // その日時点で存在していた習慣を取得
      final habits = await _db.getHabitsAtDate(date);

      if (habits.isEmpty) {
        return false;
      }

      // その日の記録を取得
      final records = await _db.getRecordsByDate(date);

      // 記録をMap化（habit_id → record）
      final Map<String, Map<String, dynamic>> recordMap = {};
      for (var record in records) {
        recordMap[record['habit_id'] as String] = record;
      }

      // 日付から曜日を取得
      final dateTime = DateTime.parse(date);
      final weekday = dateTime.weekday; // 1=月, 2=火, ..., 7=日

      // その日が対象の習慣をチェック
      int targetCount = 0;
      int completedCount = 0;

      for (var habit in habits) {
        final habitId = habit['id'] as String;
        final daysOfWeek = habit['days_of_week'] as String?;

        // この習慣がその日の対象かチェック
        bool isTargetDay = false;

        if (daysOfWeek == null) {
          // 毎日が対象
          isTargetDay = true;
        } else {
          // 曜日指定
          final days = daysOfWeek.split(',').map(int.parse).toList();
          isTargetDay = days.contains(weekday);
        }

        if (!isTargetDay) {
          // この習慣はこの日の対象外（曜日指定で対象外）
          continue;
        }

        // 対象の習慣数をカウント
        targetCount++;

        // この習慣の記録があるかチェック
        if (recordMap.containsKey(habitId)) {
          final record = recordMap[habitId]!;
          if (record['completed'] == 1) {
            completedCount++;
          }
        }
        // 記録がない場合は未達成として扱う（completedCountに加算しない）
      }

      // 対象の習慣がない日は完全達成日としない
      if (targetCount == 0) {
        return false;
      }

      // すべての対象習慣が達成されていればtrue
      final isPerfect = completedCount == targetCount;

      if (!isPerfect) {
        // ignore: avoid_print
        print('❌ $date: $completedCount/$targetCount 達成');
      }

      return isPerfect;
    } catch (e) {
      // ignore: avoid_print
      print('完全達成日チェックエラー: $e');
      return false;
    }
  }

  /// 現在の連続達成日数を計算【修正版】
  ///
  /// 今日から過去にさかのぼって、連続で100%達成している日数
  ///
  /// 処理の流れ:
  /// 1. 今日から過去にさかのぼる
  /// 2. 各日で _isPerfectDay() をチェック
  /// 3. 100%でない日が出たら終了
  ///
  /// 戻り値:
  /// - int: 連続達成日数
  Future<int> _calculateCurrentStreak() async {
    try {
      int streak = 0;
      DateTime date = DateTime.now();

      // 最大365日前までチェック（無限ループ防止）
      for (int i = 0; i < 365; i++) {
        final dateStr = _formatDate(date);

        // その日が完全達成日かチェック
        final isPerfect = await _isPerfectDay(dateStr);

        // 完全達成でない
        if (!isPerfect) {
          break;
        }

        streak++;
        // 1日前に移動
        date = date.subtract(const Duration(days: 1));
      }

      // ignore: avoid_print
      print('🔥 連続達成日数: $streak 日');

      return streak;
    } catch (e) {
      // ignore: avoid_print
      print('連続日数計算エラー: $e');
      return 0;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
