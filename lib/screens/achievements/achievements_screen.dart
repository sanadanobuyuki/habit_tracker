import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/achievement.dart';
import '../../models/user_achievement.dart';

/// AchievementsScreen
///
/// 役割:
/// - 実績一覧を表示
/// - 解除済み / 未解除を区別して表示
/// - 進捗状況を表示
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // すべての実績（定義）
  List<Achievement> _achievements = [];

  // ユーザーが解除した実績
  List<UserAchievement> _userAchievements = [];

  // ローディング中かどうか
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  /// 実績データを読み込む
  ///
  /// 処理の流れ:
  /// 1. すべての実績定義を取得
  /// 2. ユーザーが解除した実績を取得
  /// 3. 画面を更新
  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    final db = DatabaseService();

    // すべての実績定義を取得
    final achievementsData = await db.getAllAchievements();
    final achievements = achievementsData
        .map((data) => Achievement.fromMap(data))
        .toList();

    // ユーザーが解除した実績を取得
    final userAchievementsData = await db.getUserAchievements();
    final userAchievements = userAchievementsData
        .map((data) => UserAchievement.fromMap(data))
        .toList();

    setState(() {
      _achievements = achievements;
      _userAchievements = userAchievements;
      _isLoading = false;
    });
  }

  /// 特定の実績が解除済みかチェック
  ///
  /// 引数:
  /// - achievementId: 実績のID
  ///
  /// 戻り値:
  /// - true: 解除済み
  /// - false: 未解除
  bool _isUnlocked(String achievementId) {
    // any() について:
    // - リストの中に条件に一致する要素が1つでもあれば true
    // - 一致する要素がなければ false
    return _userAchievements.any(
      (userAch) => userAch.achievementId == achievementId,
    );
  }

  /// 特定の実績のユーザー記録を取得
  ///
  /// 引数:
  /// - achievementId: 実績のID
  ///
  /// 戻り値:
  /// - UserAchievement: 解除記録
  /// - null: 未解除
  UserAchievement? _getUserAchievement(String achievementId) {
    // try-catch について:
    // firstWhere で見つからない場合は例外が発生するため
    try {
      return _userAchievements.firstWhere(
        (userAch) => userAch.achievementId == achievementId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('実績')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // RefreshIndicator について:
              // - 下に引っ張って更新（Pull to Refresh）
              // - iOS/Android でよくある UI
              onRefresh: _loadAchievements,
              child: _buildContent(),
            ),
    );
  }

  /// メインコンテンツを作成
  Widget _buildContent() {
    if (_achievements.isEmpty) {
      // 実績データがない場合
      return const Center(child: Text('実績データがありません'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 進捗サマリー
        _buildProgressSummary(),

        const SizedBox(height: 24),

        // 実績リスト
        ..._buildAchievementsList(),
      ],
    );
  }

  /// 進捗サマリーを作成
  ///
  /// 解除数 / 総数を表示
  /// プログレスバーで視覚化
  Widget _buildProgressSummary() {
    final totalCount = _achievements.length;
    final unlockedCount = _userAchievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'あなたの実績',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 解除数
            Text(
              '解除済み: $unlockedCount / $totalCount',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            // プログレスバー
            // LinearProgressIndicator について:
            // - 横長のプログレスバー
            // - value: 0.0〜1.0 の進捗率
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 8),

            // パーセンテージ
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// 実績リストを作成
  ///
  /// すべての実績をカードで表示
  /// 解除済み / 未解除で見た目を変える
  List<Widget> _buildAchievementsList() {
    // map() について:
    // - リストの各要素に対して処理を実行
    // - 新しいリストを作成
    //
    // toList() について:
    // - Iterable を List に変換
    return _achievements.map((achievement) {
      final isUnlocked = _isUnlocked(achievement.id);
      final userAchievement = _getUserAchievement(achievement.id);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildAchievementCard(achievement, isUnlocked, userAchievement),
      );
    }).toList();
  }

  /// 実績カードを作成
  ///
  /// 引数:
  /// - achievement: 実績の定義
  /// - isUnlocked: 解除済みかどうか
  /// - userAchievement: ユーザーの解除記録（未解除なら null）
  Widget _buildAchievementCard(
    Achievement achievement,
    bool isUnlocked,
    UserAchievement? userAchievement,
  ) {
    return Card(
      // elevation について:
      // - カードの影の深さ
      // - 解除済みは影を濃くして目立たせる
      elevation: isUnlocked ? 3 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 左側: 絵文字 or ？マーク
            _buildIcon(achievement, isUnlocked),

            const SizedBox(width: 16),

            // 右側: 実績情報
            Expanded(
              child: _buildInfo(achievement, isUnlocked, userAchievement),
            ),
          ],
        ),
      ),
    );
  }

  /// アイコン部分を作成
  ///
  /// 解除済み: 絵文字を表示
  /// 未解除: ？マークを表示
  Widget _buildIcon(Achievement achievement, bool isUnlocked) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        // 解除済みなら色付き、未解除ならグレー
        color: isUnlocked
            ? Colors.orange.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          // 解除済みなら絵文字、未解除なら？
          isUnlocked ? achievement.emoji : '？',
          style: TextStyle(
            fontSize: 32,
            // 未解除ならグレーアウト
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// 実績情報部分を作成
  ///
  /// 解除済み: 名前、説明、解除日時を表示
  /// 未解除: ？？？を表示
  Widget _buildInfo(
    Achievement achievement,
    bool isUnlocked,
    UserAchievement? userAchievement,
  ) {
    if (isUnlocked && userAchievement != null) {
      // 解除済みの場合
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 実績名
          Text(
            achievement.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          // 説明
          Text(
            achievement.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          const SizedBox(height: 8),

          // 解除日時
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                userAchievement.formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      );
    } else {
      // 未解除の場合
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ？？？
          Text(
            '？？？',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          // ヒント
          Text(
            '${achievement.conditionValue}${achievement.unit}達成で解除',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      );
    }
  }
}
