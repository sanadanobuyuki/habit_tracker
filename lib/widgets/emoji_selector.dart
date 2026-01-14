import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

/// EmojiSelector
///
/// 役割:
/// - 絵文字選択UIを提供
/// - 再利用可能なウィジェット
///
/// StatelessWidgetについて:
/// - 状態を持たない（変更されない）ウィジェット
/// - 親から値と関数を受け取って表示するだけ
/// - 軽量でパフォーマンスが良い
class EmojiSelector extends StatelessWidget {
  final String selectedEmoji;
  final Function(String) onEmojiSelected;

  // 利用可能な絵文字リスト（大幅拡充）
  final List<String> availableEmojis;

  const EmojiSelector({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
    this.availableEmojis = const [
      // 運動・健康系
      '🏃', // ランニング
      '💪', // 筋トレ
      '🏊', // 水泳
      '🚴', // サイクリング
      '🧘', // ヨガ・瞑想
      '🚶', // ウォーキング
      '🤸', // ストレッチ
      // 学習・仕事系
      '📚', // 読書
      '✍️', // 書く
      '📖', // 勉強
      '💼', // 仕事
      '🧠', // 思考・学習
      '🎯', // 目標達成
      // 生活習慣系
      '💤', // 睡眠
      '🍎', // 健康的な食事
      '🍽️', // 食事
      '💧', // 水分補給
      '🧹', // 掃除
      '🏠', // 家事
      '🪥', // 歯磨き
      '🛁', // 入浴
      '🛏️', // 就寝
      // 趣味・娯楽系
      '🎨', // アート・創作
      '🎵', // 音楽
      '🎮', // ゲーム
      '📷', // 写真
      '🎸', // 楽器演奏
      '📝', // 日記
      // メンタルケア系
      '❤️', // セルフケア
      '🌱', // 成長
      '☕', // リラックス
      '🌟', // ポジティブ
      '🙏', // 感謝
      // その他
      '⚽', // スポーツ
      '🌞', // 朝活
      '🌙', // 夜活
      '🪇', // マラカス（その他楽器）
    ],
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.emoji, // 絵文字
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Wrap について:
        // 子要素を横に並べてスペースが足りなくなったら自動で改行する
        Wrap(
          spacing: 8, // 横の間隔
          runSpacing: 8, // 縦の間隔
          children: availableEmojis.map((emoji) {
            // 選択中の絵文字かどうか
            final isSelected = selectedEmoji == emoji;

            return GestureDetector(
              // GestureDetector について:
              // タップなどのジェスチャーを検知する
              onTap: () => onEmojiSelected(emoji),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.purple.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  border: isSelected
                      ? Border.all(color: Colors.purple, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
