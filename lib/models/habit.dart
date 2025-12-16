// Habit クラス
//
// 役割: 習慣のデータを扱いやすくするためのクラス
// データベースのhabitsテーブルの1行分のデータを表す
class Habit {
  final String id; // 習慣のID
  final String name; // 習慣名
  final String emoji; // 絵文字
  final int color; // 色コード
  final String? daysOfWeek; // 曜日指定 (null=毎日, "1,3,5"=月水金)
  final int createdAt; // 作成日時
  final int isDeleted; // 削除フラグ
  final int? deletedAt; //タイムスタンプを保存

  // コンストラクタ
  //
  // required = 必須の引数
  // this.isDeleted = 0 = デフォルト値(省略すると0)
  // this.daysOfWeek = null = デフォルト値(省略するとnull=毎日)
  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.daysOfWeek, // 曜日指定(省略可能)
    required this.createdAt,
    this.isDeleted = 0,
    this.deletedAt,
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
      daysOfWeek: map['days_of_week'] as String?, // 追加
      createdAt: map['created_at'] as int,
      isDeleted: map['is_deleted'] as int? ?? 0, // nullなら0
      deletedAt: map['deleted_at'] as int?,
    );
  }

  //creatAtをDateTime型に変換 getter
  DateTime get createdAtDate {
    //ミリ秒からDateTimeで日付変換している
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return DateTime(dt.year, dt.month, dt.day);
  }

  // daysOfWeek 文字列を List<int> に変換する getter
  //
  // 役割:
  // データベースに保存されている文字列形式の曜日指定（例: "1,3,5"）を
  // プログラムで扱いやすい数値のリスト（例: [1, 3, 5]）に変換する
  //
  // 使い方:
  // Habit habit = Habit(daysOfWeek: "1,3,5", ...);
  // List<int> days = habit.frequency; // [1, 3, 5]
  //
  // 戻り値:
  // - null または空文字列の場合: 空のリスト [] （毎日対象を意味する）
  // - "1,3,5" の場合: [1, 3, 5] （月・水・金を意味する）
  //
  // 曜日の番号:
  // 1=月曜日, 2=火曜日, 3=水曜日, 4=木曜日, 5=金曜日, 6=土曜日, 7=日曜日
  List<int> get frequency {
    // daysOfWeek が null または空文字列の場合
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      return []; // 空のリストを返す（毎日対象を意味する）
    }

    try {
      // カンマ区切りの文字列を分割してリストに変換
      // 例: "1,3,5" → ["1", "3", "5"]
      final dayStrings = daysOfWeek!.split(',');

      // 文字列のリストを数値のリストに変換
      // 例: ["1", "3", "5"] → [1, 3, 5]
      return dayStrings
          .map((s) => int.tryParse(s.trim())) // trim() で空白を除去してから数値に変換
          .where((day) => day != null) // 変換失敗した null を除外
          .cast<int>() // List<int?> を List<int> に変換
          .toList();
    } catch (e) {
      // パースエラーが発生した場合は空のリストを返す
      // これによりアプリが落ちるのを防ぐ
      // ignore: avoid_print
      print('frequency パースエラー: $daysOfWeek, $e');
      return [];
    }
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
      'days_of_week': daysOfWeek, // 追加
      'created_at': createdAt,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
    };
  }

  // この習慣が指定された曜日に対象かどうかを判定
  //
  // 使い方:
  // Habit habit = Habit(daysOfWeek: "1,3,5", ...);
  // bool isTarget = habit.isTargetDay(1); // 月曜日 → true
  // bool isTarget = habit.isTargetDay(2); // 火曜日 → false
  //
  // 引数:
  // weekday = 1(月) ~ 7(日)
  bool isTargetDay(int weekday) {
    // daysOfWeek が null = 毎日対象
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      return true;
    }

    // カンマ区切りの文字列を分割してリストに変換
    // 例: "1,3,5" → ["1", "3", "5"]
    final days = daysOfWeek!.split(',');

    // weekdayが含まれているかチェック
    // 例: weekday=1 → "1"が含まれているか
    return days.contains(weekday.toString());
  }
}
