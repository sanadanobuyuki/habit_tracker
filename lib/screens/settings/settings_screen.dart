import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'theme_selector_screen.dart';

/// SettingsScreen
///
/// 役割:
/// - 設定画面を表示
/// - テーマ選択への導線
/// - 今後の機能拡張に対応
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
}
