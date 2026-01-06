// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

/// 多言語対応クラス
///
/// 役割:
/// - 日本語と英語の翻訳を管理
/// - 現在の言語に応じた文字列を返す
///
/// 使い方:
/// final l10n = AppLocalizations.of(context);
/// Text(l10n.home)  // 日本語: "ホーム" / 英語: "Home"
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// context から AppLocalizations を取得
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Flutter に登録するための delegate
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // ========== 実績名の翻訳 ==========
  String achievementName(String achievementId) {
    final names = {
      'ja': {
        'ach_first_habit': '初めての一歩',
        'ach_habit_5': '習慣コレクター',
        'ach_habit_10': '習慣マスター',
        'ach_first_day': '初日達成',
        'ach_total_7': '1週間の成果',
        'ach_total_30': '1ヶ月の積み重ね',
        'ach_total_100': '百日修行',
        'ach_streak_3': '三日坊主克服',
        'ach_streak_7': '継続の達人',
        'ach_streak_30': '習慣の鬼',
      },
      'en': {
        'ach_first_habit': 'First Step',
        'ach_habit_5': 'Habit Collector',
        'ach_habit_10': 'Habit Master',
        'ach_first_day': 'First Day Complete',
        'ach_total_7': 'One Week Achievement',
        'ach_total_30': 'One Month Dedication',
        'ach_total_100': '100 Days Training',
        'ach_streak_3': '3-Day Streak',
        'ach_streak_7': 'Consistency Expert',
        'ach_streak_30': 'Habit Champion',
      },
    };

    return names[locale.languageCode]?[achievementId] ?? achievementId;
  }

  // ========== 実績説明の翻訳 ==========
  String achievementDescription(String achievementId) {
    final descriptions = {
      'ja': {
        'ach_first_habit': '初めて習慣を作成した',
        'ach_habit_5': '5個の習慣を作成した',
        'ach_habit_10': '10個の習慣を作成した',
        'ach_first_day': '初めてすべての習慣を達成した',
        'ach_total_7': '累計7日すべての習慣を達成した',
        'ach_total_30': '累計30日すべての習慣を達成した',
        'ach_total_100': '累計100日すべての習慣を達成した',
        'ach_streak_3': '3日連続ですべての習慣を達成した',
        'ach_streak_7': '7日連続ですべての習慣を達成した',
        'ach_streak_30': '30日連続ですべての習慣を達成した',
      },
      'en': {
        'ach_first_habit': 'Created your first habit',
        'ach_habit_5': 'Created 5 habits',
        'ach_habit_10': 'Created 10 habits',
        'ach_first_day': 'Completed all habits for the first time',
        'ach_total_7': 'Completed all habits for 7 days total',
        'ach_total_30': 'Completed all habits for 30 days total',
        'ach_total_100': 'Completed all habits for 100 days total',
        'ach_streak_3': 'Completed all habits for 3 days in a row',
        'ach_streak_7': 'Completed all habits for 7 days in a row',
        'ach_streak_30': 'Completed all habits for 30 days in a row',
      },
    };

    return descriptions[locale.languageCode]?[achievementId] ?? '';
  }

  // ========== テーマ名の翻訳 ==========
  String themeName(String themeId) {
    final names = {
      'ja': {
        'light': 'ライト',
        'dark': 'ダーク',
        'blue': 'ブルー',
        'green': 'グリーン',
        'pink': 'ピンク',
        'checkered_blue': 'ブルーチェック',
        'dotted_pink': 'ピンクドット',
        'striped_green': 'グリーンストライプ',
        'gradient_sunset': 'サンセット',
        'dark_checkered': 'ダークチェック',
      },
      'en': {
        'light': 'Light',
        'dark': 'Dark',
        'blue': 'Blue',
        'green': 'Green',
        'pink': 'Pink',
        'checkered_blue': 'Blue Checkered',
        'dotted_pink': 'Pink Dotted',
        'striped_green': 'Green Striped',
        'gradient_sunset': 'Sunset',
        'dark_checkered': 'Dark Checkered',
      },
    };

    return names[locale.languageCode]?[themeId] ?? themeId;
  }

  // ========== 一般的なテキスト ==========
  String get appTitle => locale.languageCode == 'ja' ? 'ハビコツ' : 'HabiKotsu';
  String get home => locale.languageCode == 'ja' ? 'ホーム' : 'Home';
  String get calendar => locale.languageCode == 'ja' ? 'カレンダー' : 'Calendar';
  String get achievements =>
      locale.languageCode == 'ja' ? '実績' : 'Achievements';
  String get settings => locale.languageCode == 'ja' ? '設定' : 'Settings';
  String get addHabit => locale.languageCode == 'ja' ? '習慣を追加' : 'Add Habit';
  String get editHabit => locale.languageCode == 'ja' ? '習慣を編集' : 'Edit Habit';
  String get deleteHabit =>
      locale.languageCode == 'ja' ? '習慣を削除' : 'Delete Habit';
  String get save => locale.languageCode == 'ja' ? '保存' : 'Save';
  String get cancel => locale.languageCode == 'ja' ? 'キャンセル' : 'Cancel';
  String get delete => locale.languageCode == 'ja' ? '削除' : 'Delete';
  String get edit => locale.languageCode == 'ja' ? '編集' : 'Edit';
  String get ok => locale.languageCode == 'ja' ? 'OK' : 'OK';
  String get close => locale.languageCode == 'ja' ? '閉じる' : 'Close';

  // 習慣関連
  String get habitName => locale.languageCode == 'ja' ? '習慣名' : 'Habit Name';
  String get habitNameHint =>
      locale.languageCode == 'ja' ? '例: 朝の運動' : 'e.g., Morning Exercise';
  String get emoji => locale.languageCode == 'ja' ? '絵文字' : 'Emoji';
  String get color => locale.languageCode == 'ja' ? '色' : 'Color';
  String get daysOfWeek =>
      locale.languageCode == 'ja' ? '実施する曜日' : 'Days of Week';
  String get everyday => locale.languageCode == 'ja' ? '毎日' : 'Everyday';
  String get selectDays =>
      locale.languageCode == 'ja' ? '曜日を選択' : 'Select Days';
  String get daysOfWeekCannotBeChanged => locale.languageCode == 'ja'
      ? '曜日は編集できません'
      : 'Days of Week cannot be changed';

  // 曜日名
  String get monday => locale.languageCode == 'ja' ? '月' : 'Mon';
  String get tuesday => locale.languageCode == 'ja' ? '火' : 'Tue';
  String get wednesday => locale.languageCode == 'ja' ? '水' : 'Wed';
  String get thursday => locale.languageCode == 'ja' ? '木' : 'Thu';
  String get friday => locale.languageCode == 'ja' ? '金' : 'Fri';
  String get saturday => locale.languageCode == 'ja' ? '土' : 'Sat';
  String get sunday => locale.languageCode == 'ja' ? '日' : 'Sun';

  // バリデーション
  String get pleaseEnterHabitName => locale.languageCode == 'ja'
      ? '習慣名を入力してください'
      : 'Please enter a habit name';
  String get pleaseSelectEmoji =>
      locale.languageCode == 'ja' ? '絵文字を選択してください' : 'Please select an emoji';
  String get pleaseSelectDays =>
      locale.languageCode == 'ja' ? '曜日を選択してください' : 'Please select days';

  // 成功メッセージ
  String get habitSaved =>
      locale.languageCode == 'ja' ? '習慣を保存しました' : 'Habit saved';
  String habitCompleted(String emoji, String name) =>
      locale.languageCode == 'ja'
      ? '$emoji $name を達成しました!'
      : '$emoji $name completed!';
  String habitDeleted(String name) =>
      locale.languageCode == 'ja' ? '「$name」を削除しました' : 'Deleted "$name"';

  // ホーム画面
  String get noHabitsYet =>
      locale.languageCode == 'ja' ? '習慣がまだありません' : 'No habits yet';
  String get tapPlusToAdd => locale.languageCode == 'ja'
      ? '右下の + ボタンから追加しましょう'
      : 'Tap the + button to add one';
  String get todaysHabits =>
      locale.languageCode == 'ja' ? '今日の習慣' : "Today's Habits";
  String get completed => locale.languageCode == 'ja' ? '達成済み' : 'Completed';
  String get notTargetToday =>
      locale.languageCode == 'ja' ? '今日は対象外' : 'Not Today';
  String get goal => locale.languageCode == 'ja' ? '目標' : 'Goal';
  String daysStreak(int days) =>
      locale.languageCode == 'ja' ? '$days日連続' : '$days day streak';
  String get todaysCompletionRate =>
      locale.languageCode == 'ja' ? '今日の達成率' : "Today's Completion Rate";
  String completedCount(int completed, int total) => locale.languageCode == 'ja'
      ? '$completed/$total 完了'
      : '$completed/$total completed';

  // カレンダー画面
  String get completionRateLegend =>
      locale.languageCode == 'ja' ? '達成率の凡例' : 'Completion Rate Legend';
  String get backToThisMonth =>
      locale.languageCode == 'ja' ? '今月に戻る' : 'Back to This Month';
  String get unrecorded => locale.languageCode == 'ja' ? '未記録' : 'Unrecorded';

  // 実績画面
  String get yourAchievements =>
      locale.languageCode == 'ja' ? 'あなたの実績' : 'Your Achievements';
  String get unlocked => locale.languageCode == 'ja' ? '解除済み' : 'Unlocked';
  String get receiveReward =>
      locale.languageCode == 'ja' ? '報酬を受け取る' : 'Receive Reward';
  String get alreadyReceived =>
      locale.languageCode == 'ja' ? '受け取り済み' : 'Already Received';
  String achievementUnlocked(String name) => locale.languageCode == 'ja'
      ? '🎉実績解除！「$name」'
      : '🎉Achievement Unlocked! "$name"';

  // 設定画面
  String get displaySettings =>
      locale.languageCode == 'ja' ? '表示設定' : 'Display Settings';
  String get theme => locale.languageCode == 'ja' ? 'テーマ' : 'Theme';
  String get themeSelection =>
      locale.languageCode == 'ja' ? 'テーマ選択' : 'Theme Selection';
  String get language => locale.languageCode == 'ja' ? '言語' : 'Language';
  String get japanese => locale.languageCode == 'ja' ? '日本語' : 'Japanese';
  String get english => locale.languageCode == 'ja' ? '英語' : 'English';
  String get appInfo =>
      locale.languageCode == 'ja' ? 'アプリ情報' : 'App Information';
  String get version => locale.languageCode == 'ja' ? 'バージョン' : 'Version';

  // エラー
  String errorOccurred(String error) => locale.languageCode == 'ja'
      ? 'エラーが発生しました: $error'
      : 'An error occurred: $error';

  // 削除確認
  String deleteConfirmation(String name) =>
      locale.languageCode == 'ja' ? '「$name」を削除しますか?' : 'Delete "$name"?';
}

/// Delegate クラス
///
/// 役割:
/// - Flutter に多言語化の設定を教える
/// - どの言語をサポートするか定義
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // 'ja' (日本語) と 'en' (英語) をサポート
    return ['ja', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations を作成して返す
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
