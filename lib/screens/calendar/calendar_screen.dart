import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/habit.dart';

//画面上でどれだけ見えているかを検出するパッケージ
import 'package:visibility_detector/visibility_detector.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  //ロード処理を起こすフラグ
  bool _isLoading = true;

  final DatabaseService _db = DatabaseService();

  //取得した習慣を入れるリスト(Habit型限定)
  List<Habit> _habits = [];

  //日付ごとの記録を保存する変数
  final Map<String, List<Map<String, dynamic>>> _recordByDate = {};

  //現在の年月
  DateTime _currentMonth = DateTime.now();

  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  //====================================データ読み込みたち=================================

  Future<void> _loadInitial() async {
    await _loadData();
    await _loadMonthRecord();
    setState(() {
      _hasLoadedOnce = true;
    });
  }

  //月の記録を読み込む機能
  Future<void> _loadMonthRecord() async {
    //既存のデータをクリア
    _recordByDate.clear();

    //月の最終日を取得
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    //1日から最終日までの繰り返し
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dateString = _formatDate(date);

      //その日の記録を取得
      final records = await _db.getRecordsByDate(dateString);
      //レコードが空じゃなかったら登録
      if (records.isNotEmpty) {
        _recordByDate[dateString] = records;
      }
    }

    //UI更新
    setState(() {});
  }

  //すべての習慣をデータベースから取得
  Future<void> _loadData() async {
    //時間がかかるからロード処理
    setState(() => _isLoading = true);

    //エラーが起きてもアプリがクラッシュしないようにする
    try {
      //すべての習慣を取得
      final habitsData = await _db.getAllHabits();

      //mapをHabitに変換
      _habits = habitsData.map((data) => Habit.fromMap(data)).toList();

      //ロード処理がおわっていたら画面更新
      setState(() => _isLoading = false);
    } catch (e) {
      //エラー処理
      _showSnackBar('エラーが発生しました:$e');
      setState(() => _isLoading = false);
    }
  }

  //=========================================月切り替え================================
  //前の月に切り替え
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    //記録を再読み込み
    _loadMonthRecord();
  }

  //次の月に切り替え
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    //記録を再読み込み
    _loadMonthRecord();
  }

  //今月に戻る
  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
    });
    //記録を再読み込み
    _loadMonthRecord();
  }

  //================================その他たち===================================================================
  //達成率に応じた色変更(ヒートマップ要素)
  Color _getHeatColor(double rate) {
    if (rate <= 0.0) return Colors.grey.shade200;
    if (rate <= 0.2) return Colors.red.shade100;
    if (rate <= 0.4) return Colors.orange.shade200;
    if (rate <= 0.6) return Colors.yellow.shade400;
    if (rate <= 0.8) return Colors.lightGreen.shade500;
    return Colors.green.shade500;
  }

  //習慣の達成率を計算
  double _getCompletionRate(DateTime date) {
    //日付を文字列に変換
    final dateString = _formatDate(date);
    //その日の記録(_loadMonthRecordで登録した)を取得
    final records = _recordByDate[dateString];

    //記録がなければ0.0%
    if (records == null || records.isEmpty) {
      return 0.0;
    }

    //その日が対象の習慣を抽出
    final weekday = date.weekday; //1(月)~7(日)
    //条件に合う要素だけを抽出
    //where(weekday)が条件
    final targetHabits = _habits
        .where((habit) => habit.isTargetDay(weekday))
        .toList();

    //対象習慣がない場合
    if (targetHabits.isEmpty) {
      return 0.0;
    }

    //達成した習慣をカウント
    int completedCount = 0;
    //対象の習慣を一つずつチェック
    for (var habit in targetHabits) {
      //firstWhere()は条件に合う最初の要素を探す
      final record = records.firstWhere(
        (r) => r['habit_id'] == habit.id,
        //orElse:見つからなかった場合に返す値
        orElse: () => <String, dynamic>{},
      );

      //記録があるかつ達成していると
      if (record.isNotEmpty && record['completed'] == 1) {
        completedCount++;
      }
    }

    return completedCount / targetHabits.length;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  //日付や月を二桁表示に合わせる
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  //============================================================================================================

  //UI構築
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('calendar-screen'),
      onVisibilityChanged: (info) {
        //画面が表示されたとき(50%以上見えていたら)パッケージのやつ
        if (info.visibleFraction > 0.5 && _hasLoadedOnce) {
          //print("カレンダーが表示されました-データ再読み込み");
          _loadData();
        }
      },
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("カレンダー"),
      actions: [
        //今月に戻るボタン
        IconButton(
          onPressed: _goToToday,
          icon: const Icon(Icons.today),
          tooltip: '今月に戻る',
        ),
      ],
    );
  }

  Widget _buildBody() {
    //ロード中なら
    if (_isLoading) {
      //ぐるぐるさせる
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          //年月ヘッダー
          _buildMonthHeader(),
          const SizedBox(height: 16),

          //曜日ヘッダー
          _buildWeekdayHeader(),
          const SizedBox(height: 8),

          //カレンダー本体
          _buildCalendar(),
          const SizedBox(height: 24),

          //凡例
          _buildLegend(),
        ],
      ),
    );
  }

  //年月ヘッダー
  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //前月ボタン
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left),
        ),

        //年月表示
        Text(
          '${_currentMonth.year}年${_currentMonth.month}月',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        //次月ボタン
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  //曜日ヘッダー
  Widget _buildWeekdayHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text("月", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("火", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("水", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("木", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("金", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          "土",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        Text(
          "日",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ],
    );
  }

  //凡例
  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "達成率の凡例",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLegendItem("未記録", Colors.grey.shade200),
            _buildLegendItem("～20%", Colors.red.shade100),
            _buildLegendItem("21～40%", Colors.orange.shade200),
            _buildLegendItem("41～60%", Colors.yellow.shade400),
            _buildLegendItem("61～80%", Colors.lightGreen.shade500),
            _buildLegendItem("81～100%", Colors.green.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  //カレンダー本体
  Widget _buildCalendar() {
    //月の最初の日
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    //月の最後の日
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    //月の最初の日が何曜日か 1(月)~7(日)
    final startWeekday = firstDay.weekday;

    //格子状に日付を並べる
    return GridView.builder(
      //コンテンツのサイズに合わせて縮む
      shrinkWrap: true,
      //GridView自体はスクロールさせない
      physics: const NeverScrollableScrollPhysics(),
      //グリッドの列数とセルの形を指定
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //横に何個並べるか
        crossAxisCount: 7,
        //縦と横の比率1.0は正方形
        childAspectRatio: 1.0,
      ),
      //グリッド表示の数
      itemCount: lastDay.day + startWeekday - 1,
      //各セルの表示方法の定義
      itemBuilder: (context, index) {
        //空白の分だけ空セルを返す
        //indexは0から始まるため-1で合わせてる
        if (index < startWeekday - 1) {
          return const SizedBox(); //空セル
        }

        //日付の計算
        //index=5 startWeekday=6の場合
        //5-6=-1になるため1から始まるよう+2する
        final day = index - startWeekday + 2;

        //計算したdayから完全なDateTimeを作成
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);

        //達成率を取得
        final rate = _getCompletionRate(date);
        //達成率に応じた色を取得
        final color = _getHeatColor(rate);

        //日付セルを表示
        return Container(
          //周りに2ピクセルの余白
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color, //背景色
            borderRadius: BorderRadius.circular(8), //角を丸く
          ),
          child: Center(child: Text('$day')),
        );
      },
    );
  }
}
