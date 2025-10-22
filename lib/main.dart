import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/home/home_screen.dart';

/// async について:
/// データベース初期化などの時間がかかる処理があるため、
/// asyncをつける
void main() async {
  // WidgetsFlutterBinding.ensureInitialized() について:
  /// Flutterの初期化を行う
  /// データベースやプラグインを使う前に必ず実行する必要がある
  WidgetsFlutterBinding.ensureInitialized();

  // データベースの初期化
  // await = データベースが開くまで待つ
  await DatabaseService().database;

  // アプリを起動
  // runApp() = Flutterアプリを起動する関数
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title = アプリ名
      title: 'ハビコツ',

      // theme = アプリ全体のテーマ設定
      theme: ThemeData(
        // primarySwatch = メインカラー
        // Colors.purple = 紫色
        primarySwatch: Colors.purple,

        // useMaterial3 = Material Design 3を使用
        // trueにすると、より現代的なデザインになる
        useMaterial3: true,
      ),

      // home = 最初に表示する画面
      // HomeScreen() = ホーム画面を表示
      home: const HomeScreen(),
    );
  }
}
