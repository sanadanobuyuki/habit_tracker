import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_tracker/data/achievement_data.dart';
import 'package:provider/provider.dart';
//データベース削除の際に必要　コメントアウト推奨
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import 'services/database_service.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/home/home_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/themed_scaffold.dart';

/// async について:
/// データベース初期化などの時間がかかる処理があるため、
/// async をつける
void main() async {
  // WidgetsFlutterBinding.ensureInitialized() について:
  /// Flutter の初期化を行う
  /// データベースやプラグインを使う前に必ず実行する必要がある
  WidgetsFlutterBinding.ensureInitialized();

  // データベースを削除 (開発中のみ)
  // final dbPath = await getDatabasesPath();
  // final path = join(dbPath, 'habit_flow.db');
  // await deleteDatabase(path);

  // データベースの初期化
  // await = データベースが開くまで待つ
  final db = DatabaseService();
  await db.database;

  //実績の初期化
  await insertInitialAchievements(db);

  // アプリを起動
  // runApp() = Flutter アプリを起動する関数
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider について:
    // ThemeProvider を全体で使えるようにする
    // Provider パターンで状態管理を行う
    //言語Providerを追加それに伴いMultiProviderに変更
    return MultiProvider(
      providers: [
        // テーマProvider (既存)
        ChangeNotifierProvider(
          create: (context) {
            final provider = ThemeProvider();
            provider.loadTheme();
            return provider;
          },
        ),
        // 言語Provider (新規追加)
        ChangeNotifierProvider(
          create: (context) {
            final provider = LanguageProvider();
            // アプリ起動時に保存された言語を読み込む
            provider.loadLanguage();
            return provider;
          },
        ),
      ],
      child: const _MaterialAppWithSettings(),
    );
  }
}

/// MaterialApp をラップして、theme とlocaleを監視
///
/// これにより、テーマ変更時に MaterialApp が再構築されず、
/// ナビゲーションスタック（画面履歴）が保持される
class _MaterialAppWithSettings extends StatelessWidget {
  const _MaterialAppWithSettings();

  @override
  Widget build(BuildContext context) {
    //テーマを監視
    // テーマを監視 (既存)
    final themeData = context.select<ThemeProvider, ThemeData>(
      (provider) => provider.currentTheme.themeData,
    );

    // 言語を監視 (新規追加)
    final locale = context.select<LanguageProvider, Locale>(
      (provider) => provider.locale,
    );

    return MaterialApp(
      // title = アプリ名
      title: 'ハビコツ',

      //debugフラグを消すやつ
      debugShowCheckedModeBanner: false,

      // theme = アプリ全体のテーマ設定
      // ThemeProvider から現在のテーマを取得
      theme: themeData,

      // 現在の言語を設定
      locale: locale,

      // 多言語化のための delegate を登録
      localizationsDelegates: const [
        // アプリの翻訳
        AppLocalizations.delegate,
        // マテリアルウィジェットの翻訳 (ボタンなど)
        GlobalMaterialLocalizations.delegate,
        // 基本ウィジェットの翻訳
        GlobalWidgetsLocalizations.delegate,
        // iOSスタイルウィジェットの翻訳
        GlobalCupertinoLocalizations.delegate,
      ],

      // サポートする言語のリスト
      supportedLocales: const [
        Locale('ja'), // 日本語
        Locale('en'), // 英語
      ],

      // home = 最初に表示する画面
      home: const MainScreen(),
    );
  }
}

// MainScreen = BottomNavigationBar を持つメイン画面
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // _currentIndex = 現在選択されているタブのインデックス
  int _currentIndex = 0;

  // _pages = 各タブで表示する画面のリスト
  final List<Widget> _pages = [
    const HomeScreen(),
    const CalendarScreen(),
    const AchievementsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 多言語化テキストを取得
    final l10n = AppLocalizations.of(context);
    // MainScreen では通常の Scaffold を使用
    // （ThemedScaffold を使うと、テーマ変更時に全体が再構築される）
    return ThemedScaffold(
      // body = 現在選択されているタブの画面を表示
      body: _pages[_currentIndex],

      // bottomNavigationBar = 下部のナビゲーションバー
      bottomNavigationBar: BottomNavigationBar(
        // type = ナビゲーションバーのタイプ
        // fixed = 固定表示（3〜5個のタブに適している）
        type: BottomNavigationBarType.fixed,

        // currentIndex = 現在選択されているタブ
        currentIndex: _currentIndex,

        // onTap = タブがタップされたときの処理
        onTap: (int selectedIndex) {
          setState(() {
            _currentIndex = selectedIndex;
          });
        },

        // items = ナビゲーションバーの各タブ
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: l10n.calendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: l10n.achievements,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
