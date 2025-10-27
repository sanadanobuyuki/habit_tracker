import 'package:flutter/material.dart';
import '../../models/habit.dart';
import '../../controllers/habit_controller.dart';
import '../../widgets/habit_card.dart';
import 'add_habit.dart';

/// HomeScreen クラス
///
/// 役割:
/// - アプリのホーム画面を表示する
/// - 習慣リストを表示
/// - 習慣の追加・削除・達成状態の切り替え
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // HabitController = ビジネスロジックを管理するクラス
  // データの読み込み、更新、削除などを担当
  final HabitController _controller = HabitController();

  List<Habit> _habits = [];

  // ローディング中かどうか
  bool _isLoading = true;

  // 今日の達成記録を保存する Map
  // キー: habit_id, 値: 達成フラグ(0=未達成, 1=達成)
  Map<String, int> _todayRecords = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  /// 習慣を読み込む
  ///
  /// 処理の流れ:
  /// 1. HabitControllerを使ってデータを取得
  /// 2. 習慣リストと今日の達成記録を取得
  /// 3. 画面を更新
  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);

    // HabitControllerから習慣データと今日の記録を取得
    final result = await _controller.loadHabits();

    // 画面を更新
    setState(() {
      _habits = result.habits;
      _todayRecords = result.todayRecords;
      _isLoading = false;
    });
  }

  /// 習慣の達成状態を切り替える
  ///
  /// 処理の流れ:
  /// 1. 現在の達成状態を確認
  /// 2. HabitControllerを使って達成状態を切り替え
  /// 3. 成功したら画面を更新
  /// 4. スナックバーで結果を通知
  Future<void> _toggleHabitCompletion(Habit habit) async {
    // 現在の達成状態を取得 (未記録の場合は0=未達成)
    final currentCompleted = _todayRecords[habit.id] ?? 0;

    // HabitControllerで達成状態を切り替え
    final result = await _controller.toggleHabitCompletion(
      habit,
      currentCompleted,
    );

    if (result.success) {
      // 成功したら画面を更新
      setState(() {
        _todayRecords[habit.id] = result.newCompleted;
      });
    }

    // スナックバーで通知
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// 習慣を削除する
  ///
  /// 処理の流れ:
  /// 1. HabitControllerで削除を実行
  /// 2. スナックバーで結果を通知
  /// 3. 成功したら習慣リストを再読み込み
  Future<void> _deleteHabit(Habit habit) async {
    final result = await _controller.deleteHabit(habit);

    // スナックバーで削除完了を通知
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (result.success) {
      // 画面を再読み込み
      await _loadHabits();
    }
  }

  /// 削除確認ダイアログを表示
  ///
  /// 戻り値:
  /// - true: 削除を実行
  /// - false: キャンセル
  Future<bool> _showDeleteConfirmDialog(Habit habit) async {
    // 削除確認ダイアログを表示
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            // タイトル
            title: const Text('習慣を削除'),
            // 詳細
            content: Text('「${habit.name}」を削除しますか?'),
            actions: [
              TextButton(
                // キャンセルボタン
                // false を返して削除しない
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                // 削除ボタン
                // true を返して削除を実行
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('削除'),
              ),
            ],
          ),
        ) ??
        // ダイアログが閉じられた場合は削除しない
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ハビコツ')),

      // SafeArea について:
      // AppBarがある場合、body全体をSafeAreaで囲む必要はない
      // しかし、統一性のため全体を囲むこともできる
      // ここではAppBarがあるのでSafeAreaは不要
      body: _isLoading
          // ローディング中ならぐるぐる回るアイコンを表示
          ? const Center(child: CircularProgressIndicator())
          // ローディング完了後の表示
          : _habits.isEmpty
          // 習慣がない場合の表示
          ? _buildEmptyView()
          // 習慣がある場合の表示
          : _buildHabitList(),

      // FloatingActionButton = 画面右下の丸いボタン
      floatingActionButton: FloatingActionButton(
        // onPressed = ボタンが押されたときの処理
        heroTag: 'add_habit',
        onPressed: () async {
          // 習慣追加画面に遷移
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddHabit()));
          // 画面から戻ってきたら習慣を再読み込み
          _loadHabits();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 習慣がない場合の表示
  ///
  /// SafeArea について:
  /// AppBarがある場合は自動的に安全領域が確保されるため不要
  /// しかし、念のため追加しても問題ない
  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon = アイコンを表示
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
        final completedStatus = _todayRecords[habit.id] ?? 0;

        // HabitCard ウィジェットで習慣カードを表示
        // ウィジェット化することで、コードが見やすくなり、再利用もできる
        return HabitCard(
          habit: habit,
          completedStatus: completedStatus,
          onTap: () => _toggleHabitCompletion(habit),
          onDeleteConfirm: () async {
            // 削除確認ダイアログを表示
            final confirmed = await _showDeleteConfirmDialog(habit);
            if (confirmed) {
              // 確認された場合のみ削除実行
              await _deleteHabit(habit);
            }
            return confirmed;
          },
        );
      },
    );
  }
}
