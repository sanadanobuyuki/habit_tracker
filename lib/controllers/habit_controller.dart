// ignore: unused_import
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/habit.dart';
import '../controllers/achievement_controller.dart'; // 【追加】

/// OperationResult クラス
/// 役割:
/// - 操作の成功/失敗を表すクラス
/// - メッセージも一緒に返す
class OperationResult {
  final bool success; // 成功したかどうか
  final String message; // 結果メッセージ
  final int newCompleted; // 新しい達成状態（toggleHabitCompletion用）

  OperationResult({
    required this.success,
    required this.message,
    this.newCompleted = 0,
  });
}

/// HabitController
///
/// 役割:
/// - 習慣データの読み込み、更新、削除などのビジネスロジックを管理
/// - UIから独立したロジックを提供
/// - 習慣達成時に実績チェックを実行 【追加】
class HabitController {
  final DatabaseService _db = DatabaseService();

  Future<OperationResult> updateHabit({
    required String id,
    required String name,
    required String emoji,
    required int color,
  }) async {
    try {
      // バリデーション: 習慣名が空でないかチェック
      if (name.trim().isEmpty) {
        return OperationResult(success: false, message: '習慣名を入力してください');
      }

      // バリデーション: 習慣名が長すぎないかチェック
      if (name.length > 30) {
        return OperationResult(success: false, message: '習慣名は30文字以内で入力してください');
      }

      // DatabaseService で習慣を更新
      await _db.updateHabit(id: id, name: name, emoji: emoji, color: color);

      // 成功を返す
      return OperationResult(success: true, message: '習慣を更新しました');
    } catch (e) {
      // エラーが発生した場合
      // ignore: avoid_print
      print('習慣の更新エラー: $e');
      return OperationResult(success: false, message: '更新中にエラーが発生しました: $e');
    }
  }

  final AchievementController _achievementController = AchievementController();

  /// 習慣を読み込む
  ///
  /// 処理の流れ:
  /// 1. データベースからすべての習慣を取得
  /// 2. MapのリストをHabitオブジェクトのリストに変換
  /// 3. 今日の達成記録を取得
  ///
  /// 戻り値:
  /// - habits: 習慣のリスト
  // ignore: unintended_html_in_doc_comment
  /// - todayRecords: 今日の達成記録 Map<habit_id, completed>
  Future<
    ({
      List<Habit> habits,
      Map<String, int> todayRecords,
      Map<String, int> streakCounts,
    })
  >
  loadHabits() async {
    // データベースサービスのインスタンスを作成
    // データベースからすべての習慣を取得
    final habitsData = await _db.getAllHabits();

    // MapのリストをHabitオブジェクトのリストに変換
    final habits = habitsData.map((data) => Habit.fromMap(data)).toList();

    // 今日の日付を取得 (YYYY-MM-DD形式)
    final today = _getTodayString();

    // 今日の記録を取得
    final todayRecordsData = await _db.getRecordsByDate(today);

    // Map形式に変換 { habit_id: completed }
    final Map<String, int> todayRecords = {};
    for (var record in todayRecordsData) {
      todayRecords[record['habit_id'] as String] =
          record['completed'] as int? ?? 0;
    }

    // 連続達成回数を取得
    final streakCounts = <String, int>{};
    for (final habit in habits) {
      final streak = await _db.getStreakCount(habit.id);
      streakCounts[habit.id] = streak;
    }

    return (
      habits: habits,
      todayRecords: todayRecords,
      streakCounts: streakCounts,
    );
  }

  /// 習慣の達成状態を切り替える【実績チェック追加版】
  ///
  /// 処理の流れ:
  /// 1. 現在の達成状態を確認
  /// 2. 達成/未達成を反転
  /// 3. データベースに保存または更新
  /// 4. 【追加】達成した場合は実績をチェック
  /// 5. 画面を更新
  ///
  /// 戻り値:
  /// - success: 成功したかどうか
  /// - newCompleted: 新しい達成状態 (0 or 1)
  /// - message: 表示するメッセージ
  /// - unlockedAchievements: 新しく解除された実績のリスト 【追加】
  Future<
    ({
      bool success,
      int newCompleted,
      String message,
      List<dynamic> unlockedAchievements,
    })
  >
  toggleHabitCompletion(Habit habit, int currentCompleted) async {
    final today = _getTodayString();

    // 現在の達成状態を取得 (未記録の場合は0=未達成)
    // 達成状態を反転 (0→1, 1→0)
    final newCompleted = currentCompleted == 0 ? 1 : 0;

    try {
      // 今日の記録が既に存在するか確認
      final existingRecords = await _db.getRecordsByDate(today);
      final existingRecord = existingRecords.firstWhere(
        (record) => record['habit_id'] == habit.id,
        orElse: () => <String, dynamic>{},
      );

      if (existingRecord.isEmpty) {
        // 記録が存在しない場合: 新規作成
        final recordId =
            'record_${habit.id}_${DateTime.now().millisecondsSinceEpoch}';
        await _db.insertRecord(
          id: recordId,
          habitId: habit.id,
          date: today,
          completed: newCompleted,
          recordedAt: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        // 記録が存在する場合: 更新
        await _db.updateRecord(
          id: existingRecord['id'] as String,
          completed: newCompleted,
        );
      }

      // ========== 実績チェック ==========
      final unlockedAchievements = <dynamic>[];

      if (newCompleted == 1) {
        // 達成した場合のみ実績をチェック
        try {
          // ignore: avoid_print
          print('🔍 実績チェック開始...');

          // total_days系の実績をチェック
          final totalDaysAchievements = await _achievementController
              .checkTotalDaysAchievements();
          unlockedAchievements.addAll(totalDaysAchievements);

          // streak系の実績をチェック
          final streakAchievements = await _achievementController
              .checkStreakAchievements();
          unlockedAchievements.addAll(streakAchievements);

          if (unlockedAchievements.isNotEmpty) {
            // ignore: avoid_print
            print('🎉 ${unlockedAchievements.length}個の実績を解除しました！');
          }
        } catch (e) {
          // ignore: avoid_print
          print('実績チェックエラー: $e');
          // 実績チェックのエラーは習慣の達成には影響しない
        }
      }
      // ========================================

      // スナックバーで通知
      final message = newCompleted == 1
          ? '${habit.emoji} ${habit.name} を達成しました!'
          : '${habit.name} の達成を取り消しました';

      return (
        success: true,
        newCompleted: newCompleted,
        message: message,
        unlockedAchievements: unlockedAchievements,
      );
    } catch (e) {
      // エラー処理
      return (
        success: false,
        newCompleted: currentCompleted,
        message: 'エラーが発生しました: $e',
        unlockedAchievements: <dynamic>[],
      );
    }
  }

  /// 習慣を削除する
  ///
  /// 実際には削除フラグを1に更新するだけ
  /// 理由: 過去の記録は保持したいため
  ///
  /// 戻り値:
  /// - success: 成功したかどうか
  /// - message: 表示するメッセージ
  Future<({bool success, String message})> deleteHabit(Habit habit) async {
    try {
      await _db.deleteHabit(habit.id);
      return (success: true, message: '「${habit.name}」を削除しました');
    } catch (e) {
      return (success: false, message: 'エラーが発生しました: $e');
    }
  }

  /// 今日の日付を YYYY-MM-DD 形式で取得
  ///
  /// 例: 2024-10-24
  String _getTodayString() {
    final now = DateTime.now();
    // padLeft(2, '0') について:
    // 2桁になるように左側を0で埋める
    // 例: 1 → 01, 12 → 12
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
