import 'package:flutter/material.dart';
import '../services/database_service.dart';
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
    //テスト
    // _addTestHabits(); // テストデータ追加
    _loadHabits(); //習慣データをロード
  }

  // テストデータ追加用の関数
  // Future<void> _addTestHabits() async {
  //   final db = DatabaseService();

  //   try {
  //     // テスト習慣1
  //     await db.insertHabit(
  //       id: 'habit_001',
  //       name: '朝の運動',
  //       emoji: '🏃‍♂️',
  //       color: 0xFFEF4444,
  //       targetFrequency: 7,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //     );

  //     // テスト習慣2
  //     await db.insertHabit(
  //       id: 'habit_002',
  //       name: '読書30分',
  //       emoji: '📚',
  //       color: 0xFF3B82F6,
  //       targetFrequency: 5,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //     );
  //   } catch (e) {
  //     // 既にデータがある場合はエラーになるが問題なし
  //     print('テストデータ追加: $e');
  //   }
  // }

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
    return Scaffold(
      appBar: AppBar(title: const Text('ハビコツ')),
      body: _isLoading
          //ローディング中ならぐるぐる回るアイコンを表示
          ? const Center(child: CircularProgressIndicator())
          //ローディング後完了後の表示
          : _habits.isEmpty
          //習慣がない場合の表示
          ? _buildEmptyView()
          //習慣がある場合の表示
          : _buildHabitList(),
    );
  }

  //習慣がない場合の表示
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          //Icon=アイコンを表示
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16), // 縦の余白
          Text(
            '習慣がまだありません',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '右下の + ボタンから追加しましょう',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 習慣リストを表示
  ///
  /// ListView.builder について:
  /// リストを効率的に表示する
  /// itemCount = リストの項目数
  /// itemBuilder = 各項目をどう表示するか
  Widget _buildHabitList() {
    return ListView.builder(
      // padding = リスト全体の余白
      padding: const EdgeInsets.all(16),

      // itemCount = 表示する項目の数
      itemCount: _habits.length,

      // itemBuilder = 各項目をどう表示するか
      // context = 画面の情報
      // index = 何番目の項目か（0から始まる）
      itemBuilder: (context, index) {
        final habit = _habits[index];

        // _buildHabitCard() で習慣カードを作成
        return _buildHabitCard(habit);
      },
    );
  }

  /// 習慣カードを作成
  ///
  /// Card = 影付きのカード型UI
  /// ListTile = リスト項目の標準的なレイアウト
  Widget _buildHabitCard(Habit habit) {
    return Card(
      // margin = カードの外側の余白
      margin: const EdgeInsets.only(bottom: 12),

      // elevation = 影の深さ
      elevation: 2,

      // shape = カードの形状
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 角を丸くする
      ),

      child: ListTile(
        // contentPadding = 内側の余白
        contentPadding: const EdgeInsets.all(16),

        // leading = 左側に表示する要素
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            // Color() = 色を指定
            // habit.color = データベースに保存されている色コード
            color: Color(habit.color).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(habit.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),

        // title = タイトル部分
        title: Text(
          habit.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        // subtitle = サブタイトル部分
        subtitle: Text(
          '目標: 週${habit.targetFrequency}回',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),

        // trailing = 右側に表示する要素
        trailing: Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: Color(habit.color),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
