import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'theme_selector_screen.dart';
//データベース削除用
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../services/database_service.dart';
import '../../../data/achievement_data.dart';

/// SettingsScreen
///
/// 役割:
/// - 設定画面を表示
/// - テーマ選択への導線
/// - 今後の機能拡張に対応
/// データベースリセット機能
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          // テーマ設定セクション
          _buildSectionHeader('表示設定'),
          _buildThemeListTile(context),

          const SizedBox(height: 24),

          // 今後の拡張用セクション
          _buildSectionHeader('アプリ情報'),
          _buildInfoListTile(
            context,
            icon: Icons.info_outline,
            title: 'バージョン',
            subtitle: '1.0.0',
            onTap: null, // タップ不可
          ),
          const SizedBox(height: 24),

          // 開発者向けセクション
          _buildSectionHeader('開発者向け'),
          _buildDangerButton(context),
        ],
      ),
    );
  }

  /// セクションヘッダーを作成
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// テーマ選択のリストタイルを作成
  Widget _buildThemeListTile(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('テーマ'),
          subtitle: Text(themeProvider.currentTheme.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // テーマ選択画面に遷移
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ThemeSelectorScreen(),
              ),
            );
          },
        );
      },
    );
  }

  /// 情報表示用のリストタイルを作成
  Widget _buildInfoListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  /// データベースリセットボタンを作成
  ///
  /// 開発用の危険なボタン
  /// タップすると確認ダイアログを表示
  Widget _buildDangerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        // 赤い枠線で危険性を示す
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        child: ListTile(
          // 警告アイコン
          leading: const Icon(Icons.warning, color: Colors.red),

          // タイトル
          title: const Text(
            'データベースをリセット',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),

          // 説明
          subtitle: const Text(
            '⚠️ すべてのデータが削除されます',
            style: TextStyle(fontSize: 12),
          ),

          // タップ時の処理
          onTap: () => _showResetConfirmDialog(context),
        ),
      ),
    );
  }

  /// リセット確認ダイアログを表示
  ///
  /// 処理の流れ:
  /// 1. 警告ダイアログを表示
  /// 2. ユーザーが「リセット」をタップ
  /// 3. データベースを削除
  /// 4. アプリを再起動（手動）
  Future<void> _showResetConfirmDialog(BuildContext context) async {
    // showDialog について:
    // ダイアログを表示する
    // await で結果を待つ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // タイトル（警告アイコン付き）
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('データベースをリセット'),
          ],
        ),

        // 詳細な説明
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '以下のデータがすべて削除されます:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• すべての習慣'),
            Text('• すべての記録'),
            Text('• 解除した実績'),
            Text('• テーマ設定'),
            SizedBox(height: 16),
            Text('⚠️ この操作は取り消せません', style: TextStyle(color: Colors.red)),
          ],
        ),

        // ボタン
        actions: [
          // キャンセルボタン
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),

          // リセットボタン（赤色）
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'リセット',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    // ユーザーがキャンセルした場合
    if (confirmed != true) return;

    // リセット実行
    await _resetDatabase(context);
  }

  /// データベースをリセットする
  ///
  /// 処理の流れ:
  /// 1. ローディング表示
  /// 2. データベースファイルを削除
  /// 3. データベースを再作成
  /// 4. 実績を再登録
  /// 5. 完了メッセージ
  /// 6. アプリの再起動を促す
  Future<void> _resetDatabase(BuildContext context) async {
    // ローディングダイアログを表示
    showDialog(
      context: context,
      // barrierDismissible: false について:
      // ダイアログの外をタップしても閉じないようにする
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('データベースをリセット中...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 1. データベースパスを取得
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'habit_flow.db');

      // 2. データベースを削除
      await deleteDatabase(path);

      // 少し待つ（UIの反映のため）
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. データベースを再作成
      final db = DatabaseService();
      await db.database;

      // 4. 実績を再登録
      await insertInitialAchievements(db);

      // ローディングダイアログを閉じる
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 5. 完了メッセージを表示
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('リセット完了'),
              ],
            ),
            content: const Text(
              'データベースをリセットしました。\n'
              'アプリを再起動してください。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // エラーが発生した場合

      // ローディングダイアログを閉じる
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // エラーメッセージを表示
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('エラー'),
              ],
            ),
            content: Text('データベースのリセットに失敗しました。\n\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
