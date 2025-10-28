import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/settings/settings_screen.dart';

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
  await DatabaseService().database;

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
      child: Consumer<ThemeProvider>(
        // Consumer について:
        // ThemeProvider の変更を監視して、変更があったら自動で再描画
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // title = アプリ名
            title: 'ハビコツ',

            // theme = アプリ全体のテーマ設定
            // ThemeProvider から現在のテーマを取得
            theme: themeProvider.currentTheme.themeData,

            // home = 最初に表示する画面
            home: const MainScreen(),
          );
        },
      ),
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
    return Scaffold(
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
