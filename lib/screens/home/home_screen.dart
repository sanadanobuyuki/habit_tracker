import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:habit_tracker/services/database_service.dart';
import '../../models/habit.dart';
import '../../controllers/habit_controller.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/completion_rate_card.dart';
import 'add_habit.dart';
import 'edit_habit.dart';

/// HomeScreen クラス
///
/// 役割:
/// - アプリのホーム画面を表示する
/// - 習慣リストをグループ別に表示
/// - 習慣の追加・削除・編集・達成状態の切り替え
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

  // 連続達成回数を保存する Map
  // キー: habit_id, 値: 連続達成日数
  Map<String, int> _streakCounts = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  /// 習慣を読み込む
  ///
  /// 処理の流れ:
  /// 1. HabitControllerを使ってデータを取得
  /// 2. 習慣リスト、今日の達成記録、連続達成回数を取得
  /// 3. 画面を更新
  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);

    // HabitControllerから習慣データと今日の記録を取得
    final result = await _controller.loadHabits();

    // 画面を更新
    setState(() {
      _habits = result.habits;
      _todayRecords = result.todayRecords;
      _streakCounts = result.streakCounts;
      _isLoading = false;
    });
  }

  // 習慣の達成状態を切り替える
  //
  // 処理の流れ:
  // 1. 現在の達成状態を確認
  // 2. HabitControllerを使って達成状態を切り替え
  // 3. 成功したら画面を更新
  // 4. スナックバーで結果を通知
  Future<void> _toggleHabitCompletion(Habit habit) async {
    // 現在の達成状態を取得 (未記録の場合は0=未達成)
    final currentCompleted = _todayRecords[habit.id] ?? 0;

    // HabitControllerで達成状態を切り替え
    final result = await _controller.toggleHabitCompletion(
      context,
      habit,
      currentCompleted,
    );

    if (result.success) {
      // 成功したら画面を更新
      setState(() {
        _todayRecords[habit.id] = result.newCompleted;
      });

      //連続達成日数を再取得
      try {
        final db = DatabaseService();

        // 達成状態に応じて、今日を含めるか決定
        final newStreak = await db.getStreakCount(
          habit.id,
          includeToday: result.newCompleted == 1, // 達成なら true、未達成なら false
        );

        // 画面を更新
        setState(() {
          _streakCounts[habit.id] = newStreak;
        });

        // デバッグ用ログ
        // ignore: avoid_print
        print('連続達成日数を更新: ${habit.name} → $newStreak日');
      } catch (e) {
        // エラーが発生してもアプリは落とさない
        // ignore: avoid_print
        print('連続達成日数の取得エラー: $e');
      }
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
    final result = await _controller.deleteHabit(context, habit);

    // スナックバーで削除完了を通知
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 1),
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
    final l10n = AppLocalizations.of(context);
    // 削除確認ダイアログを表示
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            // タイトル
            title: Text(l10n.deleteHabit), //習慣を削除
            // 詳細
            content: Text(l10n.deleteConfirmation(habit.name)), //を削除しますか？
            actions: [
              TextButton(
                // キャンセルボタン
                // false を返して削除しない
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel), //キャンセル
              ),
              TextButton(
                // 削除ボタン
                // true を返して削除を実行
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete), //削除
              ),
            ],
          ),
        ) ??
        // ダイアログが閉じられた場合は削除しない
        false;
  }

  /// 習慣を3つのグループに分ける
  ///
  /// 処理の流れ:
  /// 1. 今日の曜日を取得 (1=月曜日, 7=日曜日)
  /// 2. 各習慣をループして、今日が対象日かチェック
  /// 3. 対象日の場合は達成状態で分類、対象外の場合は別グループへ
  /// 4. 今日は対象外の習慣を曜日順にソート
  ///
  /// 戻り値:
  /// - incomplete: 今日の未達成の習慣
  /// - completed: 今日の達成済みの習慣
  /// - notToday: 今日は対象外の習慣(曜日順)
  Map<String, List<Habit>> _groupHabits() {
    final today = DateTime.now().weekday; // 1=月曜日, 7=日曜日

    final incomplete = <Habit>[];
    final completed = <Habit>[];
    final notToday = <Habit>[];

    for (final habit in _habits) {
      try {
        // 今日が対象の曜日かチェック
        // habit.frequency は Habit モデルの getter で、
        // daysOfWeek 文字列（例: "1,3,5"）を List<int>（例: [1,3,5]）に変換する
        // null の場合は空のリスト [] を返す
        final frequency = habit.frequency;

        // 空のリストまたはnullの場合は毎日対象とする
        // contains(today) で今日の曜日が含まれているかチェック
        final isTodayTarget = frequency.isEmpty || frequency.contains(today);

        if (isTodayTarget) {
          // 今日が対象の場合、達成状態でグループ分け
          final completedStatus = _todayRecords[habit.id] ?? 0;
          if (completedStatus == 1) {
            completed.add(habit); // 達成済みグループ
          } else {
            incomplete.add(habit); // 未達成グループ
          }
        } else {
          // 今日が対象外の場合
          notToday.add(habit);
        }
      } catch (e) {
        // エラーが発生した場合は今日の未達成に入れる
        // これによりアプリが落ちるのを防ぐ
        // ignore: avoid_print
        print('グループ分けエラー: ${habit.name}, $e');
        incomplete.add(habit);
      }
    }

    // 今日は対象外の習慣を曜日順にソート
    try {
      notToday.sort((a, b) {
        // 各習慣の最初の曜日で比較
        final aFrequency = a.frequency;
        final bFrequency = b.frequency;
        // 空のリストの場合は 8 を使う（日曜日の次 = 最後に表示）
        final aFirstDay = aFrequency.isNotEmpty ? aFrequency.first : 8;
        final bFirstDay = bFrequency.isNotEmpty ? bFrequency.first : 8;
        // 小さい曜日番号が先に来るようにソート
        return aFirstDay.compareTo(bFirstDay);
      });
    } catch (e) {
      // ignore: avoid_print
      print('ソートエラー: $e');
      // ソートに失敗しても続行（順番が変わらないだけ）
    }

    return {
      'incomplete': incomplete,
      'completed': completed,
      'notToday': notToday,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)), //ハビコツ
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
          // 習慣がある場合の表示（グループ別）
          : _buildGroupedHabitList(),

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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon = アイコンを表示
          const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16), // 縦の余白
          Text(
            l10n.noHabitsYet, //まだ習慣がありません
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapPlusToAdd, //画面下の「＋」ボタンをタップして習慣を追加しましょう
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// グループ別に習慣リストを表示
  ///
  /// 処理の流れ:
  /// 1. _groupHabits() で習慣を3つのグループに分類
  /// 2. 今日の達成率を計算
  /// 3. 達成率カードを表示
  /// 4. 各グループが空でなければヘッダーと習慣カードを表示
  /// 5. 表示順序: 達成率カード → 今日の未達成 → 達成済み → 今日は対象外
  ///
  /// ListView について:
  /// children に直接ウィジェットのリストを渡す方式
  /// ListView.builder と違い、グループヘッダーなど
  /// 様々なウィジェットを自由に配置できる
  Widget _buildGroupedHabitList() {
    final l10n = AppLocalizations.of(context);
    // 習慣を3つのグループに分類
    final groups = _groupHabits();
    final incomplete = groups['incomplete']!;
    final completed = groups['completed']!;
    final notToday = groups['notToday']!;

    // 今日の達成率を計算
    final totalToday = incomplete.length + completed.length;
    final completionRate = totalToday > 0 ? completed.length / totalToday : 0.0;
    return ListView(
      // padding = リスト全体の余白
      padding: const EdgeInsets.all(16),
      children: [
        // 達成率カード
        if (totalToday > 0)
          CompletionRateCard(
            completionRate: completionRate,
            completedCount: completed.length,
            totalCount: totalToday,
          ),

        // 1. 今日の未達成の習慣
        // if と ... を組み合わせた条件付き表示
        // グループが空でなければヘッダーとカードを表示
        if (incomplete.isNotEmpty) ...[
          _buildGroupHeader(l10n.todaysHabits, incomplete.length), //今日の習慣
          // ... はスプレッド演算子: リストの中身を展開する
          // map() で各習慣を HabitCard ウィジェットに変換
          ...incomplete.map((habit) => _buildHabitCardWidget(habit)),
          const SizedBox(height: 24), // グループ間の余白
        ],

        // 2. 今日の達成済みの習慣
        if (completed.isNotEmpty) ...[
          _buildGroupHeader(l10n.completed, completed.length), //達成済み
          ...completed.map((habit) => _buildHabitCardWidget(habit)),
          const SizedBox(height: 24),
        ],

        // 3. 今日は対象外の習慣（曜日順にソート済み）
        if (notToday.isNotEmpty) ...[
          _buildGroupHeader(l10n.notTargetToday, notToday.length), //今日は対象外
          ...notToday.map((habit) => _buildHabitCardWidget(habit)),
        ],
      ],
    );
  }

  /// グループヘッダーを作成
  ///
  /// 表示内容:
  /// - タイトル（例: "今日の習慣"）
  /// - 件数バッジ（例: "2"）
  ///
  /// 引数:
  /// - title: グループのタイトル
  /// - count: グループ内の習慣の数
  Widget _buildGroupHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          // グループタイトル
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8), // タイトルとバッジの間の余白
          // 件数バッジ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HabitCardウィジェットを作成
  ///
  /// 処理の流れ:
  /// 1. 習慣の達成状態と連続達成回数を取得
  /// 2. HabitCard ウィジェットを作成
  /// 3. タップ時、スワイプ削除時、編集時の処理を設定
  ///
  /// HabitCard について:
  /// ウィジェット化することで、コードが見やすくなり、再利用もできる
  Widget _buildHabitCardWidget(Habit habit) {
    final completedStatus = _todayRecords[habit.id] ?? 0;
    final streakCount = _streakCounts[habit.id] ?? 0;

    return HabitCard(
      habit: habit,
      completedStatus: completedStatus,
      streakCount: streakCount,
      // onTap = カードをタップしたときの処理
      onTap: () => _toggleHabitCompletion(habit),
      // onDeleteConfirm = スワイプして削除確認が必要なときの処理
      onDeleteConfirm: () async {
        // 削除確認ダイアログを表示
        final confirmed = await _showDeleteConfirmDialog(habit);
        if (confirmed) {
          // 確認された場合のみ削除実行
          await _deleteHabit(habit);
        }
        return confirmed;
      },
      // onEdit = 編集画面への遷移処理（新規追加）
      onEdit: () async {
        // 編集画面へ遷移
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditHabit(habit: habit)),
        );

        // 編集から戻ってきた場合、result が true なら更新があった
        // リストを再読み込みして最新の状態を表示
        if (result == true) {
          await _loadHabits();
        }
      },
      l10n: AppLocalizations.of(context),
    );
  }
}
