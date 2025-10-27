import 'package:flutter/material.dart';

/// ColorSelector
///
/// 役割:
/// - 色選択UIを提供
/// - 再利用可能なウィジェット
class ColorSelector extends StatelessWidget {
  final int selectedColor;
  final Function(int) onColorSelected;

  // 利用可能な色リスト
  final List<int> availableColors;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.availableColors = const [
      0xFFFF4444, // 赤
      0xFF3B82F6, // 青
      0xFF10B981, // 緑
      0xFFF59E0B, // 黄
      0xFF8B5CF6, // 紫
      0xFFEC4899, // ピンク
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '色',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableColors.map((color) {
            final isSelected = selectedColor == color;

            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(color),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  // boxShadow について:
                  // 影をつける
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Color(color).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 32)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
