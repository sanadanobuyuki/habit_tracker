import 'package:flutter/material.dart';
import '../../services/database_service.dart';

//画面上でどれだけ見えているかを検出するパッケージ
import 'package:visibility_detector/visibility_detector.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  final DatabaseService _db = DatabaseService();

  //現在の年月
  DateTime _currentMonth = DateTime.now();

  //初回読み込みが完了したかどうか
  bool _hasLoadedOnce = false;

  //再描画を強制するためのキー
  int _rebuildKey=0;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  //====================================データ読み込みたち=================================

  //初回データ読み込み
  Future<void> _loadInitial() async {
    await _loadMonthRecord();
    if(mounted){
      //読み込み完了フラグを立てる
      setState(() => _hasLoadedOnce = true);
    }
  }

  //月の記録を読み込む機能

  //表示中の月の全日付をループ
  //各日付の達成率を計算(データベース側で実行)
  //_rebuildKeyを更新してFutureBuilderに再計算を促す
  Future<void> _loadMonthRecord() async {
    //_rebuildKeyをインクリメントして、すべてのFutureBuilderを再実行
    if(mounted){
      setState(() => _rebuildKey++);
    }
  }

  //=========================================月切り替え================================
  //前の月に切り替え
  void _previousMonth() {
    if(!mounted) return;
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      });

    //記録を再読み込み
    _loadMonthRecord();
  }

  //次の月に切り替え
  void _nextMonth() {
    if(!mounted) return;
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      });
    
    //記録を再読み込み
    _loadMonthRecord();
  }

  //今月に戻る
  void _goToToday() {
    if(!mounted) return;
      setState(() {
        _currentMonth = DateTime.now();
      });
    
    //記録を再読み込み
    _loadMonthRecord();
  }

  //================================その他たち===================================================================
  //達成率に応じた色変更(ヒートマップ要素)
  Color _getHeatColor(double rate) {
    //テーマに合わせた色選択
    final colorScheme=Theme.of(context).colorScheme;

                                  //onSurfaceVariant:テーマに合わせた背景色
    if (rate <= 0.0) return colorScheme.onSurfaceVariant.withValues(alpha:0.1);
    if (rate <= 0.2) return Colors.red.shade100;
    if (rate <= 0.4) return Colors.orange.shade200;
    if (rate <= 0.6) return Colors.yellow.shade400;
    if (rate <= 0.8) return Colors.lightGreen.shade500;
    return Colors.green.shade500;
  }

  //指定日の達成率を取得
  Future<double> _getCompletionRate(DateTime date)async{
    final dateString=_formatDate(date);

    //データベースから直接達成率を取得
    return await _db.getCompletionRateForDate(dateString);
  }

  //今日の達成率を取得（デバッグ用）
  Future<double> _getTodayCompletionRate() async{
    return await _getCompletionRate(DateTime.now());
  }

  //日付をYYYY-MM-DD形式に変換
  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  //============================================================================================================

  //UI構築
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('calendar-screen'),
      onVisibilityChanged: (info) {
        //画面が表示されたとき(50%以上見えていたら)パッケージのやつ
        if (info.visibleFraction > 0.5 && _hasLoadedOnce && mounted) {
          //print("カレンダーが表示されました-データ再読み込み");
          _loadMonthRecord();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody()
      ),
    );
  }

  //AppBarを構築
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

  //Bodyを構築
  Widget _buildBody() {
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
          tooltip: "前月",
        ),

        //年月表示
        Text(
          '${_currentMonth.year}年${_currentMonth.month}月',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),
        ),

        //次月ボタン
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right),
          tooltip: "次月",
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue
          ),
        ),
        Text(
          "日",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red
          ),
        ),
      ],
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

        return _buildDateCell(date,day);
      },
    );
  }

  //日付セルを構築
  Widget _buildDateCell(DateTime date,int day){

    //今日かどうかを判定
    final isToday=_isToday(date);

    return FutureBuilder<double>(
      key: ValueKey('$_rebuildKey-${_formatDate(date)}'),
      future: _getCompletionRate(date),
      builder: (context,snapshot){
        //データ読み込み中
        if(!snapshot.hasData){
          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                ? Border.all(color: Theme.of(context).colorScheme.primary,width:3)
                : null,
            ),
            child: Center(child: Text('$day')),
          );
        }

        final rate=snapshot.data!;
        final color=_getHeatColor(rate);
        final scheme=Theme.of(context).colorScheme;

        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: isToday
              ? Border.all(color:scheme.primary,width:3)
              : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                color: rate > 0.0 ? Colors.black : scheme.onSurface,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }
    );
  }

  //今日かどうかを判定するbool文
  bool _isToday(DateTime date){
    final now=DateTime.now();
    return date.year==now.year &&
          date.month==now.month &&
          date.day==now.day;
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 12),
            _buildTodayCompletionRate(),
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

  //今日の達成率表示を構築
  Widget _buildTodayCompletionRate(){ 
    //今日の達成率を表示するやつ(デバッグ用)
    //FutureBuilder:非同期処理が完了するまで待ち、その後に特定のウィジェットを構築
    return FutureBuilder<double>(
      key: ValueKey('today-rate-$_rebuildKey'),
      future: _getTodayCompletionRate(),
      //snapshot:非同期プログラミングやウィジェットの状態の変更を監視する
      builder: (context,snapshot){
        //connectionState:非同期操作の状態
        if(snapshot.connectionState==ConnectionState.waiting){
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if(snapshot.hasError){
          return const Text(
            "エラー",
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          );
        }

        final rate=snapshot.data ?? 0.0;
        final percentage=(rate*100).toInt();

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getHeatColor(rate),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child:Text(
            "今日: $percentage%",
            style: TextStyle(
              color: rate>0.0
                ? Colors.black
                : Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  //凡例の各項目を構築
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
}

// 処理の流れ
// 1.画面初期化（initState）

// 2.データ読み込み（_loadInitial）

// 3.月の記録読み込み(_loadMonthRecord)

// 4.カレンダー表示（build）

// 5.各日付セルで達成率を取得・表示（_buildDateCell）

// 各工程の詳細

// 1.画面初期化について
// _CalendarScreenState

// //現在表示している年月
// DateTime _currentMonth=DateTime.now();

// // 初回読み込みが完了したかどうか
//   bool _hasLoadedOnce = false;

// // 再描画を強制するためのキー 重要！
// int _rebuildKey = 0;

// ・_rebuildKeyの役割

// FutureBuilderは通常、同じfutureなら再実行しないが
// _rebuildKeyを変更することで「新しいキー」となり、FutureBuilderが再実行される。
// これにより、月が替わったときやカレンダーが表示されたときにデータを再取得できる。


// 2.データ読み込みの仕組みについて

// //初回読み込み
// _loadInitial()

// Future<void> _loadInitial() async {
//   await _loadMonthRecord();//月の記録を読み込む
//   if(mounted){
//     setState(()　=> _hasLoadedOnce = true); //読み込み完了フラグを立てる
// 　}
// }

// //月の記録を読み込む
// _loadMonthRecord()

// Future<void> _loadMonthRecord() async {
//   // _rebuildKeyをインクリメント
//   // これにより、すべてのFutureBuilderが再実行される
//   if(mounted){
//     setState(() => _rebuildKey++);
//   }
// }

// この関数は実際にデータを取得しない
// _rebuildKeyを変更することで,各日付セルのFutureBuilderに「データを再取得しろ」と指示を出すだけ


// 3.カレンダーの構築について

// //グリッド状にカレンダーを作成
// _buildCalendar()

// Widget _buildCalendar() {
//   //月の最初の日:2025/12/01
//   final firstDay = DateTime(_currentMonth.year,_currentMonth.month,1);

//   //月の最後の日:2025/12/31
//   final lastDay = DateTime(_currentMonth.year,_currentMonth.month + 1,0);

//   //月最初の日が何曜日か:1(月)～7(日)
//   //例：12/1が日曜日なら startWeekday=7
//   final startWeekday=firstDay.weekday;

  
//   return GridView.builder(
//     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount:7, //横に7列(月～日)
//       childAspectRatio:1.0, //正方形のセル
//     ),

//     //表示するセルの総数
//     //月の日数＋空白セル
//     //例：31日＋6空白=37セル
//     itemCount: lastDay.day + startWeekday - 1,

//     itemBuilder:(context,index){
//       //空白の分だけ空セルを返す
//       //例: startWeekday=7(日曜始まり)なら  ここでstartWeekday-1とindexの差だけ空セル配置する
//       // index 0～5は空セル
//       if(index<startWeekday - 1){
//         return const SizedBox(); //空セル
//       }

//       //日付の計算
//       //index=6 - 7 + 2 = 1(1日)
//       final day=index-startWeekday+2;

//       //完全なDateTimeを作成
//       //dayだけでは何年何月の1日かが分からないため完全なものが必要
//       final date = DateTime(_currentMonth.year,_currentMonth.month,day);

//       return _buildDateCell(date,day);
//     },
//   );
// }

