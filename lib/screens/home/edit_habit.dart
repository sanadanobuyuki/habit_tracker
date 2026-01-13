import 'package:flutter/material.dart';
import '../../models/habit.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../controllers/habit_controller.dart';
import '../../widgets/emoji_selector.dart';
import '../../widgets/color_selector.dart';
import '../../widgets/themed_scaffold.dart';

/// EditHabit クラス
///
/// 役割:
/// - 既存の習慣を編集する画面
/// - 名前、絵文字、色のみ編集可能
/// - 曜日は変更不可（データ整合性のため）
/// - EmojiSelectorとColorSelectorウィジェットを使用
class EditHabit extends StatefulWidget {
  // 編集対象の習慣
  final Habit habit;

  const EditHabit({super.key, required this.habit});

  @override
  State<EditHabit> createState() => _EditHabitState();
}

class _EditHabitState extends State<EditHabit> {
  // HabitController = ビジネスロジックを管理
  final HabitController _controller = HabitController();

  // TextEditingController = テキストフィールドの値を管理
  // dispose() で必ずメモリ解放が必要
  late TextEditingController _nameController;

  // 選択された絵文字と色を保持
  late String _selectedEmoji;
  late int _selectedColor;

  // 保存中かどうか（ボタンの二重押し防止）
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // TextEditingController を初期化して、現在の習慣名を設定
    _nameController = TextEditingController(text: widget.habit.name);

    // 現在の絵文字と色を設定
    _selectedEmoji = widget.habit.emoji;
    _selectedColor = widget.habit.color;
  }

  @override
  void dispose() {
    // TextEditingController のメモリを解放
    // これを忘れるとメモリリークが発生する
    _nameController.dispose();
    super.dispose();
  }

  /// 習慣を更新する
  ///
  /// 処理の流れ:
  /// 1. 入力値をバリデーション（チェック）
  /// 2. HabitController で更新実行
  /// 3. 成功したら前の画面に戻る
  /// 4. エラーがあればスナックバーで通知
  Future<void> _updateHabit() async {
    // 習慣名が空でないかチェック
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showErrorMessage(l10n.pleaseEnterHabitName); // 習慣名を入力してください
      return;
    }

    // 保存中フラグをONにする（ボタンの二重押し防止）
    setState(() => _isSaving = true);

    try {
      // HabitController で習慣を更新
      final result = await _controller.updateHabit(
        context: context,
        id: widget.habit.id,
        name: name,
        emoji: _selectedEmoji,
        color: _selectedColor,
      );

      // mounted について:
      // この画面がまだ表示されているかチェック
      // 非同期処理中に画面が閉じられた場合、エラーを防ぐ
      if (!mounted) return;

      if (result.success) {
        // 成功したらスナックバーで通知して前の画面に戻る
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            duration: const Duration(seconds: 2),
          ),
        );

        // 前の画面に戻る（true を返すことで更新があったことを通知）
        Navigator.of(context).pop(true);
      } else {
        // 失敗したらエラーメッセージを表示
        _showErrorMessage(result.message);
      }
    } catch (e) {
      // 予期しないエラーが発生した場合
      _showErrorMessage('更新中にエラーが発生しました: $e');
    } finally {
      // 処理が終わったら保存中フラグをOFFにする
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// エラーメッセージをスナックバーで表示
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 曜日を表示用の文字列に変換
  ///
  /// 例:
  /// - null → "毎日"
  /// - "1,3,5" → "月 水 金"
  String _getDaysOfWeekText() {
    final l10n = AppLocalizations.of(context);
    if (widget.habit.daysOfWeek == null || widget.habit.daysOfWeek!.isEmpty) {
      return l10n.everyday; // 毎日
    }

    // 曜日番号を日本語に変換するマップ
    final dayNames = {
      '1': l10n.monday, // 月
      '2': l10n.tuesday, // 火
      '3': l10n.wednesday, // 水
      '4': l10n.thursday, // 木
      '5': l10n.friday, // 金
      '6': l10n.saturday, // 土
      '7': l10n.sunday, // 日
    };

    // "1,3,5" を分割して ["月", "水", "金"] に変換
    final days = widget.habit.daysOfWeek!
        .split(',')
        .map((d) => dayNames[d] ?? '')
        .where((d) => d.isNotEmpty)
        .join(' ');

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ThemedScaffold(
      // AppBar = 画面上部のバー
      appBar: AppBar(
        title: Text(l10n.editHabit), // 習慣を編集
        // leading = AppBar左端のウィジェット
        // 自動的に「戻る」ボタンが表示される
      ),

      body: SingleChildScrollView(
        // SingleChildScrollView について:
        // 画面に収まらない内容をスクロール可能にする
        // キーボードが表示されても内容が隠れない
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 習慣名の入力欄
            _buildNameField(),
            const SizedBox(height: 24),

            // 絵文字選択（EmojiSelectorウィジェットを使用）
            EmojiSelector(
              selectedEmoji: _selectedEmoji,
              onEmojiSelected: (emoji) {
                setState(() {
                  _selectedEmoji = emoji;
                });
              },
            ),
            const SizedBox(height: 24),

            // 色選択（ColorSelectorウィジェットを使用）
            ColorSelector(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 24),

            // 曜日表示（編集不可）
            _buildDaysOfWeekDisplay(),
            const SizedBox(height: 32),

            // 保存ボタン
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// 習慣名の入力欄
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
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_selectedEmoji, style: const TextStyle(fontSize: 24)),
            ),
            // border = 枠線のスタイル
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          // maxLength = 最大文字数
          maxLength: 30,
        ),
      ],
    );
  }

  /// 曜日表示エリア（編集不可）
  Widget _buildDaysOfWeekDisplay() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.daysOfWeek, //曜日
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // 灰色の背景で編集不可を表現
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDaysOfWeekText(),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l10n.daysCannotBeChanged, // 曜日は編集できません
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 保存ボタン
  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity, // 画面幅いっぱい
      height: 50,
      child: ElevatedButton(
        // ボタンが押されたときの処理
        onPressed: _isSaving ? null : _updateHabit,

        // _isSaving が true の場合は null（ボタン無効化）
        // これにより二重押しを防ぐ
        child: _isSaving
            // 保存中はローディングインジケーターを表示
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            // 通常時は「保存する」テキスト
            : Text(l10n.save, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
