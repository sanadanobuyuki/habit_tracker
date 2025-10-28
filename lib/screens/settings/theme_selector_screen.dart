import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

/// ThemeSelectorScreen
///
/// 役割:
/// - テーマ選択画面を表示
/// - 利用可能なテーマを一覧表示
/// - テーマのプレビューと選択
class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('テーマ選択')),
      body: Consumer<ThemeProvider>(
        // Consumer について:
        // ThemeProvider の変更を監視して、変更があったら自動で再描画
        builder: (context, themeProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: themeProvider.themes.length,
            itemBuilder: (context, index) {
              final theme = themeProvider.themes[index];
              final isSelected = themeProvider.currentThemeId == theme.id;

              return _buildThemeCard(
                context,
                theme,
                isSelected,
                () => themeProvider.setTheme(theme.id),
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
  /// 小さな四角でテーマの色を表示
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
        child: Column(
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
        ),
      ),
    );
  }
}
