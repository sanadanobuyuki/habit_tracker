import 'package:flutter/material.dart';

/// CompletionRateCard クラス
///
/// 役割:
/// - 今日の達成率をサマリー表示
/// - グラデーション背景で視覚的に魅力的に
/// - 達成数と総数も表示
class CompletionRateCard extends StatelessWidget {
  final double completionRate; // 達成率（0.0 〜 1.0）
  final int completedCount; // 達成した習慣の数
  final int totalCount; // 今日対象の習慣の総数

  const CompletionRateCard({
    super.key,
    required this.completionRate,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    // パーセンテージに変換（0〜100）
    final percentage = (completionRate * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // グラデーション背景
        // 100%の場合は特別な金色グラデーション
        gradient: completionRate >= 1.0
            ? _glowingGoldGradient()
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getGradientColor1(completionRate),
                  _getGradientColor2(completionRate),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        // 影を追加
        boxShadow: [
          BoxShadow(
            color: completionRate >= 1.0
                // ignore: deprecated_member_use
                ? const Color(0xFFFFD700).withOpacity(0.4)
                // ignore: deprecated_member_use
                : _getGradientColor1(completionRate).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // タイトル
          const Text(
            '今日の達成率',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // パーセンテージ（大きく表示）
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          // 達成数/総数
          Text(
            '$completedCount/$totalCount 完了',
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // プログレスバー
          _buildProgressBar(completionRate),
        ],
      ),
    );
  }

  /// 金色のグラデーション定義（100%達成時）
  ///
  /// カレンダーで使っている金色と同じグラデーション
  LinearGradient _glowingGoldGradient() {
    return const LinearGradient(
      // begin グラデーションを始める位置
      begin: Alignment.topLeft,
      // end グラデーションを終える位置
      end: Alignment.bottomRight,
      // stops グラデーションの各色が始まる位置を0.0から1.0の範囲で指定
      stops: [0.0, 0.45, 0.7, 1.0],
      colors: [
        Color(0xFFFFF8E1), // 強いハイライト（光）
        Color(0xFFFFE082), // 明るい金
        Color(0xFFD4AF37), // ベース金
        Color(0xFFB8962E), // 影
      ],
    );
  }

  /// プログレスバーを作成
  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// 達成率に応じたグラデーション色1を取得
  ///
  /// カレンダーのヒートマップと同じ色階調を使用
  /// 達成率によって色が段階的に変化
  ///
  /// 注意: 100%の場合は _glowingGoldGradient() を使用するため、
  /// この関数は呼ばれない
  Color _getGradientColor1(double rate) {
    if (rate >= 0.81) {
      // 81〜99%: 濃い緑
      return const Color(0xFF2E7D32);
    } else if (rate >= 0.61) {
      // 61〜80%: 中間の緑
      return const Color(0xFF66BB6A);
    } else if (rate >= 0.41) {
      // 41〜60%: 黄色
      return const Color(0xFFFFEB3B);
    } else if (rate >= 0.21) {
      // 21〜40%: オレンジ
      return const Color(0xFFFFB74D);
    } else if (rate > 0) {
      // 1〜20%: ピンク
      return const Color(0xFFFFABAB);
    } else {
      // 0%（未記録）: グレー
      return const Color(0xFFE0E0E0);
    }
  }

  /// 達成率に応じたグラデーション色2を取得
  ///
  /// グラデーション効果のため、色1より少し明るい色を返す
  ///
  /// 注意: 100%の場合は _glowingGoldGradient() を使用するため、
  /// この関数は呼ばれない
  Color _getGradientColor2(double rate) {
    if (rate >= 0.81) {
      // 81〜99%: 明るい濃い緑
      return const Color(0xFF4CAF50);
    } else if (rate >= 0.61) {
      // 61〜80%: 明るい緑
      return const Color(0xFF81C784);
    } else if (rate >= 0.41) {
      // 41〜60%: 明るい黄色
      return const Color(0xFFFFF176);
    } else if (rate >= 0.21) {
      // 21〜40%: 明るいオレンジ
      return const Color(0xFFFFCC80);
    } else if (rate > 0) {
      // 1〜20%: 明るいピンク
      return const Color(0xFFFFCDD2);
    } else {
      // 0%（未記録）: 明るいグレー
      return const Color(0xFFEEEEEE);
    }
  }
}
