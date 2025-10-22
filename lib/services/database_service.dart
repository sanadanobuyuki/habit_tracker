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
  //1回目：データベースがなければ作成、あれば開く
  //二回目以降：既に開いているデータベースを返す
  Future<Database> get database async {
    //Future<Database>について
    //Future =「未来の値」を表す型。時間がかかる処理の結果を表す
    //例：データベースを開くのに0.1秒かかる場合、その0.1秒後の結果を表す

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
    //version:1 =データベースのバージョン(更新時に利用)
    //onCreate =初回作成時に実行する関数
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables, //テーブル作成処理を呼び出す
    );
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
    //=========habitsテーブル=========
    //役割:ユーザーが登録した習慣の情報の保存
    //例:「朝の運動」「読書」「水を飲む」
    await db.execute('''
      CREATE TABLE habits(
       id TEXT PRIMARY KEY,                      --習慣の一意な識別子
       name TEXT NOT NULL,                       --習慣の名前  
       emoji TEXT,                               --習慣を表す絵文字
       color INTEGER,                           --習慣の表示色
       target_frequency INTEGER DEFAULT 7,       --目標頻度（週あたりの回数）
       created_at INTEGER NOT NULL,              --習慣の作成日時（UNIXタイムスタンプ）
       is_deleted INTEGER DEFAULT 0              --削除フラグ（0=有効、1=削除済み）
       )
       ''');

    //========habit_recordsテーブル=========
    //役割:毎日の習慣達成記録を保存
    //例:「2024-10-02に朝の運動を達成した」という記録
    await db.execute('''
      CREATE TABLE habit_records(
       id TEXT PRIMARY KEY,                      --記録の一意な識別子
       habit_id TEXT NOT NULL,                   --習慣のID(habitsテーブルと関連付け)
       date TEXT NOT NULL,                       --記録日(YYYY-MM-DD形式)
       completed INTEGER DEFAULT 0,              --達成フラグ（0=未達成、1=達成）
       note TEXT,                                --記録に関するメモ
       recorded_at INTEGER NOT NULL,              --記録日時
       FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
       -- FOREIGN KEY =habit_idはhabitsテーブルのidを参照
       -- ON DELETE CASCADE =習慣を削除すると関連記録も削除
        )
        ''');

    //===========achirvrmentsテーブル=========
    //役割:実績の定義を保存(アプリ内で固定)
    //例:「7日連続達成」「30日間継続」など
    await db.execute('''
      CREATE TABLE achievements(
       id TEXT PRIMARY KEY,                      --実績の一意な識別子
       name TEXT NOT NULL,                       --実績の名前
       description TEXT,                         --実績の説明
       condition_type TEXT,                     --達成条件のタイプ（例:連続日数、総達成回数）
       condition_value INTEGER,                  --達成条件の値
       rarity TEXT                             --実績の希少性（例:一般、レア、エピック
       theme_id TEXT                             --実績のテーマID
       )
       ''');

    //=======user_achivementsテーブル ========
    //役割:ユーザーが獲得した実績の記録
    //例:「2024-10-15に7日連続達成を達成した」
    await db.execute('''
      CREATE TABLE user_achievements(
       id TEXT PRIMARY KEY,                      --記録の一意な識別子
       achievement_id TEXT NOT NULL,             --実績のID(achievementsテーブルと関連付け)
       unlocked_at INTEGER NOT NULL,            --実績を獲得した日時
       theme_received INTEGER DEFAULT 0,          --報酬の受け取り=未受取、1=受取済み）
      FOREIGN KEY (achievement_id) REFERENCES achievements (id)
        )
        ''');

    //========themesテーブル==========
    //役割: アプリのテーマ情報を保存
    //例:「ダークモード」「ライトモード」「カラフルテーマ」
    await db.execute('''
      CREATE TABLE themes(
        id TEXT PRIMARY KEY,                      --テーマの一意な識別子
        name TEXT NOT NULL,                       --テーマの名前
        is_default INTEGER DEFAULT 0,              --デフォルトテーマ（0=実績報酬、1=最初から使用可能)
        primary_color TEXT,                       --メインカラー(16進数)
        secondary_color TEXT,                     --サブカラー(16進数)
        is_unlocked INTEGER DEFAULT 0,              --解禁済み（0=未解禁、1=解禁済み）
        unlocked_at INTEGER                      --解禁日時
        )
        ''');

    // ========== settingsテーブル ==========
    // 役割：ユーザーの設定情報を保存
    // 例：「現在のテーマはピンク」「通知はON」など
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,    -- 設定キー（例：current_theme_id）
        value TEXT,              -- 設定値（例：theme_pink）
        updated_at INTEGER       -- 更新日時
      )
    ''');

    //=======インデックスの作成=======
    //役割:データベースの検索を高速化
    //例:「この日付のすべての記録を取得」という検索が多いので、日付でインデックスを作成

    //日付で検索数r時を高速化
    await db.execute(
      'CREATE INDEX idx_habit_records_date ON habit_records(date)',
    );

    //習慣IDで検索時を高速化
    await db.execute(
      'CREATE INDEX idx_habit_records_habit_id ON habit_records(habit_id)',
    );
  }

  //=========習慣(habits)の操作=========

  //習慣を追加する
  //requiredについて
  //required =この引数は必須(省略できない)
  Future<void> insertHabit({
    required String id, //習慣のID
    required String name, //習慣の名前
    required String emoji, //習慣の絵文字
    required int color, //習慣の表示色
    required int targetFrequency, //目標頻度
    required int createdAt, //作成日時
  }) async {
    final db = await database;

    //insert()=データベースに新しい行を追加する
    //habitsテーブルに新しい習慣を追加
    //conflictAlgorithm.replace = 既に同じIDが存在する場合は上書きする テスト用
    await db.insert('habits', {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'target_frequency': targetFrequency,
      'created_at': createdAt,
      'is_deleted': 0, //新規追加時は削除フラグを0に設定
    }, conflictAlgorithm: ConflictAlgorithm.replace); //テスト用
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
  }) async {
    final db = await database;

    await db.update(
      'habits',
      {'name': name, 'emoji': emoji, 'color': color},
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
  // 使い方の例：
  // List<Map> records = await DatabaseService().getRecordsByHabit('habit_001');
  //  結果：2024-10-02の朝の運動の記録、2024-10-01の記録、... と新しい順に返される
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
  // 使い方の例：
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
  // 使い方の例：
  // List<Map> achievements = await DatabaseService().getAllAchievements();
  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    final db = await database;
    return await db.query('achievements');
  }

  // ===== 設定(settings)の操作 =====

  // 設定を保存する
  //
  // 使い方の例：
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
  // 使い方の例：
  // String? themeId = await DatabaseService().getSetting('current_theme_id');
  // // 結果：'theme_pink' など、または null（設定がなかった場合）
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

  // データベースをクローズする（アプリ終了時に実行）
  //
  // 使い方の例：
  // await DatabaseService().closeDatabase();
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
