import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/habit.dart';
import 'add_habit.dart';

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
    _addTestHabits(); // テストデータ追加(開発中のみ)
    _loadHabits(); //習慣データをロード
  }

  // テストデータ追加用の関数
  Future<void> _addTestHabits() async {
    final db = DatabaseService();

    try {
      // テスト習慣1
      await db.insertHabit(
        id: 'habit_001',
        name: '朝の運動',
        emoji: '🏃‍♂️',
        color: 0xFFEF4444,
        targetFrequency: 7,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // テスト習慣2
      await db.insertHabit(
        id: 'habit_002',
        name: '読書30分',
        emoji: '📚',
        color: 0xFF3B82F6,
        targetFrequency: 5,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // 既にデータがある場合はエラーになるが問題なし
    }
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

  @override
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

      // FloatingActionButton = 画面右下の丸いボタン
      floatingActionButton: FloatingActionButton(
        // onPressed = ボタンが押されたときの処理
        heroTag: 'add_habit',
        onPressed: () async {
          // 習慣追加画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const AddHabit();
              },
            ),
          );
          _loadHabits();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //習慣がない場合の表示
  Widget _buildEmptyView() {
    return SafeArea(
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
      // index = 何番目の項目か(0から始まる)
      itemBuilder: (context, index) {
        final habit = _habits[index];

        // _buildHabitCard() で習慣カードを作成
        return _buildHabitCard(habit);
      },
    );
  }

  // 習慣カードを作成
  //
  // Card = 影付きのカード型UI
  // ListTile = リスト項目の標準的なレイアウト
  //
  //Dismissible = スワイプで削除可能にするウィジェット
  // key = 各項目を一意に識別するためのキー
  //direction = スワイプ可能な方向
  //background = スワイプ時に表示される背景
  //onDismissed = スワイプで削除されたときの処理
  Widget _buildHabitCard(Habit habit) {
    return Dismissible(
      //key=各カードを識別するための一意のキー
      key: Key(habit.id),
      //direction=スワイプ可能な方向
      direction: DismissDirection.endToStart,
      //background=スワイプ時に表示される背景
      background: Container(
        alignment: Alignment.centerRight,
        // 右側に余白を追加 これがないとゴミ箱アイコンが端にくっついてしまう
        padding: const EdgeInsets.only(right: 20),
        //赤い背景とゴミ箱アイコン
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        //アイコンの表示
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      //confirmDismiss=スワイプで削除する前に確認ダイアログを表示
      confirmDismiss: (direction) async {
        //削除確認ダイアログを表示
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                //タイトル
                title: const Text('習慣を削除'),
                //詳細
                content: Text('「${habit.name}」を削除しますか?'),
                actions: [
                  TextButton(
                    //キャンセルボタン
                    //falseを返して削除しない
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    //削除ボタン
                    //trueを返して削除を実行
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('削除'),
                  ),
                ],
              ),
            ) ??
            // ダイアログが閉じられた場合は削除しない
            false;
      },
      // onDismissed について:
      /// スワイプ完了後に実行される関数
      /// ここでデータベースから削除する
      onDismissed: (direction) async {
        final db = DatabaseService();
        await db.deleteHabit(habit.id);

        // スナックバーで削除完了を通知
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「${habit.name}」を削除しました'),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // 画面を再読み込み
        await _loadHabits();
      },
      child: Card(
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
              // ignore: deprecated_member_use
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
      ),
    );
  }
}
