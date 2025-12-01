//achievement.dart
//実績データを扱いやすくするためのクラス
//データベースのMapをオブジェクトに変換したり、その逆を行う
class Achievement {
  final String id;

  ///実績の一意な識別子
  final String name;

  ///実績の名前
  final String description;

  ///実績の説明
  final String conditionType;

  ///条件のタイプ
  final int conditionValue;

  final String? rarity;

  //開放するテーマID
  final String? themeId;

  ///報酬テーマID（null可能）

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.conditionType,
    required this.conditionValue,
    this.rarity,
    this.themeId,
  });

  //データベースのMapからAchievementオブジェクトを作成
  //fromMapについて
  //ファクトリーコンストラクタ
  //データベースから取得したMapをAchievementオブジェクトに変換
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      conditionType: map['condition_type'] as String,
      conditionValue: map['condition_value'] as int,
      rarity: map['rarity'] as String?,
      themeId: map['theme_id'] as String?,
    );
  }

  //Achievementオブジェクトをデータベース用のMapに変換
  //toMapについて
  //データベースに保存するためにAchievementオブジェクトをMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'condition_type': conditionType,
      'condition_value': conditionValue,
      'rarity': rarity,
      'theme_id': themeId,
    };
  }

  //条件タイプに応じた絵文字を取得
  //getter 関数のように呼び出せるプロパティ
  String get emoji {
    switch (conditionType) {
      case 'habit_count':
        return '📋'; // 習慣の数
      case 'total_days':
        return '📅'; // 累計達成日数
      case 'streak':
        return '🔥'; // 連続達成日数
      default:
        return '🏆'; // その他の実績
    }
  }

  //条件の単位を取得
  String get unit {
    switch (conditionType) {
      case 'habit_count':
        return '個'; // 習慣の数
      case 'streak':
        return '日連続'; // 連続達成日数
      case 'total_days':
        return '日'; // 日数
      default:
        return ''; // その他の実績
    }
  }

  //デバック用の文字列表現
  @override
  String toString() {
    return 'Achievement($name, $description, $conditionType: $conditionValue)';
  }
}
