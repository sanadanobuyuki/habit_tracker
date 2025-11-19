import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'pattern_backgrounds.dart';

/// ThemedScaffold
///
/// 役割:
/// - Scaffold を拡張して、自動的にパターン背景を適用
/// - ThemeProvider から現在のテーマを取得し、適切な背景を表示
/// - Selector を使って、パターン情報だけを監視することで、
///   スクロール位置を保持したまま背景を即座に更新
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
    return Scaffold(
      appBar: appBar,
      // body を Stack で重ねる
      // 背景レイヤーだけを Selector で監視
      body: Stack(
        children: [
          // 背景レイヤー（Selector で監視）
          Selector<ThemeProvider, AppTheme>(
            selector: (context, themeProvider) => themeProvider.currentTheme,
            shouldRebuild: (previous, next) {
              return previous.pattern != next.pattern ||
                  previous.patternColors != next.patternColors ||
                  previous.squareSize != next.squareSize ||
                  previous.dotSize != next.dotSize ||
                  previous.spacing != next.spacing ||
                  previous.stripeWidth != next.stripeWidth ||
                  previous.isVertical != next.isVertical;
            },
            builder: (context, theme, _) {
              return _buildBackground(theme);
            },
          ),
          // コンテンツレイヤー（再構築されない）
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: Colors.transparent,
    );
  }

  /// 背景ウィジェットを構築
  Widget _buildBackground(AppTheme theme) {
    switch (theme.pattern) {
      case BackgroundPattern.checkered:
        return Positioned.fill(
          child: CheckeredBackground(
            color1: theme.patternColors?[0] ?? Colors.white,
            color2: theme.patternColors?[1] ?? const Color(0xFFF5F5F5),
            squareSize: theme.squareSize ?? 20.0,
            child: Container(), // 空のコンテナ
          ),
        );

      case BackgroundPattern.dotted:
        return Positioned.fill(
          child: DottedBackground(
            backgroundColor: theme.patternColors?[0] ?? Colors.white,
            dotColor: theme.patternColors?[1] ?? const Color(0xFFE0E0E0),
            dotSize: theme.dotSize ?? 4.0,
            spacing: theme.spacing ?? 20.0,
            child: Container(),
          ),
        );

      case BackgroundPattern.striped:
        return Positioned.fill(
          child: StripedBackground(
            colors:
                theme.patternColors ?? [Colors.white, const Color(0xFFF5F5F5)],
            stripeWidth: theme.stripeWidth ?? 20.0,
            isVertical: theme.isVertical ?? false,
            child: Container(),
          ),
        );

      case BackgroundPattern.gradient:
        return Positioned.fill(
          child: GradientBackground(
            colors: theme.patternColors ?? [Colors.white, Colors.blue.shade100],
            child: Container(),
          ),
        );

      case BackgroundPattern.solid:
        // 単色の場合は ThemeData の背景色を使用
        return Container(color: theme.themeData.scaffoldBackgroundColor);
    }
  }
}
