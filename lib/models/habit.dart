// Habit クラス
//
// 役割: 習慣のデータを扱いやすくするためのクラス
// データベースのhabitsテーブルの1行分のデータを表す
// 例:
// Habit habit = Habit(
//   id: 'habit_001',
//   name: '朝の運動',
//   emoji: '🏃‍♂️',
//   color: 0xFFEF4444,
//   targetFrequency: 7,
//   createdAt: 1234567890,
// );
class Habit {
  final String id; // 習慣のID
  final String name; // 習慣名
  final String emoji; // 絵文字
  final int color; // 色コード
  final int targetFrequency; // 目標頻度
  final int createdAt; // 作成日時
  final int isDeleted; // 削除フラグ

  // コンストラクタ
  //
  // required = 必須の引数
  // this.isDeleted = 0 = デフォルト値（省略すると0）
  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.targetFrequency,
    required this.createdAt,
    this.isDeleted = 0,
  });

  //データベースのMapからHabitオブジェクトを作成
  //
  // factory = 特別なコンストラクタ
  // 使い方:
  // Map<String, dynamic> data = {'id': 'habit_001', 'name': '運動', ...};
  // Habit habit = Habit.fromMap(data);
  //
  // これでMapをHabitオブジェクトに変換できる
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      color: map['color'] as int,
      targetFrequency: map['target_frequency'] as int,
      createdAt: map['created_at'] as int,
      isDeleted: map['is_deleted'] as int? ?? 0, // nullなら0
    );
  }

  // HabitオブジェクトをMapに変換
  //
  // 使い方:
  // Habit habit = Habit(...);
  // Map<String, dynamic> data = habit.toMap();
  //
  // データベースに保存する時に使う
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'target_frequency': targetFrequency,
      'created_at': createdAt,
      'is_deleted': isDeleted,
    };
  }
}
