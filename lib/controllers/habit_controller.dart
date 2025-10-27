import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/habit.dart';

/// HabitController
///
/// 役割:
/// - 習慣データの読み込み、更新、削除などのビジネスロジックを管理
/// - UIから独立したロジックを提供
class HabitController {
  final DatabaseService _db = DatabaseService();

  /// 習慣を読み込む
  ///
  /// 処理の流れ:
  /// 1. データベースからすべての習慣を取得
  /// 2. MapのリストをHabitオブジェクトのリストに変換
  /// 3. 今日の達成記録を取得
  ///
  /// 戻り値:
  /// - habits: 習慣のリスト
  /// - todayRecords: 今日の達成記録 Map<habit_id, completed>
  Future<({List<Habit> habits, Map<String, int> todayRecords})>
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

    return (habits: habits, todayRecords: todayRecords);
  }

  /// 習慣の達成状態を切り替える
  ///
  /// 処理の流れ:
  /// 1. 現在の達成状態を確認
  /// 2. 達成/未達成を反転
  /// 3. データベースに保存または更新
  /// 4. 画面を更新
  ///
  /// 戻り値:
  /// - success: 成功したかどうか
  /// - newCompleted: 新しい達成状態 (0 or 1)
  /// - message: 表示するメッセージ
  Future<({bool success, int newCompleted, String message})>
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

      // スナックバーで通知
      final message = newCompleted == 1
          ? '${habit.emoji} ${habit.name} を達成しました!'
          : '${habit.name} の達成を取り消しました';

      return (success: true, newCompleted: newCompleted, message: message);
    } catch (e) {
      // エラー処理
      return (
        success: false,
        newCompleted: currentCompleted,
        message: 'エラーが発生しました: $e',
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
