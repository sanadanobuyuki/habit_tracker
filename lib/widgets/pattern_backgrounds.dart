import 'package:flutter/material.dart';

/// パターン背景ウィジェット集
///
/// 役割:
/// - チェック柄、ドット柄、ストライプ、グラデーションの背景を描画
/// - CustomPainter を使って効率的に描画
///
/// ファイルの場所: lib/widgets/pattern_backgrounds.dart

// ========================================
// チェック柄背景
// ========================================

/// チェック柄の背景を描画するウィジェット
///
/// 使い方:
/// CheckeredBackground(
///   color1: Colors.white,
///   color2: Colors.grey.shade200,
///   squareSize: 30.0,
///   child: YourWidget(),
/// )
class CheckeredBackground extends StatelessWidget {
  final Widget child;
  final Color color1;
  final Color color2;
  final double squareSize;

  const CheckeredBackground({
    Key? key,
    required this.child,
    this.color1 = Colors.white,
    this.color2 = const Color(0xFFF5F5F5),
    this.squareSize = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // チェック柄の背景
        Positioned.fill(
          child: CustomPaint(
            painter: CheckeredPainter(
              color1: color1,
              color2: color2,
              squareSize: squareSize,
            ),
          ),
        ),
        // 実際のコンテンツ
        child,
      ],
    );
  }
}

/// チェック柄を描画するPainter
///
/// CustomPainter について:
/// - Canvas に直接図形を描画するための仕組み
/// - paint メソッドで描画処理を記述
/// - shouldRepaint でパフォーマンス最適化
class CheckeredPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double squareSize;

  CheckeredPainter({
    required this.color1,
    required this.color2,
    required this.squareSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    // 画面全体をチェック柄で埋める
    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        // チェック柄のパターン計算
        // 行と列が両方偶数または両方奇数の時に色1を使用
        final isEvenRow = ((y / squareSize).floor() % 2) == 0;
        final isEvenCol = ((x / squareSize).floor() % 2) == 0;
        final useColor1 = isEvenRow == isEvenCol;

        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          useColor1 ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CheckeredPainter oldDelegate) {
    // プロパティが変更された場合のみ再描画
    return oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.squareSize != squareSize;
  }
}

// ========================================
// ドット柄背景
// ========================================

/// ドット柄の背景を描画するウィジェット
///
/// 使い方:
/// DottedBackground(
///   backgroundColor: Colors.white,
///   dotColor: Colors.pink.shade100,
///   dotSize: 6.0,
///   spacing: 25.0,
///   child: YourWidget(),
/// )
class DottedBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color dotColor;
  final double dotSize;
  final double spacing;

  const DottedBackground({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.dotColor = const Color(0xFFE0E0E0),
    this.dotSize = 4.0,
    this.spacing = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: DottedPainter(
              backgroundColor: backgroundColor,
              dotColor: dotColor,
              dotSize: dotSize,
              spacing: spacing,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// ドット柄を描画するPainter
class DottedPainter extends CustomPainter {
  final Color backgroundColor;
  final Color dotColor;
  final double dotSize;
  final double spacing;

  DottedPainter({
    required this.backgroundColor,
    required this.dotColor,
    required this.dotSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 背景色を塗る
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // ドットを描画
    final dotPaint = Paint()..color = dotColor;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(DottedPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.spacing != spacing;
  }
}

// ========================================
// ストライプ背景
// ========================================

/// ストライプ背景を描画するウィジェット
///
/// 使い方:
/// StripedBackground(
///   colors: [Colors.green.shade100, Colors.green.shade200],
///   stripeWidth: 40.0,
///   isVertical: false,  // false=横ストライプ, true=縦ストライプ
///   child: YourWidget(),
/// )
class StripedBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final double stripeWidth;
  final bool isVertical;

  const StripedBackground({
    Key? key,
    required this.child,
    required this.colors,
    this.stripeWidth = 20.0,
    this.isVertical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: StripedPainter(
              colors: colors,
              stripeWidth: stripeWidth,
              isVertical: isVertical,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// ストライプを描画するPainter
class StripedPainter extends CustomPainter {
  final List<Color> colors;
  final double stripeWidth;
  final bool isVertical;

  StripedPainter({
    required this.colors,
    required this.stripeWidth,
    required this.isVertical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxDimension = isVertical ? size.width : size.height;
    int colorIndex = 0;

    // ストライプを描画
    for (
      double position = 0;
      position < maxDimension;
      position += stripeWidth
    ) {
      final paint = Paint()..color = colors[colorIndex % colors.length];

      if (isVertical) {
        // 縦ストライプ
        canvas.drawRect(
          Rect.fromLTWH(position, 0, stripeWidth, size.height),
          paint,
        );
      } else {
        // 横ストライプ
        canvas.drawRect(
          Rect.fromLTWH(0, position, size.width, stripeWidth),
          paint,
        );
      }

      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(StripedPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.isVertical != isVertical;
  }
}

// ========================================
// グラデーション背景
// ========================================

/// グラデーション背景を描画するウィジェット
///
/// 使い方:
/// GradientBackground(
///   colors: [Colors.orange, Colors.yellow, Colors.teal],
///   child: YourWidget(),
/// )
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    Key? key,
    required this.child,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: begin, end: end, colors: colors),
      ),
      child: child,
    );
  }
}
