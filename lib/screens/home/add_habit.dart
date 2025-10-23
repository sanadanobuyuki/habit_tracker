import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AddHabit extends StatefulWidget {
  const AddHabit({super.key});

  @override
  State<AddHabit> createState() => _AddHabitState();
}

class _AddHabitState extends State<AddHabit> {
  //テキストフィールドの入力内容を管理するためのコントローラー
  final TextEditingController _nameController = TextEditingController();

  //選択された絵文字（初期値なし）
  String _selectedEmoji = '';

  //選択された色（初期値赤）
  int _selectedColor = 0xFFFF4444;

  //目標頻度（初期値7回/週）
  int _targetFrequency = 7;

  //利用可能な絵文字リスト
  final List<String> _availableEmojis = [
    '🏃‍♂️',
    '📚',
    '🧘‍♀️',
    '🍎',
    '💧',
    '🛏️',
    '📝',
    '🎨',
    '🎵',
    '💪',
    '🧹',
    '🎮',
  ];

  //利用可能な色リスト
  final List<int> _availableColors = [
    0xFFFF4444, // 赤
    0xFF3B82F6, // 青
    0xFF10B981, // 緑
    0xFFF59E0B, // 黄
    0xFF8B5CF6, // 紫
    0xFFEC4899, // ピンク
  ];
  @override
  void dispose() {
    //dispose()について
    //画面gな破棄されるときにコントローラーも破壊する
    //メモリリークを防ぐため
    _nameController.dispose();
    super.dispose();
  }

  //習慣を保存する
  Future<void> _saveHabit() async {
    //入力チェック
    if (_nameController.text.trim().isEmpty) {
      //SnacBarについて
      //画面下部に一時的にメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('習慣名を入力してください'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedEmoji.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('絵文字を選択してください'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    //データベースに保存
    final db = DatabaseService();

    //新しい習慣IDを生成
    //DataTime.now().millisecondsSinceEpoch=現在の日時をミリ秒で取得
    final habitId = 'habit_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await db.insertHabit(
        id: habitId,
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        color: _selectedColor,
        targetFrequency: _targetFrequency,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      //保存成功
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('習慣を保存しました'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(); //前の画面に戻る
      }
    } catch (e) {
      //保存失敗
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
      appBar: AppBar(
        title: const Text('習慣を追加'),
        //actionsについて
        //AppBarの右側にボタンを配置
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text(
              '保存',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        //SingleChildScrollViewについて
        //画面をスクロール可能にする
        //キーボードが表示されたときに画面が隠れないようにするため
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //習慣の名前
            const Text(
              '習慣名',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '例：朝の運動',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            //絵文字の選択
            const Text(
              '絵文字',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            //Wrapについて
            //子要素を横に並べてスペースが足りなくなったったら自動で改行する
            Wrap(
              spacing: 8, // 横の間隔
              runSpacing: 8, // 縦の間隔
              children: _availableEmojis.map((emoji) {
                // 選択中の絵文字かどうか
                final isSelected = _selectedEmoji == emoji;

                return GestureDetector(
                  // GestureDetector について:
                  // タップなどのジェスチャーを検知する
                  onTap: () {
                    setState(() {
                      _selectedEmoji = emoji;
                    });
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      border: isSelected
                          ? Border.all(color: Colors.purple, width: 2)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 色の選択
            const Text(
              '色',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(color),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      // boxShadow について:
                      // 影をつける
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(color).withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 32)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 目標頻度の選択
            const Text(
              '目標頻度（週あたり）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // IconButton について:
                // アイコンをボタンにする
                IconButton(
                  onPressed: _targetFrequency > 1
                      ? () {
                          setState(() {
                            _targetFrequency--;
                          });
                        }
                      : null, // 1以下にはできない
                  icon: const Icon(Icons.remove_circle_outline),
                ),

                Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$_targetFrequency回',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _targetFrequency < 7
                      ? () {
                          setState(() {
                            _targetFrequency++;
                          });
                        }
                      : null, // 7以上にはできない
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
