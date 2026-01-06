import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

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
  final int streakCount;
  final VoidCallback onTap;
  final Future<bool> Function() onDeleteConfirm;
  final VoidCallback onEdit;
  final AppLocalizations l10n;
  const HabitCard({
    super.key,
    required this.habit,
    required this.completedStatus,
    required this.streakCount,
    required this.onTap,
    required this.onDeleteConfirm,
    required this.onEdit,
    required this.l10n,
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
      direction: DismissDirection.horizontal,
      // background = 右スワイプ時に表示される背景
      background: _buildDismissBackgroundRight(),
      //左スワイプ時に表示される背景
      secondaryBackground: _buildDismissBackgroundLeft(),
      // confirmDismiss = スワイプ方向によって処理を分ける
      // DismissDirection.endToStart = 右スワイプ（削除）
      // DismissDirection.startToEnd = 左スワイプ（編集）
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // 右スワイプ → 削除確認ダイアログを表示
          return await onDeleteConfirm();
        } else if (direction == DismissDirection.startToEnd) {
          // 左スワイプ → 編集画面へ遷移
          onEdit();
          return false; // カードは消さない（編集だけ）
        }
        return false;
      },
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
            trailing: _buildTrailing(context, isCompleted, isTargetDay),
          ),
        ),
      ),
    );
  }

  /// 右スワイプ時の背景
  ///
  /// 右側に余白を追加
  /// これがないとアイコンが端にくっついてしまう
  /// 青い背景と編集アイコン
  Widget _buildDismissBackgroundRight() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      // アイコンの表示
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  /// 左スワイプ時の背景
  Widget _buildDismissBackgroundLeft() {
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
    if (!isTargetDay) {
      // 今日は対象外の場合
      return Text(
        l10n.notTargetToday,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
      );
    }
    // 今日が対象日の場合は連続達成回数を表示
    if (streakCount > 0) {
      return Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            l10n.daysStreak(streakCount),
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      // 連続達成0日の場合
      return Text(
        l10n.goal,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      );
    }
  }

  /// 右側の部分
  Widget _buildTrailing(
    BuildContext context,
    bool isCompleted,
    bool isTargetDay,
  ) {
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

        //メニューボタン
        //IconButton タップ可能なアイコン
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          color: Colors.grey[600],
          padding: EdgeInsets.zero, // パディングをゼロに
          constraints: const BoxConstraints(), // サイズ制約を最小に
          onPressed: () => _showMenu(context), // メニューを表示
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

  //メニューを表示
  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // shape = BottomSheet の形状（上部を丸くする）
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        // SafeArea について:
        // 画面下部の安全領域（ホームバーなど）を確保
        child: Column(
          mainAxisSize: MainAxisSize.min, // 必要最小限の高さ
          children: [
            // 習慣名をヘッダーとして表示
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 絵文字
                  Text(habit.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  // 習慣名
                  Expanded(
                    child: Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 区切り線
            const Divider(height: 1),

            // 編集メニュー
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context); // メニューを閉じる
                onEdit(); // 編集画面へ遷移
              },
            ),

            // 削除メニュー
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.delete),
              onTap: () async {
                Navigator.pop(context); // メニューを閉じる
                await onDeleteConfirm(); // 削除確認ダイアログを表示
              },
            ),

            // 下部の余白
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
