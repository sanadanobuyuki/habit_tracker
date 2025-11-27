import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../controllers/achievement_controller.dart';
import '../../widgets/emoji_selector.dart';
import '../../widgets/color_selector.dart';
import '../../widgets/day_selector.dart';
import '../../widgets/themed_scaffold.dart';

/// AddHabit
///
/// 役割:
/// - 新しい習慣を追加する画面
/// - 各種ウィジェットを組み合わせて習慣の設定を行う
class AddHabit extends StatefulWidget {
  const AddHabit({super.key});

  @override
  State<AddHabit> createState() => _AddHabitState();
}

class _AddHabitState extends State<AddHabit> {
  // テキストフィールドの入力内容を管理するためのコントローラー
  final TextEditingController _nameController = TextEditingController();

  final DatabaseService _db = DatabaseService();
  final AchievementController _achievementController = AchievementController();

  // 選択された絵文字（初期値なし）
  String _selectedEmoji = '';

  // 選択された色（初期値: 赤）
  int _selectedColor = 0xFFFF4444;

  // 曜日設定の種類
  // true = 毎日, false = 曜日指定
  bool _isEveryDay = true;

  // 選択された曜日のリスト
  final List<int> _selectedDays = [];

  @override
  void dispose() {
    // dispose() について:
    // 画面が破棄されるときにコントローラーも破棄する
    // メモリリークを防ぐため
    _nameController.dispose();
    super.dispose();
  }

  /// 習慣を保存する
  ///
  /// 処理の流れ:
  /// 1. 入力内容をバリデーション
  /// 2. データベースに保存
  /// 3. 成功したら前の画面に戻る
  Future<void> _saveHabit() async {
    // 入力チェック
    if (!_validateInput()) {
      return;
    }

    // データベースに保存
    // 新しい習慣IDを生成
    // DateTime.now().millisecondsSinceEpoch = 現在の日時をミリ秒で取得
    final habitId = 'habit_${DateTime.now().millisecondsSinceEpoch}';

    // 曜日データを文字列に変換
    final daysOfWeek = _getDaysOfWeekString();

    try {
      await _db.insertHabit(
        id: habitId,
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        color: _selectedColor,
        daysOfWeek: daysOfWeek,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      //実績チェック
      //習慣を作成した後、habit_count系の実績をチェック
      //処理の流れ
      //1.checkHabitContAchievements()を呼ぶ
      //2.新しく解除された実績のリストが返ってくる
      //3.リストがからでなければ実績解除の通知を表示
      final newAchievements = await _achievementController
          .checkHabitCountAchievements();

      // 保存成功
      if (mounted) {
        _showSnackBar('習慣を保存しました');

        //新しく解除された実績があれば通知
        //isNotEmpty
        //リストがからでない＝新しい実績が解除された
        if (newAchievements.isNotEmpty) {
          //複数解除されることもあるが最初の一つだけ通知
          final achievement = newAchievements.first;

          //スナックバーで通知
          //後でダイアログに変更する
          _showSnackBar('🎉実績解除！「${achievement.name}」');
        }

        Navigator.of(context).pop(); // 前の画面に戻る
      }
    } catch (e) {
      // 保存失敗
      if (mounted) {
        _showSnackBar('エラーが発生しました: $e');
      }
    }
  }

  /// 入力内容をバリデーション
  ///
  /// 戻り値:
  /// - true: バリデーション成功
  /// - false: バリデーション失敗
  bool _validateInput() {
    // 入力チェック
    if (_nameController.text.trim().isEmpty) {
      // SnackBar について:
      // 画面下部に一時的にメッセージを表示
      _showSnackBar('習慣名を入力してください');
      return false;
    }

    if (_selectedEmoji.isEmpty) {
      _showSnackBar('絵文字を選択してください');
      return false;
    }

    // 曜日指定の場合、曜日が選択されているかチェック
    if (!_isEveryDay && _selectedDays.isEmpty) {
      _showSnackBar('曜日を選択してください');
      return false;
    }

    return true;
  }

  /// 曜日データを文字列に変換
  ///
  /// 戻り値:
  /// - 毎日の場合: null
  /// - 曜日指定の場合: "1,3,5" のような文字列 (1=月, 2=火, ..., 7=日)
  String? _getDaysOfWeekString() {
    if (_isEveryDay) {
      // 毎日の場合は null
      return null;
    }
    _selectedDays.sort(); // 並び替え
    return _selectedDays.join(',');
  }

  /// スナックバーを表示
  ///
  /// 引数:
  /// - message: 表示するメッセージ
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// 毎日/曜日指定の切り替え
  ///
  /// 処理の流れ:
  /// 1. isEveryDay の値を更新
  /// 2. 毎日に切り替えた場合は選択された曜日をクリア
  void _onEveryDayChanged(bool isEveryDay) {
    setState(() {
      _isEveryDay = isEveryDay;
      if (isEveryDay) {
        _selectedDays.clear();
      }
    });
  }

  /// 曜日の選択/解除
  ///
  /// 処理の流れ:
  /// 1. 既に選択されている場合は解除
  /// 2. 選択されていない場合は追加
  void _onDayToggle(int dayNumber) {
    setState(() {
      if (_selectedDays.contains(dayNumber)) {
        _selectedDays.remove(dayNumber);
      } else {
        _selectedDays.add(dayNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('習慣を追加'),
        // actions について:
        // AppBarの右側にボタンを配置
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // SingleChildScrollView について:
        // 画面をスクロール可能にする
        // キーボードが表示されたときに画面が隠れないようにするため
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 習慣名入力フィールド
            _buildNameField(),
            const SizedBox(height: 24),

            // 絵文字選択
            // EmojiSelector ウィジェットを使用
            // ウィジェット化することで、コードが見やすくなり、再利用もできる
            EmojiSelector(
              selectedEmoji: _selectedEmoji,
              onEmojiSelected: (emoji) {
                setState(() => _selectedEmoji = emoji);
              },
            ),
            const SizedBox(height: 24),

            // 色選択
            // ColorSelector ウィジェットを使用
            ColorSelector(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() => _selectedColor = color);
              },
            ),
            const SizedBox(height: 24),

            // 曜日設定
            // DaySelector ウィジェットを使用
            DaySelector(
              isEveryDay: _isEveryDay,
              selectedDays: _selectedDays,
              onEveryDayChanged: _onEveryDayChanged,
              onDayToggle: _onDayToggle,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 習慣名入力フィールド
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '習慣名',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: '例: 朝の運動',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
