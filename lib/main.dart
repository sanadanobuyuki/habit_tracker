import 'package:flutter/material.dart';
import 'package:habit_tracker/data/achievement_data.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
// ignore: duplicate_import
import 'data/achievement_data.dart';
import 'providers/theme_provider.dart';
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
    return ChangeNotifierProvider(
      create: (context) {
        final provider = ThemeProvider();
        // アプリ起動時にテーマを読み込む
        provider.loadTheme();
        return provider;
      },
      // Consumer を MaterialApp の中に移動することで、
      // テーマ変更時に MaterialApp 自体は再構築されず、
      // theme プロパティだけが更新される
      child: const _MaterialAppWithTheme(),
    );
  }
}

/// MaterialApp をラップして、theme だけを監視
///
/// これにより、テーマ変更時に MaterialApp が再構築されず、
/// ナビゲーションスタック（画面履歴）が保持される
class _MaterialAppWithTheme extends StatelessWidget {
  const _MaterialAppWithTheme();

  @override
  Widget build(BuildContext context) {
    // Selector を使って theme だけを監視
    // Consumer と違い、指定したプロパティだけを監視できる
    return Selector<ThemeProvider, ThemeData>(
      // どのプロパティを監視するか
      selector: (context, themeProvider) =>
          themeProvider.currentTheme.themeData,
      // theme が変更された時だけ再構築
      builder: (context, themeData, child) {
        return MaterialApp(
          // title = アプリ名
          title: 'ハビコツ',

          //debugフラグを消すやつ
          debugShowCheckedModeBanner: false,

          // theme = アプリ全体のテーマ設定
          // ThemeProvider から現在のテーマを取得
          theme: themeData,

          // home = 最初に表示する画面
          home: child,
        );
      },
      // child は再利用されるため、MainScreen は再構築されない
      child: const MainScreen(),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "ホーム"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "カレンダー",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "実績"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
        ],
      ),
    );
  }
}
