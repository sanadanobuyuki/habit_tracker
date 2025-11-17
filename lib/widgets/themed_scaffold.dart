import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'pattern_backgrounds.dart';

/// ThemedScaffold
///
/// 役割:
/// - Scaffold を拡張して、自動的にパターン背景を適用
/// - ThemeProvider から現在のテーマを取得し、適切な背景を表示
///
/// 使い方:
/// Scaffold の代わりに ThemedScaffold を使うだけ
///
/// 例:
/// ThemedScaffold(
///   appBar: AppBar(title: Text('タイトル')),
///   body: YourWidget(),
///   bottomNavigationBar: BottomNavigationBar(...),
/// )
///
/// ファイルの場所: lib/widgets/themed_scaffold.dart
class ThemedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;

  const ThemedScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ThemeProvider から現在のテーマを取得
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    // デフォルトは body をそのまま表示
    Widget backgroundWidget = body;

    // パターンに応じて背景を変更
    switch (theme.pattern) {
      case BackgroundPattern.checkered:
        // チェック柄背景を適用
        backgroundWidget = CheckeredBackground(
          color1: theme.patternColors?[0] ?? Colors.white,
          color2: theme.patternColors?[1] ?? const Color(0xFFF5F5F5),
          squareSize: theme.squareSize ?? 20.0,
          child: body,
        );
        break;

      case BackgroundPattern.dotted:
        // ドット柄背景を適用
        backgroundWidget = DottedBackground(
          backgroundColor: theme.patternColors?[0] ?? Colors.white,
          dotColor: theme.patternColors?[1] ?? const Color(0xFFE0E0E0),
          dotSize: theme.dotSize ?? 4.0,
          spacing: theme.spacing ?? 20.0,
          child: body,
        );
        break;

      case BackgroundPattern.striped:
        // ストライプ背景を適用
        backgroundWidget = StripedBackground(
          colors:
              theme.patternColors ?? [Colors.white, const Color(0xFFF5F5F5)],
          stripeWidth: theme.stripeWidth ?? 20.0,
          isVertical: theme.isVertical ?? false,
          child: body,
        );
        break;

      case BackgroundPattern.gradient:
        // グラデーション背景を適用
        backgroundWidget = GradientBackground(
          colors: theme.patternColors ?? [Colors.white, Colors.blue.shade100],
          child: body,
        );
        break;

      case BackgroundPattern.solid:
      default:
        // 単色の場合は何もしない（ThemeData の scaffoldBackgroundColor が使われる）
        break;
    }

    return Scaffold(
      appBar: appBar,
      body: backgroundWidget,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      // パターン背景の場合のみ透明にする
      // 単色テーマの場合は null にして ThemeData の scaffoldBackgroundColor を使う
      backgroundColor: theme.pattern == BackgroundPattern.solid
          ? null
          : Colors.transparent,
    );
  }
}

/// テーマ選択画面
///
/// 役割:
/// - すべてのテーマを一覧表示
/// - テーマのプレビューを表示
/// - タップでテーマを変更
///
/// 使い方:
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => ThemeSelectionScreen()),
/// );
class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ThemedScaffold(
      appBar: AppBar(title: const Text('テーマ選択')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themeProvider.themes.length,
        itemBuilder: (context, index) {
          final theme = themeProvider.themes[index];
          final isSelected = theme.id == themeProvider.currentThemeId;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isSelected ? 8 : 2,
            child: InkWell(
              onTap: () async {
                await themeProvider.setTheme(theme.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // テーマプレビュー
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: _buildThemePreview(theme),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // テーマ情報
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    // 選択インジケータ
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// テーマのプレビューを生成
  Widget _buildThemePreview(AppTheme theme) {
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
              colors: theme.patternColors ?? [Colors.white, Colors.blue],
            ),
          ),
        );

      case BackgroundPattern.solid:
      default:
        return Container(color: theme.themeData.scaffoldBackgroundColor);
    }
  }
}
