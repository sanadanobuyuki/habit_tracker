import 'package:flutter/material.dart';

/// FrequencySelector
///
/// 役割:
/// - 目標頻度選択UIを提供
/// - +/- ボタンで頻度を調整
/// - 再利用可能なウィジェット
class FrequencySelector extends StatelessWidget {
  final int targetFrequency;
  final Function(int) onFrequencyChanged;
  final int minFrequency;
  final int maxFrequency;

  const FrequencySelector({
    super.key,
    required this.targetFrequency,
    required this.onFrequencyChanged,
    this.minFrequency = 1,
    this.maxFrequency = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '目標頻度(週あたり)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // IconButton について:
            // アイコンをボタンにする
            // マイナスボタン
            IconButton(
              onPressed: targetFrequency > minFrequency
                  ? () => onFrequencyChanged(targetFrequency - 1)
                  : null, // 最小値以下にはできない
              icon: const Icon(Icons.remove_circle_outline),
            ),

            // 現在の頻度表示
            Container(
              width: 80,
              height: 48,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$targetFrequency回',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // プラスボタン
            IconButton(
              onPressed: targetFrequency < maxFrequency
                  ? () => onFrequencyChanged(targetFrequency + 1)
                  : null, // 最大値以上にはできない
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}
