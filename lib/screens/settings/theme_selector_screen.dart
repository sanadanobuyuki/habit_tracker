import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../../widgets/pattern_backgrounds.dart';
import '../../../widgets/themed_scaffold.dart';

/// ThemeSelectorScreen
///
/// 役割:
/// - テーマ選択画面を表示
/// - 利用可能なテーマを一覧表示
/// - テーマのプレビューと選択（パターン背景対応）
/// - ロックされたテーマは選択不可
class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ThemedScaffold(
      appBar: AppBar(title: Text(l10n.themeSelection)), // テーマ選択
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // アンロック済みとロック中のテーマを分ける
          final unlockedThemes = themeProvider.themes
              .where((theme) => themeProvider.isThemeUnlocked(theme.id))
              .toList();
          final lockedThemes = themeProvider.themes
              .where((theme) => !themeProvider.isThemeUnlocked(theme.id))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // アンロック済みセクション
              if (unlockedThemes.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  title: l10n.availableThemes, // 利用可能なテーマ
                  count: unlockedThemes.length,
                ),
                const SizedBox(height: 12),
                ...unlockedThemes.map((theme) {
                  final isSelected = themeProvider.currentThemeId == theme.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildThemeCard(
                      context,
                      theme,
                      isSelected,
                      false, // isLocked = false
                      () => themeProvider.setTheme(theme.id),
                    ),
                  );
                }),
              ],

              // ロック中セクション
              if (lockedThemes.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                  context,
                  icon: Icons.lock,
                  iconColor: Colors.orange,
                  title: l10n.lockedThemes, // ロック中のテーマ
                  count: lockedThemes.length,
                ),
                const SizedBox(height: 8),
                // ヒントメッセージ
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.unlockByAchievement, // 実績解除で利用可能
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...lockedThemes.map((theme) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildThemeCard(
                      context,
                      theme,
                      false, // isSelected = false
                      true, // isLocked = true
                      () => _showLockedDialog(context, theme),
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  // セクションヘッダーを作成
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }

  /// ロックされたテーマをタップした時のダイアログ
  void _showLockedDialog(BuildContext context, AppTheme theme) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.themeLocked, // テーマがロックされています
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.themeLockedMessage(l10n.themeName(theme.id)),
          // テーマ「$themeName」を使用するには、特定の実績を解除する必要があります。
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  /// テーマカードを作成
  Widget _buildThemeCard(
    BuildContext context,
    AppTheme theme,
    bool isSelected,
    bool isLocked,
    VoidCallback onTap,
  ) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isSelected ? 4 : (isLocked ? 0 : 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : (isLocked
                  // ignore: deprecated_member_use
                  ? BorderSide(color: Colors.orange.withOpacity(0.3), width: 1)
                  : BorderSide.none),
      ),
      // ロックされている場合は背景色を変更
      // ignore: deprecated_member_use
      color: isLocked ? Colors.grey.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // テーマのプレビュー
              Stack(
                children: [
                  _buildThemePreview(context, theme, isLocked),
                  // ロック時のオーバーレイ
                  if (isLocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // テーマ情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.themeName(theme.id), // テーマ名を多言語化
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLocked
                                  ? Colors.grey
                                  : (isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface),
                            ),
                          ),
                        ),
                        // ロックバッジ
                        if (isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                // ignore: deprecated_member_use
                                color: Colors.orange.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: Colors.orange[700],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.locked, // ロック中
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.themeDescription(theme.id), // テーマ説明を多言語化
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked
                            ? Colors.grey
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isLocked) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.orange[700],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              l10n.availableByAchievement, // 実績解除で利用可能
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 選択中のマーク（アンロック済みのみ）
              if (isSelected && !isLocked)
                Icon(Icons.check_circle, color: colorScheme.primary, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// テーマのプレビューを作成
  Widget _buildThemePreview(
    BuildContext context,
    AppTheme theme,
    bool isLocked,
  ) {
    final borderColor = isLocked
        // ignore: deprecated_member_use
        ? Colors.orange.withOpacity(0.3)
        : Theme.of(context).colorScheme.outline;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isLocked ? 2 : 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildPatternPreview(theme),
      ),
    );
  }

  /// パターンに応じたプレビューを生成
  Widget _buildPatternPreview(AppTheme theme) {
    switch (theme.pattern) {
      case BackgroundPattern.checkered:
        return CustomPaint(
          painter: CheckeredPainter(
            color1: theme.patternColors?[0] ?? Colors.white,
            color2: theme.patternColors?[1] ?? Colors.grey,
            squareSize: 10.0,
          ),
        );

      case BackgroundPattern.dotted:
        return CustomPaint(
          painter: DottedPainter(
            backgroundColor: theme.patternColors?[0] ?? Colors.white,
            dotColor: theme.patternColors?[1] ?? Colors.grey,
            dotSize: 2.0,
            spacing: 8.0,
          ),
        );

      case BackgroundPattern.striped:
        return CustomPaint(
          painter: StripedPainter(
            colors: theme.patternColors ?? [Colors.white, Colors.grey],
            stripeWidth: 8.0,
            isVertical: theme.isVertical ?? false,
          ),
        );

      case BackgroundPattern.gradient:
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
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: theme.themeData.appBarTheme.backgroundColor,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(color: theme.themeData.scaffoldBackgroundColor),
            ),
          ],
        );
    }
  }
}
