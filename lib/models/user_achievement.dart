// user_achievement.dart
//
// 役割:
// - ユーザーが解除した実績の記録を管理
// - 解除日時を保存
// - テーマ報酬の受け取り状況を管理

// UserAchievement クラス
//
// ユーザーが解除した実績の情報を保持するクラス
//
// データベースの user_achievements テーブルに対応
//
// 使い方:
// // データベースから取得
// final userAchievementsData = await db.getUserAchievements();
// final userAchievement = UserAchievement.fromMap(userAchievementsData[0]);
//
// // 情報にアクセス
// print(userAchievement.achievementId);  // 'ach_first_habit'
// print(userAchievement.unlockedAt);     // DateTime(2024, 11, 10)
// print(userAchievement.themeReceived);  // false
// ```
class UserAchievement {
  /// レコードの一意な識別子
  /// 例: 'user_ach_001', 'user_ach_002'
  /// - 更新や削除時に使用
  final String id;

  /// 解除した実績のID
  /// Achievement の id を参照
  /// 例: 'ach_first_habit', 'ach_streak_7'
  /// FOREIGN KEY (achievement_id) REFERENCES achievements (id)
  final String achievementId;

  /// 実績を解除した日時
  /// DateTime 型で保存
  /// データベースには millisecondsSinceEpoch（ミリ秒）で保存
  /// 例: DateTime(2024, 11, 10, 14, 30)
  final DateTime unlockedAt;

  /// テーマ報酬を受け取ったかどうか
  /// false (0) = まだ受け取っていない
  /// true (1) = 受け取り済み
  /// 使い方:
  /// - 実績解除時: false
  /// - 「テーマを受け取る」ボタンをタップ: true
  final bool themeReceived;

  /// コンストラクタ
  /// required について:
  /// - 必須パラメータ
  /// - インスタンス作成時に必ず指定する必要がある
  UserAchievement({
    required this.id,
    required this.achievementId,
    required this.unlockedAt,
    required this.themeReceived,
  });

  /// データベースの Map から UserAchievement オブジェクトを作成
  /// fromMap について:
  /// - ファクトリーコンストラクタ
  /// - データベースから取得した Map を UserAchievement に変換
  /// 使い方:
  /// final map = {
  ///   'id': 'user_ach_001',
  ///   'achievement_id': 'ach_first_habit',
  ///   'unlocked_at': 1699999999999,  // ミリ秒
  ///   'theme_received': 0,            // 0 or 1
  /// };
  /// final userAchievement = UserAchievement.fromMap(map);
  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      id: map['id'] as String,
      achievementId: map['achievement_id'] as String,

      // unlocked_at について:
      // - データベースには int (ミリ秒) で保存
      // - DateTime.fromMillisecondsSinceEpoch() で DateTime に変換
      // 例:
      // 1699999999999 → DateTime(2023, 11, 15, 6, 13, 19)
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(
        map['unlocked_at'] as int,
      ),

      // theme_received について:
      // - データベースには int (0 or 1) で保存
      // - bool に変換: 0 → false, 1 → true
      // == 1 について:
      // - 1 なら true
      // - 0 なら false
      themeReceived: (map['theme_received'] as int) == 1,
    );
  }

  /// UserAchievement オブジェクトを Map に変換
  /// toMap について:
  /// - データベースに保存する際に使用
  /// - UserAchievement → Map の変換
  /// 使い方:
  /// final userAchievement = UserAchievement(
  ///   id: 'user_ach_001',
  ///   achievementId: 'ach_first_habit',
  ///   unlockedAt: DateTime.now(),
  ///   themeReceived: false,
  /// );
  /// final map = userAchievement.toMap();
  /// await db.insert('user_achievements', map);
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'achievement_id': achievementId,

      // millisecondsSinceEpoch について:
      // - DateTime を int (ミリ秒) に変換
      // - データベースには整数で保存
      // 例:
      // DateTime(2024, 11, 10, 14, 30) → 1699622400000
      'unlocked_at': unlockedAt.millisecondsSinceEpoch,

      // bool を int に変換
      // - true → 1
      // - false → 0
      // 三項演算子: 条件 ? true の場合 : false の場合
      'theme_received': themeReceived ? 1 : 0,
    };
  }

  /// 解除日時を読みやすい形式で取得
  /// getter について:
  /// - 関数のように呼び出せるプロパティ
  /// - userAchievement.formattedDate のように使う
  /// 使い方:
  /// final userAchievement = UserAchievement(...);
  /// print(userAchievement.formattedDate);
  /// // 出力: 2024年11月10
  String get formattedDate {
    // padLeft(2, '0') について:
    // - 2桁になるように左側を0で埋める
    // - 例: 1 → 01, 12 → 12
    return '${unlockedAt.year}年'
        '${unlockedAt.month}月'
        '${unlockedAt.day}日';
  }

  /// 解除日時を短い形式で取得
  /// 使い方:
  /// print(userAchievement.shortDate);
  /// // 出力: 2024/11/10
  String get shortDate {
    return '${unlockedAt.year}/'
        '${unlockedAt.month.toString().padLeft(2, '0')}/'
        '${unlockedAt.day.toString().padLeft(2, '0')}';
  }

  /// 解除してからの経過日数を取得
  /// 使い方:
  /// print('${userAchievement.daysAgo}日前に解除');
  /// // 出力: 5日前に解除
  int get daysAgo {
    // DateTime.now() = 現在の日時
    // difference() = 2つの日時の差
    // inDays = 日数に変換
    return DateTime.now().difference(unlockedAt).inDays;
  }

  /// 今日解除したかどうか
  /// 使い方:
  /// if (userAchievement.isUnlockedToday) {
  ///   print('今日解除しました！');
  /// }
  bool get isUnlockedToday {
    final now = DateTime.now();
    return unlockedAt.year == now.year &&
        unlockedAt.month == now.month &&
        unlockedAt.day == now.day;
  }

  /// UserAchievement のコピーを作成（一部のフィールドを変更）
  /// copyWith について:
  /// - イミュータブル（変更不可）なオブジェクトを扱うための手法
  /// - 既存のオブジェクトをベースに、一部だけ変更した新しいオブジェクトを作成
  ///
  /// なぜ必要？
  /// - final で定義されたフィールドは変更できない
  /// - でも「themeReceived だけ true に変更したい」という場面がある
  /// - copyWith で新しいオブジェクトを作成する
  ///
  /// 使い方:
  /// ```dart
  /// // 元のオブジェクト
  /// final original = UserAchievement(
  ///   id: 'user_ach_001',
  ///   achievementId: 'ach_first_habit',
  ///   unlockedAt: DateTime.now(),
  ///   themeReceived: false,  // まだ受け取っていない
  /// );
  ///
  /// // themeReceived だけ true に変更した新しいオブジェクトを作成
  /// final updated = original.copyWith(themeReceived: true);
  ///
  /// print(original.themeReceived);  // false（元のまま）
  /// print(updated.themeReceived);   // true（変更された）
  /// ```
  UserAchievement copyWith({
    String? id,
    String? achievementId,
    DateTime? unlockedAt,
    bool? themeReceived,
  }) {
    return UserAchievement(
      // ?? について:
      // - null でなければ左側の値を使う
      // - null なら右側の値を使う
      //
      // 例:
      // id ?? this.id
      // - id が null でなければ id を使う
      // - id が null なら this.id（元の値）を使う
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      themeReceived: themeReceived ?? this.themeReceived,
    );
  }

  /// デバッグ用の文字列表現
  ///
  /// print(userAchievement) で呼ばれる
  ///
  /// 出力例:
  /// ```
  /// UserAchievement(ach_first_habit, 2024/11/10, received: false)
  /// ```
  @override
  String toString() {
    return 'UserAchievement($achievementId, $shortDate, received: $themeReceived)';
  }
}
