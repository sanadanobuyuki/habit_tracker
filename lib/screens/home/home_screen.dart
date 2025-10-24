import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/habit.dart';
import 'add_habit.dart';

//HomeScreenクラス
//役割
// アプリのホーム画面を表示する

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];

  //ローディング中かどうか
  bool _isLoading = true;

  //今日の記録達成を保存する Map
  //キー:habit_id,値:達成フラグ(0=未達成,1=達成)
  Map<String, int> _todayRecords = {};

  @override
  void initState() {
    super.initState();
    _initializeData(); // この関数で順番に実行
  }

  // データを初期化する
  // 処理の流れ:
  // 1. テストデータを追加(完了を待つ)
  // 2. 習慣データを読み込む
  Future<void> _initializeData() async {
    await _addTestHabits(); // テストデータ追加を待つ
    await _loadHabits(); // その後、習慣を読み込む
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
  //3.今日の達成記録を取得
  //4.画面を更新

  Future<void> _loadHabits() async {
    //データべースサービスのインスタンスを作成
    final db = DatabaseService();

    //データベースからすべての習慣を取得
    final habitsData = await db.getAllHabits();

    //MapのリストをHabitオブジェクトのリストに変換
    final habits = habitsData.map((data) => Habit.fromMap(data)).toList();

    //今日の日付を取得(YYYY-MM-DD形式)
    final today = _getTodayString();

    //今日の記録を取得
    final todayRecordsData = await db.getRecordsByDate(today);

    //Map形式に変換 {habit_id: completed}
    final Map<String, int> todayRecords = {};
    for (var record in todayRecordsData) {
      todayRecords[record['habit_id'] as String] =
          record['completed'] as int ?? 0;
    }

    //画面を更新
    setState(() {
      _habits = habits;
      _todayRecords = todayRecords;
      _isLoading = false;
    });
  }

  //今日の日付をYYYY-MM-DD形式で取得
  //例2024-10-24
  String _getTodayString() {
    final now = DateTime.now();
    //oadLeft(2,'0')について
    //二桁になるように左側をゼロで埋める
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  //習慣の達成状態を切り替える
  //処理の流れ
  //1.現在の達成状態を確認
  //2.達成・未達成を反転
  //3.データベースに保存または更新
  //4.画面を更新
  Future<void> _toggleHabitCompletion(Habit habit) async {
    final db = DatabaseService();
    final today = _getTodayString();

    //達成状況を取得
    final currentCompleted = _todayRecords[habit.id] ?? 0;

    //達成状態を反転
    final newCompleted = currentCompleted == 0 ? 1 : 0;

    try {
      //今日の記録がすでに存在するか確認
      final existingRecords = await db.getRecordsByDate(today);
      final existingRecord = existingRecords.firstWhere(
        (record) => record['habit_id'] == habit.id,
        orElse: () => <String, dynamic>{},
      );
      if (existingRecord.isEmpty) {
        //記録が存在しない場合新規製作
        final recordId =
            'record_${habit.id}_${DateTime.now().millisecondsSinceEpoch}';
        await db.insertRecord(
          id: recordId,
          habitId: habit.id,
          date: today,
          completed: newCompleted,
          recordedAt: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        //記録が存在する場合:更新
        await db.updateRecord(
          id: existingRecord['id'] as String,
          completed: newCompleted,
        );
      }

      //画面更新
      setState(() {
        _todayRecords[habit.id] = newCompleted;
      });

      //スナックバーで通知
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newCompleted == 1
                  ? '${habit.emoji} ${habit.name} を達成しました!'
                  : '${habit.name} の達成を取り消しました',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // エラー処理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
          //画面から戻ってきたら習慣を再度読み込み
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
    //今日の達成状態を取得
    final isCompleted = (_todayRecords[habit.id] ?? 0) == 1;

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
          //onTapについて
          //カードをタップした時の処理
          //ここでは達成状態を切り替える
          onTap: () => _toggleHabitCompletion(habit),

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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //達成済みの場合はチェックマークを表示
              if (isCompleted)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(habit.color),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              const SizedBox(width: 8),
              //色のバー
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(habit.color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
