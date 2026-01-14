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
        'first': '初期',
        'dark': '黒',
        'blue': '青',
        'green': '緑',
        'pink': 'ピンク',
        'red': '赤',
        'checkered_blue': '青チェック',
        'dotted_pink': 'ピンクドット',
        'striped_green': 'グリーンストライプ',
        'gradient_sunset': 'サンセット',
        'dark_checkered': '黒チェック',
      },
      'en': {
        'first': 'First',
        'dark': 'Dark',
        'blue': 'Blue',
        'green': 'Green',
        'pink': 'Pink',
        'red': 'Red',
        'checkered_blue': 'Blue Checkered',
        'dotted_pink': 'Pink Dotted',
        'striped_green': 'Green Striped',
        'gradient_sunset': 'Sunset',
        'dark_checkered': 'Dark Checkered',
      },
    };

    return names[locale.languageCode]?[themeId] ?? themeId;
  }

  // ========== テーマ説明の翻訳 ==========
  String themeDescription(String themeId) {
    final descriptions = {
      'ja': {
        'first': '初期のテーマ設定',
        'dark': '暗いテーマ',
        'blue': '青基調のテーマ',
        'green': '緑基調のテーマ',
        'pink': 'ピンク基調のテーマ',
        'red': '赤基調のテーマ',
        'checkered_blue': '青いチェック柄',
        'dotted_pink': 'かわいいドット柄',
        'striped_green': '緑のストライプ柄',
        'gradient_sunset': '夕焼けグラデーション',
        'dark_checkered': '暗いチェック柄',
      },
      'en': {
        'first': 'First theme',
        'dark': 'Dark theme',
        'blue': 'Blue-based theme',
        'green': 'Green-based theme',
        'pink': 'Pink-based theme',
        'red': 'Red-based theme',
        'checkered_blue': 'Blue checkered pattern',
        'dotted_pink': 'Cute dotted pattern',
        'striped_green': 'Green striped pattern',
        'gradient_sunset': 'Sunset gradient',
        'dark_checkered': 'Dark checkered pattern',
      },
    };

    return descriptions[locale.languageCode]?[themeId] ?? '';
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

  // 習慣追加・編集画面
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
  String get targetFrequency => locale.languageCode == 'ja'
      ? '目標頻度(週あたり)'
      : 'Target Frequency (per week)';
  String get timesPerWeek => locale.languageCode == 'ja' ? '回' : 'times';

  // ========== カレンダー用の曜日名（省略形） ==========
  String get sun => locale.languageCode == 'ja' ? '日' : 'Sun';
  String get mon => locale.languageCode == 'ja' ? '月' : 'Mon';
  String get tue => locale.languageCode == 'ja' ? '火' : 'Tue';
  String get wed => locale.languageCode == 'ja' ? '水' : 'Wed';
  String get thu => locale.languageCode == 'ja' ? '木' : 'Thu';
  String get fri => locale.languageCode == 'ja' ? '金' : 'Fri';
  String get sat => locale.languageCode == 'ja' ? '土' : 'Sat';

  // 曜日名（フルネーム - 既存のもの）
  String get monday => locale.languageCode == 'ja' ? '月' : 'Mon';
  String get tuesday => locale.languageCode == 'ja' ? '火' : 'Tue';
  String get wednesday => locale.languageCode == 'ja' ? '水' : 'Wed';
  String get thursday => locale.languageCode == 'ja' ? '木' : 'Thu';
  String get friday => locale.languageCode == 'ja' ? '金' : 'Fri';
  String get saturday => locale.languageCode == 'ja' ? '土' : 'Sat';
  String get sunday => locale.languageCode == 'ja' ? '日' : 'Sun';

  // ========== 月名 ==========
  String get january => locale.languageCode == 'ja' ? '1月' : 'January';
  String get february => locale.languageCode == 'ja' ? '2月' : 'February';
  String get march => locale.languageCode == 'ja' ? '3月' : 'March';
  String get april => locale.languageCode == 'ja' ? '4月' : 'April';
  String get may => locale.languageCode == 'ja' ? '5月' : 'May';
  String get june => locale.languageCode == 'ja' ? '6月' : 'June';
  String get july => locale.languageCode == 'ja' ? '7月' : 'July';
  String get august => locale.languageCode == 'ja' ? '8月' : 'August';
  String get september => locale.languageCode == 'ja' ? '9月' : 'September';
  String get october => locale.languageCode == 'ja' ? '10月' : 'October';
  String get november => locale.languageCode == 'ja' ? '11月' : 'November';
  String get december => locale.languageCode == 'ja' ? '12月' : 'December';

  // ========== カレンダー画面用のテキスト ==========
  String get today => locale.languageCode == 'ja' ? '今日' : 'Today';
  String get selectPeriodDays =>
      locale.languageCode == 'ja' ? '生理日を選択' : 'Select your period days';
  String get tapDatesToMark => locale.languageCode == 'ja'
      ? '日付をタップして生理日をマーク'
      : 'Tap dates to mark your period';
  String daysSelected(int count) =>
      locale.languageCode == 'ja' ? '$count日選択済み' : '$count days selected';
  // String daySelected =>
  //     locale.languageCode == 'ja' ? '1日選択済み' : '1 day selected';

  // バリデーションメッセージ
  String get pleaseEnterHabitName => locale.languageCode == 'ja'
      ? '習慣名を入力してください'
      : 'Please enter a habit name';
  String get pleaseSelectEmoji =>
      locale.languageCode == 'ja' ? '絵文字を選択してください' : 'Please select an emoji';
  String get pleaseSelectDays =>
      locale.languageCode == 'ja' ? '曜日を選択してください' : 'Please select days';
  String get habitNameTooLong => locale.languageCode == 'ja'
      ? '習慣名は30文字以内で入力してください'
      : 'Habit name must be 30 characters or less';

  // 成功メッセージ
  String get habitSaved =>
      locale.languageCode == 'ja' ? '習慣を保存しました' : 'Habit saved';
  String get habitUpdated =>
      locale.languageCode == 'ja' ? '習慣を更新しました' : 'Habit updated';
  String habitDeleted(String name) =>
      locale.languageCode == 'ja' ? '「$name」を削除しました' : 'Deleted "$name"';
  String habitCompleted(String emoji, String name) =>
      locale.languageCode == 'ja'
      ? '$emoji $name を達成しました!'
      : '$emoji $name completed!';
  String habitUncompleted(String name) =>
      locale.languageCode == 'ja' ? '$name の達成を取り消しました' : 'Uncompleted $name';

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
  String get notTargetTodayDescription =>
      locale.languageCode == 'ja' ? '今日は対象外' : 'Not scheduled for today';
  String get goal => locale.languageCode == 'ja' ? '未達成' : 'Not achieved';
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
  String get showLegend =>
      locale.languageCode == 'ja' ? '凡例を表示' : 'Show Legend';
  String get backToThisMonth =>
      locale.languageCode == 'ja' ? '今月に戻る' : 'Back to This Month';
  String get previousMonth =>
      locale.languageCode == 'ja' ? '前月' : 'Previous Month';
  String get nextMonth => locale.languageCode == 'ja' ? '次月' : 'Next Month';
  String get unrecorded => locale.languageCode == 'ja' ? '未記録' : 'Unrecorded';
  String get availableThemes =>
      locale.languageCode == 'ja' ? '利用可能なテーマ' : 'Available Themes';
  String get lockedThemes =>
      locale.languageCode == 'ja' ? 'ロック中のテーマ' : 'Locked Themes';
  String get unlockByAchievement => locale.languageCode == 'ja'
      ? '実績を解除すると使えるようになります'
      : 'Unlock by completing achievements';

  // 実績画面
  String get yourAchievements =>
      locale.languageCode == 'ja' ? 'あなたの実績' : 'Your Achievements';
  String get unlocked => locale.languageCode == 'ja' ? '解除済み' : 'Unlocked';
  String get noAchievements =>
      locale.languageCode == 'ja' ? '実績データがありません' : 'No achievements data';
  String unlockCondition(int value, String unit) => locale.languageCode == 'ja'
      ? '$value$unit達成で解除'
      : 'Unlock at $value$unit';
  String get reward => locale.languageCode == 'ja' ? '報酬' : 'Reward';
  String rewardTheme(String themeName) => locale.languageCode == 'ja'
      ? '報酬: テーマ「$themeName」'
      : 'Reward: Theme "$themeName"';
  String get receiveReward =>
      locale.languageCode == 'ja' ? '報酬を受け取る' : 'Receive Reward';
  String get alreadyReceived =>
      locale.languageCode == 'ja' ? '受け取り済み' : 'Already Received';
  String get received =>
      locale.languageCode == 'ja' ? '受け取り済み' : 'Already Received';
  String get themeReceived =>
      locale.languageCode == 'ja' ? 'テーマを受け取りました!' : 'Theme Received!';
  String themeUnlocked(String themeName) => locale.languageCode == 'ja'
      ? 'テーマ「$themeName」が使えるようになりました。\n設定画面から選択できます。'
      : 'Theme "$themeName" is now available.\nYou can select it in Settings.';
  String themeReward(String themeName) => locale.languageCode == 'ja'
      ? '報酬: テーマ「$themeName」'
      : 'Reward: Theme "$themeName"';
  String get noReward => locale.languageCode == 'ja'
      ? 'この実績には報酬がありません'
      : 'No reward for this achievement';
  String get rewardAlreadyReceived => locale.languageCode == 'ja'
      ? 'この報酬はすでに受け取り済みです'
      : 'This reward has already been received';
  String achievementUnlocked(String name) => locale.languageCode == 'ja'
      ? '🎉実績解除!「$name」'
      : '🎉Achievement Unlocked! "$name"';
  String achievementCondition(dynamic achievement) =>
      locale.languageCode == 'ja'
      ? '${achievement.conditionValue}${achievement.unit}達成で解除'
      : 'Unlock at ${achievement.conditionValue}${achievement.unit}';
  String achievementUnit(String conditionType) {
    if (locale.languageCode == 'ja') {
      // 日本語の単位
      switch (conditionType) {
        case 'habit_count':
          return '個';
        case 'total_days':
          return '日';
        case 'streak':
          return '日連続';
        default:
          return '';
      }
    } else {
      // 英語の単位（前にスペースを含める）
      switch (conditionType) {
        case 'habit_count':
          return ' habits';
        case 'total_days':
          return ' days';
        case 'streak':
          return ' day streak';
        default:
          return '';
      }
    }
  }

  String formatDate(DateTime dateTime) {
    if (locale.languageCode == 'ja') {
      // 日本語: YYYY年MM月DD日
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    } else {
      // 英語: Month DD, YYYY
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
      final monthName = monthNames[dateTime.month - 1];
      return '$monthName ${dateTime.day}, ${dateTime.year}';
    }
  }

  String get availableByAchievement =>
      locale.languageCode == 'ja' ? '実績解除で利用可能' : 'Available by achievement';
  String get locked => locale.languageCode == 'ja' ? 'ロック中' : 'Locked';

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
  String get developerOptions =>
      locale.languageCode == 'ja' ? '開発者向け' : 'Developer Options';
  String get resetDatabase =>
      locale.languageCode == 'ja' ? 'データベースをリセット' : 'Reset Database';
  String get allDataWillBeDeleted => locale.languageCode == 'ja'
      ? '⚠️ すべてのデータが削除されます'
      : '⚠️ All data will be deleted';
  String get databaseReset =>
      locale.languageCode == 'ja' ? 'データベースリセット' : 'Database Reset';
  String get resetWarning => locale.languageCode == 'ja'
      ? '以下のデータがすべて削除されます:'
      : 'The following data will be deleted:';
  String get allHabits => locale.languageCode == 'ja' ? 'すべての習慣' : 'All habits';
  String get allRecords =>
      locale.languageCode == 'ja' ? 'すべての記録' : 'All records';
  String get unlockedAchievements =>
      locale.languageCode == 'ja' ? '解除した実績' : 'Unlocked achievements';
  String get themeSettings =>
      locale.languageCode == 'ja' ? 'テーマ設定' : 'Theme settings';
  String get cannotUndo => locale.languageCode == 'ja'
      ? '⚠️ この操作は取り消せません'
      : '⚠️ This action cannot be undone';
  String get reset => locale.languageCode == 'ja' ? 'リセット' : 'Reset';
  String get resetting =>
      locale.languageCode == 'ja' ? 'データベースをリセット中...' : 'Resetting database...';
  String get resetComplete =>
      locale.languageCode == 'ja' ? 'リセット完了' : 'Reset Complete';
  String get resetCompleteMessage => locale.languageCode == 'ja'
      ? 'データベースをリセットしました。\nアプリを再起動してください。'
      : 'Database has been reset.\nPlease restart the app.';
  String get error => locale.languageCode == 'ja' ? 'エラー' : 'Error';
  String resetFailed(String error) => locale.languageCode == 'ja'
      ? 'データベースのリセットに失敗しました。\n\n$error'
      : 'Failed to reset database.\n\n$error';

  // 編集画面
  String get daysCannotBeChanged =>
      locale.languageCode == 'ja' ? '曜日は変更できません' : 'Days cannot be changed';
  String get updating => locale.languageCode == 'ja' ? '更新中...' : 'Updating...';

  // 削除確認
  String deleteConfirmation(String name) =>
      locale.languageCode == 'ja' ? '「$name」を削除しますか?' : 'Delete "$name"?';

  // テーマ関連
  String get themeLocked =>
      locale.languageCode == 'ja' ? 'テーマがロックされています' : 'Theme is locked';
  String themeLockedMessage(String themeName) => locale.languageCode == 'ja'
      ? 'テーマ「$themeName」を使用するには、特定の実績を解除する必要があります。'
      : 'To use theme "$themeName", you need to unlock a specific achievement.';

  String get rewardReceived =>
      locale.languageCode == 'ja' ? '報酬を受け取りました' : 'Reward Received';
  // エラーメッセージ
  String errorOccurred(String error) => locale.languageCode == 'ja'
      ? 'エラーが発生しました: $error'
      : 'An error occurred: $error';
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
