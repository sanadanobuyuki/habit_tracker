import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/achievement.dart';
import '../../models/user_achievement.dart';

//役割
/// - 実績画面を表示
/// - すべての実績を一覧表示
/// - ユーザーが解除した実績を表示
///   進捗状況の確認

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchivementsScreenState();
}

class _AchivementsScreenState extends State<AchievementsScreen> {
  //すべての実績
  List<Achievement> _achievements = [];

  //ユーザーが解除した実績
  List<UserAchievement> _userAchievements = [];

  //ロード中かどうか
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  //実績データを読み込む
  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    final db = DatabaseService();

    //すべての実績を取得
    final achievementsData = await db.getAllAchievements();
    final achievements = achievementsData
        .map((data) => Achievement.fromMap(data))
        .toList();

    //ユーザーが解除した実績を取得
    final userAchievemetsSata = await db.getUserAchievements();
    final userAchievements = userAchievemetsSata
        .map((data) => UserAchievement.fromMap(data))
        .toList();

    setState(() {
      _achievements = achievements;
      _userAchievements = userAchievements;
      _isLoading = false;
    });
  }

  //特定の実績が解除済みかどうかをチェック
  //引数
  // achivemetnId: 実績ID
  //戻り値
  // 解除済みならtrue、未解除ならfalse

  bool _isUnlocked(String achievementId) {
    //anyについて
    //リストの中に条件に一致する要素が一つでもあればtrueなければfakse
    return _userAchievements.any(
      (userAch) => userAch.achievementId == achievementId,
    );
  }

  //特定の実績のユーザー記録を取得
  //引数
  // achievementId: 実績ID
  //戻り値
  //- UserAchievement: 解除記録
  // null 未解除
  UserAchievement? _getUserAchievement(String achievementId) {
    //try-catchについて
    // 条件に一致する要素が見つからない場合に例外が発生する可能性があるため
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
      body: const Center(child: Text('実績画面')),
    );
  }
}
