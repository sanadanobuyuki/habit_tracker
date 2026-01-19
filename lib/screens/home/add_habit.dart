import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
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
/// - EmojiSelector, ColorSelector, DaySelectorを使用
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

  // 保存中かどうか（ボタンの二重押し防止）
  bool _isSaving = false;

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

    // 保存中フラグをONにする（ボタンの二重押し防止）
    setState(() => _isSaving = true);

    try {
      // データベースに保存
      // 新しい習慣IDを生成
      // DateTime.now().millisecondsSinceEpoch = 現在の日時をミリ秒で取得
      final habitId = 'habit_${DateTime.now().millisecondsSinceEpoch}';

      // 曜日データを文字列に変換
      final daysOfWeek = _getDaysOfWeekString();

      //現在の日時取得
      final now = DateTime.now();

      await _db.insertHabit(
        id: habitId,
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        color: _selectedColor,
        daysOfWeek: daysOfWeek,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      //今日の未達成記録を自動生成
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final weekday = now.weekday;

      //今日が対象曜日かチェック
      bool isTargetToday = true;
      if (daysOfWeek != null && daysOfWeek.isNotEmpty) {
        final days = daysOfWeek.split(',');
        isTargetToday = days.contains(weekday.toString());
      }

      //対象曜日なら未達成記録を作成
      if (isTargetToday) {
        final recordId = 'record_${habitId}_${now.millisecondsSinceEpoch}';
        await _db.insertRecord(
          id: recordId,
          habitId: habitId,
          date: today,
          completed: 0, //未達成
          recordedAt: now.millisecondsSinceEpoch,
        );
      }

      //実績チェック
      //習慣を作成した後、habit_count系の実績をチェック
      final newAchievements = await _achievementController
          .checkHabitCountAchievements();
      // ignore: use_build_context_synchronously
      final l10n = AppLocalizations.of(context);
      // 保存成功
      if (mounted) {
        _showSnackBar(l10n.habitSaved); //習慣を保存しました

        //新しく解除された実績があれば通知
        if (newAchievements.isNotEmpty) {
          //複数解除されることもあるが最初の一つだけ通知
          final achievement = newAchievements.first;

          //スナックバーで通知
          _showSnackBar(l10n.achievementUnlocked(achievement.name)); //実績解除
        }

        Navigator.of(context).pop(); // 前の画面に戻る
      }
    } catch (e) {
      // 保存失敗
      if (mounted) {
        _showSnackBar('エラーが発生しました: $e');
      }
    } finally {
      // 処理が終わったら保存中フラグをOFFにする
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// 入力内容をバリデーション
  ///
  /// 戻り値:
  /// - true: バリデーション成功
  /// - false: バリデーション失敗
  bool _validateInput() {
    final l10n = AppLocalizations.of(context);
    // 入力チェック
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.pleaseEnterHabitName); // 習慣名を入力してください
      return false;
    }

    if (_selectedEmoji.isEmpty) {
      _showSnackBar(l10n.pleaseSelectEmoji); // 絵文字を選択してください
      return false;
    }

    // 曜日指定の場合、曜日が選択されているかチェック
    if (!_isEveryDay && _selectedDays.isEmpty) {
      _showSnackBar(l10n.pleaseSelectDays); // 曜日を選択してください
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
    final l10n = AppLocalizations.of(context);
    return ThemedScaffold(
      appBar: AppBar(
        title: Text(l10n.addHabit), // 習慣を追加
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 32),

              // 保存ボタン
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 習慣名入力フィールド
  Widget _buildNameField() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.habitName, //習慣名
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: l10n.habitNameHint, //例: 朝の運動
            // suffixIcon = テキストフィールド右端のアイコン
            suffixIcon: _selectedEmoji.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLength: 30,
        ),
      ],
    );
  }

  /// 保存ボタン
  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveHabit,
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(l10n.save, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
