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

  //達成率データをキャッシュ
  Map<String , double> _completionRateCache={};
  //キャッシュの原理
  //非同期処理を事前に完了させ、画像描画時は同期的にメモリから取得

  //ローディング状態
  bool _isLoading=false;

   //金色のグラデーション定義
  final LinearGradient _glowingGoldGradient = const LinearGradient(
    //begin グラデーションを始める位置
    begin: Alignment.topLeft,
    //end グラデーションを終える位置
    end: Alignment.bottomRight,
    //stops グラデーションの各色が始まる位置を0.0から1.0の範囲で指定
    stops: [0.0, 0.45, 0.7, 1.0],
    colors: [
      Color(0xFFFFF8E1), // 強いハイライト（光）
      Color(0xFFFFE082), // 明るい金
      Color(0xFFD4AF37), // ベース金
      Color(0xFFB8962E), // 影
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  //====================================データ読み込みたち=================================

  //初回データ読み込み
  Future<void> _loadInitial() async {
    await _loadMonthRecord();
    if (mounted) {
      //読み込み完了フラグを立てる
      setState(() => _hasLoadedOnce = true);
    }
  }

  //月の記録を読み込む機能

  //表示中の月の全日付をループ
  //各日付の達成率を計算(データベース側で実行)
  //先に全データを取得してメモリに保存
  Future<void> _loadMonthRecord() async {
    //ロード中なら何もしない
    if(_isLoading) return;

    setState(()=> _isLoading=true);

    //月の最初の日
    final lastDay=DateTime(_currentMonth.year,_currentMonth.month+1,0);

    //新しいキャッシュを作成
    final newCache=<String,double>{};

    //各日付の達成率を取得
    //その月のすべての日付の達成率を一度に取得
    for(int day=1;day<=lastDay.day;day++){
      final date=DateTime(_currentMonth.year,_currentMonth.month,day);
      final dateString=_formatDate(date);

      //達成率を取得してキャッシュに保存
      final rate=await _db.getCompletionRateForDate(dateString);

      //メモリに保存
      newCache[dateString]=rate;
    }

    if (mounted) {
      setState((){

        //一度に反映するからちらつかない
        _completionRateCache=newCache;

        _isLoading=false;
      });
    }
  }

  //=========================================月切り替え================================
  //前の月に切り替え
  void _previousMonth() {
    if (!mounted) return;
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);

      //キャッシュをクリア
      _completionRateCache.clear();
    });

    //記録を再読み込み
    _loadMonthRecord();
  }

  //次の月に切り替え
  void _nextMonth() {
    if (!mounted) return;
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);

      //キャッシュをクリア
      _completionRateCache.clear();
    });

    //記録を再読み込み
    _loadMonthRecord();
  }

  //今月に戻る
  void _goToToday() {
    if (!mounted) return;
    setState(() {
      _currentMonth = DateTime.now();

      //キャッシュをクリア
      _completionRateCache.clear();
    });

    //記録を再読み込み
    _loadMonthRecord();
  }

  //================================その他たち===================================================================
  //達成率に応じた色変更(ヒートマップ要素)
  Color _getHeatColor(double rate) {
    //テーマに合わせた色選択
    final colorScheme = Theme.of(context).colorScheme;

    //onSurfaceVariant:テーマに合わせた背景色
    if (rate <= 0.0) return colorScheme.onSurfaceVariant.withValues(alpha: 0.1);
    if (rate <= 0.2) return Colors.red.shade100;
    if (rate <= 0.4) return Colors.orange.shade200;
    if (rate <= 0.6) return Colors.yellow.shade400;
    if (rate <= 0.8) return  Colors.lightGreen.shade500;
    if (rate < 1.0) return Colors.green.shade500;
    return const Color(0xFFD4AF37); // 100%
  }

  //指定日の達成率を取得
  double? _getCompletionRate(DateTime date){
    final dateString = _formatDate(date);

    //データベースから直接達成率を取得
    return _completionRateCache[dateString];
  }

  //今日の達成率を取得（デバッグ用）
  double _getTodayCompletionRate(){
    return _getCompletionRate(DateTime.now()) ?? 0.0;
  }

  //日付をYYYY-MM-DD形式に変換
  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _showLegendDialog(){
    showDialog(
      context: context,
      builder: (context) => Dialog(
        //ダイアログ全体を角丸にする
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha:0.95),
              ],
            ),
          ),
          child:SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //ヘッダー部分
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient( //グラデーション
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        //アプリの主要な色 primary
                        Theme.of(context).colorScheme.primaryContainer,
                        //補助的な色 secondary
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: const BorderRadius.only( //上部の角だけ丸くする
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size:28,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "達成率の凡例",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                
                //コンテンツ部分
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    //子要素を横幅いっぱいに引き延ばす
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTodayCompletionRate(),
                      // const SizedBox(height: 20),

                      //凡例リスト
                      _buildLegendItem("未記録", Colors.grey.shade200),
                      const SizedBox(height: 8),
                      _buildLegendItem("～20%", Colors.red.shade100),
                      const SizedBox(height: 8),
                      _buildLegendItem("21～40%", Colors.orange.shade200),
                      const SizedBox(height: 8),
                      _buildLegendItem("41～60%", Colors.yellow.shade400),
                      const SizedBox(height: 8),
                      _buildLegendItem("61～80%", Colors.lightGreen.shade500),
                      const SizedBox(height: 8),
                      _buildLegendItem("81～99%", Colors.green.shade500),
                      const SizedBox(height: 8),
                      _buildLegendItem("100%",null,gradient: _glowingGoldGradient),

                      const SizedBox(height: 20),

                      //閉じるボタン
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: Text("閉じる"),
                        style: FilledButton.styleFrom(
                          //symmetric:対象的な余白
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }

  //AppBarを構築
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("カレンダー"),
      actions: [
        //凡例表示
        IconButton(
          onPressed: _showLegendDialog,
          icon: const Icon(Icons.help_outline),
          tooltip: "凡例を表示",
        ),

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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        Text(
          "日",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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

        return _buildDateCell(date, day);
      },
    );
  }

  //日付セルを構築
  //セル描画時はメモリから即座に取得
  Widget _buildDateCell(DateTime date, int day) {
    //今日かどうかを判定
    final isToday = _isToday(date);

    //キャッシュから達成率を取得
    //今日の達成率をデータベースから直接取得
    final rate = _getCompletionRate(date);
    final scheme=Theme.of(context).colorScheme;

    //達成率がまだロードされていない場合
    if(rate==null){
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: isToday
            ? Border.all(color: scheme.primary,width: 3)
            : null,
        ),
        child: Center(
          child: Text(
            "$day",
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    //達成率がロード済みの場合
    final color=_getHeatColor(rate);

    //100%達成の場合はグラデーションを適用
    final bool isPerfect=rate>=1.0;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        //100%の時はグラデーション、それ以外は単色
        gradient: isPerfect ? _glowingGoldGradient:null,
        color: isPerfect ? null : color,
        borderRadius: BorderRadius.circular(8),
        border: isToday
          ? Border.all(color: scheme.primary,width: 3)
          : null,
      ),
      child: Center(
        child: Text(
          "$day",
          style: TextStyle(
            color: rate > 0.0 ? Colors.black : scheme.onSurface,
            fontWeight:  isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  //今日かどうかを判定するbool文
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  //今日の達成率表示を構築
  Widget _buildTodayCompletionRate() {
    //今日の達成率を表示するやつ(デバッグ用)
    final rate=_getTodayCompletionRate();
    final percentage=(rate*100).toInt();

    final bool isPerfect= rate >= 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: isPerfect ? _glowingGoldGradient:null,
        color: isPerfect ? null : _getHeatColor(rate),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Text(
        "今日: $percentage%",
        style: TextStyle(
          color: rate > 0.0
            ? Colors.black
            :Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //凡例の各項目を構築
  Widget _buildLegendItem(String label, Color? color,{Gradient? gradient, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration:BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            //色サンプル
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient==null ? color : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          //ラベル
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          //アイコン
          if(icon != null)
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }
}