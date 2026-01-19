import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../l10n/app_localizations.dart';

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

  //達成率データをキャッシュ
  Map<String, double> _completionRateCache = {};
  //キャッシュの原理
  //非同期処理を事前に完了させ、画像描画時は同期的にメモリから取得

  //ローディング状態
  bool _isLoading = false;

  //最長連続達成日数
  int _maxStreak = 0;

  //今月の達成日数
  int _thisMonthCompletedDays = 0;

  //金色のグラデーション定義
  final LinearGradient _glowingGoldGradient = const LinearGradient(
    //begin グラデーションを始める位置
    begin: Alignment.topLeft,
    //end グラデーションを終える位置
    end: Alignment.bottomRight,
    //stops グラデーションの各色が始まる位置を0.0から1.0の範囲で指定
    stops: [0.0, 0.45, 0.7, 1.0],
    colors: [
      Color(0xFFFFF8E1), // 強いハイライト(光)
      Color(0xFFFFE082), // 明るい金
      Color(0xFFD4AF37), // ベース金
      Color(0xFFB8962E), // 影
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadMonthRecord();
  }

  //====================================データ読み込みたち=================================

  //月の記録を読み込む機能

  //表示中の月の全日付をループ
  //各日付の達成率を計算(データベース側で実行)
  //先に全データを取得してメモリに保存
  Future<void> _loadMonthRecord() async {
    //ロード中なら何もしない
    if (_isLoading) return;

    setState(() => _isLoading = true);

    //月の最初の日
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);

    //月の最初の日
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    //新しいキャッシュを作成
    final newCache = <String, double>{};

    //今月の達成日数をカウント
    int completedDaysCount = 0;

    //各日付の達成率を取得
    //その月のすべての日付の達成率を一度に取得
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dateString = _formatDate(date);

      //達成率を取得してキャッシュに保存
      final rate = await _db.getCompletionRateForDate(dateString);

      //メモリに保存
      newCache[dateString] = rate;

      //達成した日をカウント
      if (rate > 0.0) {
        completedDaysCount++;
      }
    }

    //最長連続達成日数を計算
    final maxStreak = await _calculateMaxStreak(firstDay, lastDay);

    if (mounted) {
      setState(() {
        //一度に反映するからちらつかない
        _completionRateCache = newCache;

        //今月の達成日数
        _thisMonthCompletedDays = completedDaysCount;

        //最長連続達成日数
        _maxStreak = maxStreak;

        _isLoading = false;
      });
    }
  }

  //最長連続達成日数を計算
  Future<int> _calculateMaxStreak(DateTime firstDay, DateTime lastDay) async {
    int maxStreak = 0;
    int currentStreak = 0;

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dateString = _formatDate(date);

      final rate = await _db.getCompletionRateForDate(dateString);

      if (rate > 0.0) {
        //達成で連続カウント増加
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        //未達成で連続リセット
        currentStreak = 0;
      }
    }

    return maxStreak;
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
    if (rate <= 0.8) return Colors.lightGreen.shade500;
    if (rate < 1.0) return Colors.green.shade500;
    return const Color(0xFFD4AF37); // 100%
  }

  //指定日の達成率を取得
  double? _getCompletionRate(DateTime date) {
    final dateString = _formatDate(date);

    //データベースから直接達成率を取得
    return _completionRateCache[dateString];
  }

  //今日の達成率を取得(デバッグ用)
  // double _getTodayCompletionRate(){
  //   return _getCompletionRate(DateTime.now()) ?? 0.0;
  // }

  //日付をYYYY-MM-DD形式に変換
  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _showLegendDialog() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        //ダイアログ全体を角丸にする
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //ヘッダー部分
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    //アプリの主要な色 primary
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      //上部の角だけ丸くする
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 28,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.completionRateLegend,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
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
                      //デバッグ用
                      // _buildTodayCompletionRate(),
                      // const SizedBox(height: 20),

                      //凡例リスト
                      _buildLegendItem(l10n.unrecorded, Colors.grey.shade200),
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
                      _buildLegendItem(
                        "100%",
                        null,
                        gradient: _glowingGoldGradient,
                      ),

                      const SizedBox(height: 20),

                      //閉じるボタン
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: Text(l10n.close),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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
        if (info.visibleFraction > 0.5 && mounted) {
          //print("カレンダーが表示されました-データ再読み込み");
          _loadMonthRecord();
        }
      },
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }

  //AppBarを構築
  AppBar _buildAppBar() {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Text(l10n.calendar),
      actions: [
        //凡例表示
        IconButton(
          onPressed: _showLegendDialog,
          icon: const Icon(Icons.help_outline),
          tooltip: l10n.showLegend,
        ),

        //今月に戻るボタン
        IconButton(
          onPressed: _goToToday,
          icon: const Icon(Icons.today),
          tooltip: l10n.backToThisMonth,
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

          //統計情報
          _buildStatsCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  //年月ヘッダー
  Widget _buildMonthHeader() {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //前月ボタン
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.previousMonth,
        ),

        //年月表示
        Text(
          _formatYearMonth(_currentMonth),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        //次月ボタン
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.nextMonth,
        ),
      ],
    );
  }

  //年月を言語に応じてフォーマット
  String _formatYearMonth(DateTime date) {
    final l10n = AppLocalizations.of(context);
    if (l10n.locale.languageCode == 'ja') {
      return '${date.year}年${date.month}月';
    } else {
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${monthNames[date.month - 1]} ${date.year}';
    }
  }

  //曜日ヘッダー
  Widget _buildWeekdayHeader() {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(l10n.monday, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(l10n.tuesday, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          l10n.wednesday,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          l10n.thursday,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(l10n.friday, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          l10n.saturday,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          l10n.sunday,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
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
    final scheme = Theme.of(context).colorScheme;

    //達成率がまだロードされていない場合
    if (rate == null) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: scheme.primary, width: 3) : null,
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
    final color = _getHeatColor(rate);

    //100%達成の場合はグラデーションを適用
    final bool isPerfect = rate >= 1.0;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        //100%の時はグラデーション、それ以外は単色
        gradient: isPerfect ? _glowingGoldGradient : null,
        color: isPerfect ? null : color,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: scheme.primary, width: 3) : null,
      ),
      child: Center(
        child: Text(
          "$day",
          style: TextStyle(
            color: rate > 0.0 ? Colors.black : scheme.onSurface,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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

  //統計情報カードを構築
  Widget _buildStatsCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                _formatMonthStatTitle(_currentMonth),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          //統計データを横並びで表示
          Row(
            children: [
              //最長連続達成日数
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: _formatStreakLabel(),
                  value: _formatDaysValue(_maxStreak),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),

              //今月の達成日数
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: _formatMonthCompletedLabel(_currentMonth.month),
                  value: _formatDaysValue(_thisMonthCompletedDays),
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //統計タイトルをフォーマット
  String _formatMonthStatTitle(DateTime date) {
    final l10n = AppLocalizations.of(context);
    if (l10n.locale.languageCode == 'ja') {
      return '${date.year}年${date.month}月の統計';
    } else {
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${monthNames[date.month - 1]} ${date.year} Statistics';
    }
  }

  //連続達成ラベルをフォーマット
  String _formatStreakLabel() {
    final l10n = AppLocalizations.of(context);
    if (l10n.locale.languageCode == 'ja') {
      return '最長連続達成';
    } else {
      return 'Longest Streak';
    }
  }

  //月の達成日数ラベルをフォーマット
  String _formatMonthCompletedLabel(int month) {
    final l10n = AppLocalizations.of(context);
    if (l10n.locale.languageCode == 'ja') {
      return '$month月の達成日数';
    } else {
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${monthNames[month - 1]} Completed';
    }
  }

  //日数の値をフォーマット
  String _formatDaysValue(int days) {
    final l10n = AppLocalizations.of(context);
    if (l10n.locale.languageCode == 'ja') {
      return '$days日';
    } else {
      return days == 1 ? '$days day' : '$days days';
    }
  }

  //統計の各項目を構築
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  //凡例の各項目を構築
  Widget _buildLegendItem(
    String label,
    Color? color, {
    Gradient? gradient,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
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
              color: gradient == null ? color : null,
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
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:colorScheme.onSurface,
              ),
            ),
          ),

          //アイコン
          if (icon != null)
            Icon(
              icon,
              size: 24,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }
}
