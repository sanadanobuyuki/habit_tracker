import 'package:flutter/material.dart';
import '../services/database_service.dart';

/// 背景パターンの種類
enum BackgroundPattern {
  solid, // 単色
  checkered, // チェック柄
  dotted, // ドット柄
  striped, // ストライプ
  gradient, // グラデーション
}

/// ThemeProvider
///
/// 役割:
/// - アプリ全体のテーマを管理
/// - テーマの切り替えと保存
/// - ChangeNotifier を継承して、テーマ変更を他のウィジェットに通知
///
/// ChangeNotifier について:
/// 状態が変更されたことを他ウィジェットに通知する仕組み
/// notifyListeners()を呼ぶと、このクラスを監視しているすべてのウィジェットが再描画される
/// これにより、テーマ変更時にUIが自動的に更新される
///
/// 使い方
///  //テーマ取得
// ignore: unintended_html_in_doc_comment
/// final themeProvider = Provider.of<ThemeProvider>(context);
/// final currentTheme = themeProvider.currentTheme;
/// //テーマ変更
/// await themeProvider.setTheme('dark');
class ThemeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // 現在のテーマID
  String _currentThemeId = 'light';

  // 利用可能なテーマのリスト
  //
  // パターンテーマの作り方:
  // 1. pattern: 使用するパターンの種類を指定
  //    - BackgroundPattern.solid: 単色（デフォルト）
  //    - BackgroundPattern.checkered: チェック柄
  //    - BackgroundPattern.dotted: ドット柄
  //    - BackgroundPattern.striped: ストライプ
  //    - BackgroundPattern.gradient: グラデーション
  //
  // 2. patternColors: パターンで使用する色のリスト
  //    - checkered: [色1, 色2] の2色を指定
  //    - dotted: [背景色, ドット色] の2色を指定
  //    - striped: [色1, 色2, 色3, ...] 複数色を指定可能
  //    - gradient: [開始色, 中間色, 終了色, ...] 複数色を指定可能
  //
  // 3. パターン固有のプロパティ:
  //    【チェック柄】
  //    - squareSize: チェックの1マスのサイズ（ピクセル）
  //
  //    【ドット柄】
  //    - dotSize: ドットの直径（ピクセル）
  //    - spacing: ドット間の距離（ピクセル）
  //
  //    【ストライプ】
  //    - stripeWidth: ストライプの幅（ピクセル）
  //    - isVertical: true=縦ストライプ, false=横ストライプ
  //
  // 4. scaffoldBackgroundColor の設定:
  //    - パターンを使う場合: Colors.transparent に設定
  //    - 単色の場合: 好きな色を設定
  //
  // 5. cardColor の設定:
  //    - パターン背景の上に配置する場合: withOpacity(0.8～0.95) で半透明にすると見やすい
  //    - 単色背景の場合: 通常の色でOK
  final List<AppTheme> _themes = [
    AppTheme(
      id: 'light',
      name: 'ライト',
      description: '明るいテーマ',
      pattern: BackgroundPattern.solid,
      themeData: ThemeData(
        //brightness について
        //Brightness.light: 明るいテーマ
        //Brightness.dark: 暗いテーマ
        // これにより、システム全体の明るさ設定に応じたUI調整が可能
        brightness: Brightness.light,

        //primarySwatch について
        //アプリの主要な色を設定
        //Material Designのカラーパレットから選択
        primarySwatch: Colors.purple,

        // useMaterial3 について
        //Material Design 3 (MD3) を使用するかどうか
        //trueに設定すると、MD3の新しいデザイン要素やコンポーネントが有効になる
        useMaterial3: true,

        // scaffoldBackgroundColor について
        //画面全体のは背景色を設定
        scaffoldBackgroundColor: Colors.white,

        // cardColor について
        //cardウィジェットの背景色を設定
        cardColor: Colors.white,

        // appBarTheme について
        //AppBarのテーマをカスタマイズ
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'dark',
      name: 'ダーク',
      description: '暗いテーマ',
      pattern: BackgroundPattern.solid,
      themeData: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'blue',
      name: 'ブルー',
      description: '青基調のテーマ',
      pattern: BackgroundPattern.solid,
      themeData: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'green',
      name: 'グリーン',
      description: '緑基調のテーマ',
      pattern: BackgroundPattern.solid,
      themeData: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0FFF4),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'pink',
      name: 'ピンク',
      description: 'ピンク基調のテーマ',
      pattern: BackgroundPattern.solid,
      themeData: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    // パターンテーマの追加例
    AppTheme(
      id: 'checkered_blue',
      name: 'ブルーチェック',
      description: '青いチェック柄',
      pattern: BackgroundPattern.checkered,
      patternColors: [Colors.white, const Color(0xFFE3F2FD)],
      squareSize: 30.0,
      themeData: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        // ignore: deprecated_member_use
        cardColor: Colors.white.withOpacity(0.9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'dotted_pink',
      name: 'ピンクドット',
      description: 'かわいいドット柄',
      pattern: BackgroundPattern.dotted,
      patternColors: [Colors.white, Colors.pink.shade100],
      dotSize: 6.0,
      spacing: 25.0,
      themeData: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        // ignore: deprecated_member_use
        cardColor: Colors.white.withOpacity(0.95),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'striped_green',
      name: 'グリーンストライプ',
      description: '緑のストライプ柄',
      pattern: BackgroundPattern.striped,
      patternColors: [
        const Color(0xFFE8F5E9),
        const Color(0xFFC8E6C9),
        const Color(0xFFA5D6A7),
      ],
      stripeWidth: 40.0,
      isVertical: false,
      themeData: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        // ignore: deprecated_member_use
        cardColor: Colors.white.withOpacity(0.9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'gradient_sunset',
      name: 'サンセット',
      description: '夕焼けグラデーション',
      pattern: BackgroundPattern.gradient,
      patternColors: [
        const Color(0xFFFF6B6B),
        const Color(0xFFFFE66D),
        const Color(0xFF4ECDC4),
      ],
      themeData: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        // ignore: deprecated_member_use
        cardColor: Colors.white.withOpacity(0.85),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    AppTheme(
      id: 'dark_checkered',
      name: 'ダークチェック',
      description: '暗いチェック柄',
      pattern: BackgroundPattern.checkered,
      patternColors: [const Color(0xFF121212), const Color(0xFF1E1E1E)],
      squareSize: 40.0,
      themeData: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        // ignore: deprecated_member_use
        cardColor: const Color(0xFF2C2C2C).withOpacity(0.9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
    ),
  ];

  /// 現在のテーマIDを取得
  String get currentThemeId => _currentThemeId;

  /// 現在のテーマを取得
  /// 1. _themes リストから現在のテーマIDに一致するテーマを検索
  /// 2. 見つからない場合はデフォルトでライトテーマを返す
  AppTheme get currentTheme {
    return _themes.firstWhere(
      //firstWhere について
      // 条件に一致する最初の要素を返す
      (theme) => theme.id == _currentThemeId,
      //条件に一致する要素が見つからなかった場合のデフォルト値
      orElse: () => _themes[0], // デフォルトはライト
    );
  }

  /// すべてのテーマを取得
  List<AppTheme> get themes => _themes;

  /// データベースからテーマ設定を読み込む
  ///
  /// アプリ起動時に呼び出す
  Future<void> loadTheme() async {
    try {
      final themeId = await _db.getSetting('current_theme_id');
      if (themeId != null) {
        _currentThemeId = themeId;
        notifyListeners(); // リスナーに通知
      }
    } catch (e) {
      // エラーの場合はデフォルトテーマを使用
      // ignore: avoid_print
      print('テーマ読み込みエラー: $e');
    }
  }

  /// テーマを変更する
  ///
  /// 引数:
  /// - themeId: 新しいテーマID
  ///
  /// 処理の流れ:
  /// 1. テーマIDを更新
  /// 2. データベースに保存
  /// 3. リスナーに通知（画面を再描画）
  Future<void> setTheme(String themeId) async {
    // テーマが存在するか確認
    final themeExists = _themes.any((theme) => theme.id == themeId);
    if (!themeExists) {
      return;
    }

    _currentThemeId = themeId;

    // データベースに保存
    try {
      await _db.saveSetting('current_theme_id', themeId);
    } catch (e) {
      // ignore: avoid_print
      print('テーマ保存エラー: $e');
    }

    // リスナーに通知（画面を再描画）
    notifyListeners();
  }
}

/// AppTheme
///
/// 役割:
/// - 個別のテーマ情報を保持
/// - パターン情報（チェック柄、ドット柄など）も含む
class AppTheme {
  final String id;
  final String name;
  final String description;
  final ThemeData themeData;

  // パターン関連のプロパティ
  final BackgroundPattern pattern;
  final List<Color>? patternColors;

  // チェック柄用
  final double? squareSize;

  // ドット柄用
  final double? dotSize;
  final double? spacing;

  // ストライプ用
  final double? stripeWidth;
  final bool? isVertical;

  AppTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.themeData,
    this.pattern = BackgroundPattern.solid,
    this.patternColors,
    this.squareSize,
    this.dotSize,
    this.spacing,
    this.stripeWidth,
    this.isVertical,
  });
}
