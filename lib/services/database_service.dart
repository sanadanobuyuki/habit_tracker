import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//DatabaseServiceクラス
//このクラスの役割
//SQLiteデータベースのすべての操作を管理する
//アプリのほかの部分からデータベースにアクセスするときの「窓口」

class DatabaseService {
  //static =アプリ全体で一つだけ存在
  //_database = このクラス内だけで使える変数
  static Database? _database;

  //データベースを取得する

  //処理:
  //1回目:データベースがなければ作成、あれば開く
  //二回目以降:既に開いているデータベースを返す
  Future<Database> get database async {
    //Future<Database>について
    //Future =「未来の値」を表す型。時間がかかる処理の結果を表す
    //例:データベースを開くのに0.1秒かかる場合、その0.1秒後の結果を表す

    if (_database != null) {
      //すでにデータベースが開いていたらそれを返す
      return _database!;
    }
    //データベースがなければ初期化して返す
    _database = await _initDatabase();
    return _database!;

    //awaitについて
    //await =「待つ」という意味Futureの結果が出るまで待機する
    //例:await database =データベースが開くまで待って、開いたその結果を取得
    //注意:awaitは「async」が付いた関数の中でしか使えない
  }

  //データベースの初期化
  //async について
  //async =この関数は時間がかかる処理を含む、という印象
  //asyncがついた関数は必ずFutureを返す
  //asyncの中でawaitを使用することができる

  Future<Database> _initDatabase() async {
    //getDatabasePath()=端末のデータベース保存場所を取得
    final dbPath = await getDatabasesPath();

    //join() =パスを結合する
    //dbPath + 'habit_flow.db'=最終的なファイルパス
    final path = join(dbPath, 'habit_flow.db');

    //openDatabase()=データベースを開く
    //version:2 =データベースのバージョン(曜日対応のため2に変更)
    //onCreate =初回作成時に実行する関数
    //onUpgrade =バージョンアップ時に実行する関数
    return await openDatabase(
      path,
      version: 2, // バージョンを2に変更
      onCreate: _createTables, //テーブル作成処理を呼び出す
      onUpgrade: _onUpgrade, // アップグレード処理を追加
    );
  }

  // データベースのアップグレード処理
  // 既存のデータベースがある場合、ここで変更を適用
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // バージョン1から2へのアップグレード
      // 既存のhabitsテーブルを削除して再作成
      await db.execute('DROP TABLE IF EXISTS habits');
      await db.execute('DROP TABLE IF EXISTS habit_records');

      // 新しいテーブルを作成
      await _createHabitsTable(db);
      await _createHabitRecordsTable(db);

      // インデックスも再作成
      await db.execute(
        'CREATE INDEX idx_habit_records_date ON habit_records(date)',
      );
      await db.execute(
        'CREATE INDEX idx_habit_records_habit_id ON habit_records(habit_id)',
      );
    }
  }

  //テーブルを作成する(初回のみ実行)
  //テーブルとはデータベース内のデータを整理するための構造
  //習慣情報を保存するテーブル
  //記録を保存するテーブル
  //実績を保存するテーブル

  //Future<void>について
  //void=この関数は何も返さない
  //Future<void>=時間がかかる処理だけど、結果として返す値はない

  Future<void> _createTables(Database db, int version) async {
    await _createHabitsTable(db);
    await _createHabitRecordsTable(db);
    await _createAchievementsTable(db);
    await _createUserAchievementsTable(db);
    await _createThemesTable(db);
    await _createSettingsTable(db);

    // インデックスの作成
    await db.execute(
      'CREATE INDEX idx_habit_records_date ON habit_records(date)',
    );
    await db.execute(
      'CREATE INDEX idx_habit_records_habit_id ON habit_records(habit_id)',
    );
  }

  // habitsテーブルを作成
  Future<void> _createHabitsTable(Database db) async {
    await db.execute('''
      CREATE TABLE habits(
       id TEXT PRIMARY KEY,
       name TEXT NOT NULL,
       emoji TEXT,
       color INTEGER,
       target_frequency INTEGER DEFAULT 7,
       days_of_week TEXT,
       created_at INTEGER NOT NULL,
       is_deleted INTEGER DEFAULT 0
       )
       ''');
  }

  // habit_recordsテーブルを作成
  Future<void> _createHabitRecordsTable(Database db) async {
    await db.execute('''
      CREATE TABLE habit_records(
       id TEXT PRIMARY KEY,
       habit_id TEXT NOT NULL,
       date TEXT NOT NULL,
       completed INTEGER DEFAULT 0,
       note TEXT,
       recorded_at INTEGER NOT NULL,
       FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
        )
        ''');
  }

  // achievementsテーブルを作成
  Future<void> _createAchievementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE achievements(
       id TEXT PRIMARY KEY,
       name TEXT NOT NULL,
       description TEXT,
       condition_type TEXT,
       condition_value INTEGER,
       rarity TEXT,
       theme_id TEXT
       )
       ''');
  }

  // user_achievementsテーブルを作成
  Future<void> _createUserAchievementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_achievements(
       id TEXT PRIMARY KEY,
       achievement_id TEXT NOT NULL,
       unlocked_at INTEGER NOT NULL,
       theme_received INTEGER DEFAULT 0,
      FOREIGN KEY (achievement_id) REFERENCES achievements (id)
        )
        ''');
  }

  // themesテーブルを作成
  Future<void> _createThemesTable(Database db) async {
    await db.execute('''
      CREATE TABLE themes(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        primary_color TEXT,
        secondary_color TEXT,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at INTEGER
        )
        ''');
  }

  // settingsテーブルを作成
  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at INTEGER
      )
    ''');
  }

  //=========習慣(habits)の操作=========

  //習慣を追加する
  //requiredについて
  //required =この引数は必須(省略できない)
  //
  // daysOfWeek について:
  // null = 毎日
  // "1,3,5" = 月・水・金のみ (1=月, 2=火, ..., 7=日)
  Future<void> insertHabit({
    required String id, //習慣のID
    required String name, //習慣の名前
    required String emoji, //習慣の絵文字
    required int color, //習慣の表示色
    required int targetFrequency, //目標頻度
    String? daysOfWeek, //曜日指定 (null=毎日)
    required int createdAt, //作成日時
  }) async {
    final db = await database;

    //insert()=データベースに新しい行を追加する
    //habitsテーブルに新しい習慣を追加
    //conflictAlgorithm.replace = 同じIDがあれば上書き(テスト用)
    await db.insert('habits', {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'target_frequency': targetFrequency,
      'days_of_week': daysOfWeek, // 追加
      'created_at': createdAt,
      'is_deleted': 0, //新規追加時は削除フラグを0に設定
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //すべての習慣を取得する
  //List<Map<String,dynamic>>について
  //List =リスト(配列)。複数のデータをまとめたもの
  //Map=キーと値のペア{'名前':'太郎','名前2':'次郎'}のような形式
  //<String,dynamic> =キーが文字列、値が任意の型(文字列,数値など)
  //Future<List<Map<String,dynamic>>> 時間がかかる処理で最終的にリストが返ってくる

  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final db = await database;

    return await db.query(
      // query() = データベースからデータを取得
      // 'habits' = habitsテーブルから取得
      // where: 'is_deleted = ?' = 削除されていない習慣だけ取得
      // whereArgs: [0] = 削除フラグが0の習慣
      // orderBy: 'created_at ASC' = 作成日時の古い順に並べる
      'habits',
      where: 'is_deleted = ?',
      whereArgs: [0], //削除されていない習慣のみ取得
      orderBy: 'created_at ASC', //作成日時の昇順でソート
    );
  }

  //習慣を更新する

  //使い方
  //await DatabaseService().updateHabit(
  // id: 'habit_001',
  //name: '新しい習慣名',
  // emoji: '🏃‍♂️',
  // color: 0xFF00FF,
  //);
  Future<void> updateHabit({
    required String id, //更新する習慣のID
    String? name, //新しい習慣名(省略可能)
    String? emoji, //新しい絵文字(省略可能)
    int? color, //新しい表示色(省略可能)
    String? daysOfWeek, //新しい曜日指定(省略可能)
  }) async {
    final db = await database;

    await db.update(
      'habits',
      {
        'name': name,
        'emoji': emoji,
        'color': color,
        'days_of_week': daysOfWeek,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //習慣を削除する
  //実際には削除フラグを1に更新するだけ
  //理由:過去の記録は保持したいため
  Future<void> deleteHabit(String id) async {
    final db = await database;

    await db.update(
      'habits',
      {'is_deleted': 1}, //削除フラグを1に設定
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //=========記録(habit_records)の操作=========
  //記録を追加する
  //String?について
  //? =この引数は省略可能、nullを許容する
  //使い方の例
  //await DatabaseService().insertRecord(
  // Id: 'record_001',
  // habitid: 'habit_001',
  //date: '2024-10-02',
  // completed: 1,
  // recordedAt:DateTime.now().millisecondsSinceEpoch,)

  Future<void> insertRecord({
    required String id, //記録のID
    required String habitId, //習慣のID
    required String date, //記録日(YYYY-MM-DD形式)
    required int completed, //達成フラグ
    required int recordedAt, //記録日時
    String? note, //メモ(省略可能)
  }) async {
    final db = await database;
    await db.insert('habit_records', {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'completed': completed,
      'note': note,
      'recorded_at': recordedAt,
    });
  }

  //特定の日すべての記録を取得する
  //使い方の例
  //List<Map> records =await DatavaseService().getRecordsByDate('2024-10-02');
  Future<List<Map<String, dynamic>>> getRecordsByDate(String date) async {
    final db = await database;

    return await db.query(
      'habit_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'recorded_at ASC', //習慣IDで並べる
    );
  }

  // 特定の習慣の全ての記録を取得する
  //
  // 使い方の例:
  // List<Map> records = await DatabaseService().getRecordsByHabit('habit_001');
  //  結果:2024-10-02の朝の運動の記録、2024-10-01の記録、... と新しい順に返される
  Future<List<Map<String, dynamic>>> getRecordsByHabit(String habitId) async {
    final db = await database;

    // habitId の全ての記録を取得
    // orderBy: 'date DESC' = 新しい日付から順に並べる
    return await db.query(
      'habit_records',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
  }

  // 記録を更新する
  //
  // 使い方の例:
  // await DatabaseService().updateRecord(
  //   id: 'record_001',
  //   completed: 1,  // 1 = 達成に変更
  //   note: '朝5時に運動した',
  // );
  Future<void> updateRecord({
    required String id,
    required int completed,
    String? note,
  }) async {
    final db = await database;
    await db.update(
      'habit_records',
      {'completed': completed, 'note': note},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== 実績(achievements)の操作 =====

  // 全ての実績を取得する
  //
  // 使い方の例:
  // List<Map> achievements = await DatabaseService().getAllAchievements();
  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    final db = await database;
    return await db.query('achievements');
  }

  // ===== 設定(settings)の操作 =====

  // 設定を保存する
  //
  // 使い方の例:
  // await DatabaseService().saveSetting('current_theme_id', 'theme_pink');
  //
  // これにより「現在使用中のテーマはピンク」という設定が保存される
  Future<void> saveSetting(String key, String value) async {
    final db = await database;

    // insert() with conflictAlgorithm: ConflictAlgorithm.replace
    // = 既に同じkeyが存在すれば上書き、なければ新規作成
    await db.insert('settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 設定を取得する
  //
  // 使い方の例:
  // String? themeId = await DatabaseService().getSetting('current_theme_id');
  // // 結果:'theme_pink' など、または null(設定がなかった場合)
  Future<String?> getSetting(String key) async {
    final db = await database;

    // key に一致する設定を検索
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    // データが見つかれば value を返す、見つからなければ null を返す
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }

  // データベースをクローズする(アプリ終了時に実行)
  //
  // 使い方の例:
  // await DatabaseService().closeDatabase();
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
