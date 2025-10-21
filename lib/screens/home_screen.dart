import 'package:flutter/material.dart';
import '../serbices/detabase_service.dart';
import '../models/habit.dart';

//HomeScreenクラス

//役割
// アプリのホーム画面を表示する
//

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];

  //ローディング中かどうか
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits(); //習慣データをロード
  }

  //習慣を読みこむ
  //処理の流れ
  //1.データベースからすべての習慣を取得
  //2.MapのリストをHabitオブジェクトのリストに変換
  //3.画面を更新

  Future<void> _loadHabits() async {
    //データべースサービスのインスタンスを作成
    final db = DatabaseService();

    //データベースからすべての習慣を取得
    final habitsData = await db.getAllHabits();

    //MapのリストをHabitオブジェクトのリストに変換
    final habits = habitsData.map((data) => Habit.fromMap(data)).toList();

    //画面を更新
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('ハビコツ')));
  }
}
