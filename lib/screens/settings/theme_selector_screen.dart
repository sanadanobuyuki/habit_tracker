import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/pattern_backgrounds.dart';
import '../../../widgets/themed_scaffold.dart';

/// ThemeSelectorScreen
///
/// 役割:
/// - テーマ選択画面を表示
/// - 利用可能なテーマを一覧表示
/// - テーマのプレビューと選択（パターン背景対応）
class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider を一度だけ取得（listen: false で監視しない）
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return ThemedScaffold(
      appBar: AppBar(title: const Text('テーマ選択')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themeProvider.themes.length,
        itemBuilder: (context, index) {
          final theme = themeProvider.themes[index];

          // Consumer をカード単位で使用して、選択状態だけを監視
          return Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              final isSelected = provider.currentThemeId == theme.id;

              return _buildThemeCard(
                context,
                theme,
                isSelected,
                () => provider.setTheme(theme.id),
              );
            },
          );
        },
      ),
    );
  }

  /// テーマカードを作成
  ///
  /// 引数:
  /// - context: ビルドコンテキスト
  /// - theme: テーマ情報
  /// - isSelected: 選択中かどうか
  /// - onTap: タップ時の処理
  Widget _buildThemeCard(
    BuildContext context,
    AppTheme theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        // InkWell について:
        // タップ時に波紋エフェクトを表示する
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // テーマのプレビュー
              _buildThemePreview(theme),
              const SizedBox(width: 16),

              // テーマ情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // 選択中のマーク
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// テーマのプレビューを作成
  ///
  /// パターン背景も含めてプレビューを表示
  Widget _buildThemePreview(AppTheme theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildPatternPreview(theme),
      ),
    );
  }

  /// パターンに応じたプレビューを生成
  Widget _buildPatternPreview(AppTheme theme) {
    // パターンごとに異なるプレビューを表示
    switch (theme.pattern) {
      case BackgroundPattern.checkered:
        // チェック柄のプレビュー
        return CustomPaint(
          painter: CheckeredPainter(
            color1: theme.patternColors?[0] ?? Colors.white,
            color2: theme.patternColors?[1] ?? Colors.grey,
            squareSize: 10.0, // プレビュー用に小さめに設定
          ),
        );

      case BackgroundPattern.dotted:
        // ドット柄のプレビュー
        return CustomPaint(
          painter: DottedPainter(
            backgroundColor: theme.patternColors?[0] ?? Colors.white,
            dotColor: theme.patternColors?[1] ?? Colors.grey,
            dotSize: 2.0, // プレビュー用に小さめに設定
            spacing: 8.0, // プレビュー用に狭めに設定
          ),
        );

      case BackgroundPattern.striped:
        // ストライプのプレビュー
        return CustomPaint(
          painter: StripedPainter(
            colors: theme.patternColors ?? [Colors.white, Colors.grey],
            stripeWidth: 8.0, // プレビュー用に狭めに設定
            isVertical: theme.isVertical ?? false,
          ),
        );

      case BackgroundPattern.gradient:
        // グラデーションのプレビュー
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.patternColors ?? [Colors.white, Colors.blue],
            ),
          ),
        );

      case BackgroundPattern.solid:
      default:
        // 単色の場合は従来のプレビュー（AppBarと背景色）
        return Column(
          children: [
            // AppBarの色
            Expanded(
              flex: 1,
              child: Container(
                color: theme.themeData.appBarTheme.backgroundColor,
              ),
            ),
            // 背景色
            Expanded(
              flex: 2,
              child: Container(color: theme.themeData.scaffoldBackgroundColor),
            ),
          ],
        );
    }
  }
}
