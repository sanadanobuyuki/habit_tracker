import 'package:flutter/material.dart';

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

  // 利用可能な絵文字リスト
  final List<String> availableEmojis;

  const EmojiSelector({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
    this.availableEmojis = const [
      '🏃‍♂️',
      '📚',
      '🧘‍♀️',
      '🍎',
      '💧',
      '🛏️',
      '📝',
      '🎨',
      '🎵',
      '💪',
      '🧹',
      '🎮',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '絵文字',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      // ignore: deprecated_member_use
                      ? Colors.purple.withOpacity(0.2)
                      // ignore: deprecated_member_use
                      : Colors.grey.withOpacity(0.1),
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
