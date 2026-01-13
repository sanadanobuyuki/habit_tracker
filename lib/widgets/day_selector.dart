import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

/// DaySelector
///
/// 役割:
/// - 曜日選択UIを提供
/// - 毎日 / 曜日指定の切り替え機能
/// - 再利用可能なウィジェット
class DaySelector extends StatelessWidget {
  final bool isEveryDay;
  final List<int> selectedDays;
  final Function(bool) onEveryDayChanged;
  final Function(int) onDayToggle;

  const DaySelector({
    super.key,
    required this.isEveryDay,
    required this.selectedDays,
    required this.onEveryDayChanged,
    required this.onDayToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.daysOfWeek,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // 毎日 / 曜日指定の切り替えボタン
        _buildToggleButtons(l10n),

        // 曜日選択UI（曜日指定の場合のみ表示）
        if (!isEveryDay) ...[
          const SizedBox(height: 16),
          _buildDayButtons(l10n),
        ],
      ],
    );
  }

  /// 毎日 / 曜日指定の切り替えボタン
  Widget _buildToggleButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onEveryDayChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isEveryDay
                    ? Colors.purple
                    // ignore: deprecated_member_use
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  l10n.everyday,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isEveryDay ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onEveryDayChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !isEveryDay
                    ? Colors.purple
                    // ignore: deprecated_member_use
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  l10n.selectDays,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: !isEveryDay ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 曜日選択ボタン
  Widget _buildDayButtons(AppLocalizations l10n) {
    // 曜日の名前リスト（多言語対応）
    final dayNames = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayNumber = index + 1; // 1〜7
        final isSelected = selectedDays.contains(dayNumber);

        return GestureDetector(
          onTap: () => onDayToggle(dayNumber),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.purple
                  // ignore: deprecated_member_use
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.purple, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                dayNames[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
