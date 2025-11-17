import 'package:flutter/material.dart';
import '../services/database_service.dart';

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
  final List<AppTheme> _themes = [
    AppTheme(
      id: 'light',
      name: 'ライト',
      description: '明るいテーマ',
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
class AppTheme {
  final String id;
  final String name;
  final String description;
  final ThemeData themeData;

  AppTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.themeData,
  });
}
