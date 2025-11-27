import 'package:flutter/material.dart';
import '../models/habit.dart';

/// HabitCard
///
/// 役割:
/// - 習慣カードのUIを表示
/// - スワイプ削除機能を提供
///
/// Card = 影付きのカード型UI
/// ListTile = リスト項目の標準的なレイアウト
/// Dismissible = スワイプで削除可能にするウィジェット
class HabitCard extends StatelessWidget {
  final Habit habit;
  final int completedStatus; // 0 = 未達成, 1 = 達成
  final VoidCallback onTap;
  final Future<bool> Function() onDeleteConfirm;

  const HabitCard({
    super.key,
    required this.habit,
    required this.completedStatus,
    required this.onTap,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    // 今日の達成状態を取得
    final isCompleted = completedStatus == 1;

    // 今日が対象の曜日かどうかを判定
    final today = DateTime.now().weekday; // 1(月)〜7(日)
    final isTargetDay = habit.isTargetDay(today);

    return Dismissible(
      // key = 各カードを識別するための一意のキー
      key: Key(habit.id),
      // direction = スワイプ可能な方向
      direction: DismissDirection.endToStart,
      // background = スワイプ時に表示される背景
      background: _buildDismissBackground(),
      // confirmDismiss = スワイプで削除する前に確認ダイアログを表示
      confirmDismiss: (direction) => onDeleteConfirm(),
      child: Opacity(
        // Opacity について:
        // 透明度を指定する (0.0〜1.0)
        // 今日対象外の場合は0.4(薄く表示)、対象の場合は1.0(通常表示)
        opacity: isTargetDay ? 1.0 : 0.4,
        child: Card(
          // margin = カードの外側の余白
          margin: const EdgeInsets.only(bottom: 12),

          // elevation = 影の深さ
          // 今日対象外の場合は影を薄くする
          elevation: isTargetDay ? 2 : 1,

          // shape = カードの形状
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 角を丸くする
          ),

          child: ListTile(
            // onTap について:
            // カードをタップした時の処理
            // 今日対象の日のみタップ可能にする
            onTap: isTargetDay ? onTap : null,

            // contentPadding = 内側の余白
            contentPadding: const EdgeInsets.all(16),

            // leading = 左側に表示する要素
            leading: _buildLeading(isTargetDay),

            // title = タイトル部分
            title: _buildTitle(isCompleted, isTargetDay),

            // subtitle = サブタイトル部分
            subtitle: _buildSubtitle(isTargetDay),

            // trailing = 右側に表示する要素
            trailing: _buildTrailing(isCompleted, isTargetDay),
          ),
        ),
      ),
    );
  }

  /// スワイプ時の背景
  ///
  /// 右側に余白を追加
  /// これがないとゴミ箱アイコンが端にくっついてしまう
  /// 赤い背景とゴミ箱アイコン
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      // アイコンの表示
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  /// 左側のアイコン部分
  Widget _buildLeading(bool isTargetDay) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Color(habit.color).withOpacity(isTargetDay ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(habit.emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  /// タイトル部分
  Widget _buildTitle(bool isCompleted, bool isTargetDay) {
    return Text(
      habit.name,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        // 達成済みの場合は取り消し線を表示
        decoration: isCompleted ? TextDecoration.lineThrough : null,
        color: isTargetDay ? (isCompleted ? Colors.grey : null) : Colors.grey,
      ),
    );
  }

  /// サブタイトル部分
  Widget _buildSubtitle(bool isTargetDay) {
    return Text(
      isTargetDay ? '目標' : '今日は対象外',
      style: TextStyle(
        fontSize: 14,
        color: isTargetDay ? Colors.grey : Colors.grey.shade400,
      ),
    );
  }

  /// 右側の部分
  Widget _buildTrailing(bool isCompleted, bool isTargetDay) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 達成済みかつ今日対象の場合はチェックマークを表示
        if (isCompleted && isTargetDay)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(habit.color),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
        const SizedBox(width: 8),
        // 色のバー
        Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: Color(
              habit.color,
              // ignore: deprecated_member_use
            ).withOpacity(isTargetDay ? 1.0 : 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
