// lib/providers/language_provider.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';

// 言語設定を管理するProvider
//
// 役割:
// - 現在の言語コード ('ja' or 'en') を管理
// - 言語の切り替え
// - データベースへの保存・読み込み
//
// ThemeProvider と同じ仕組みで動作
class LanguageProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // 現在の言語コード ('ja' = 日本語, 'en' = 英語)
  String _languageCode = 'ja';

  /// 現在の言語コードを取得
  String get languageCode => _languageCode;

  /// Locale オブジェクトを取得
  /// MaterialApp で使用
  Locale get locale => Locale(_languageCode);

  // 言語を変更する
  //
  // 引数:
  // - languageCode: 'ja' または 'en'
  //
  // 処理の流れ:
  // 1. 言語コードを更新
  // 2. データベースに保存
  // 3. notifyListeners() で画面を更新
  Future<void> setLanguage(String languageCode) async {
    // 同じ言語なら何もしない
    if (_languageCode == languageCode) return;

    // 言語コードを更新
    _languageCode = languageCode;

    // データベースに保存
    try {
      await _db.saveSetting('language_code', languageCode);
      // ignore: avoid_print
      print('言語を $languageCode に変更しました');
    } catch (e) {
      // ignore: avoid_print
      print('言語設定保存エラー: $e');
    }

    // 画面を更新
    // これを呼ぶことで、全ての画面が再描画される
    notifyListeners();
  }

  /// データベースから言語設定を読み込む
  ///
  /// アプリ起動時に呼び出す
  /// main.dart の MyApp で実行
  Future<void> loadLanguage() async {
    try {
      final savedLanguage = await _db.getSetting('language_code');
      if (savedLanguage != null) {
        _languageCode = savedLanguage;
        // ignore: avoid_print
        print('保存された言語を読み込み: $_languageCode');
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print('言語設定読み込みエラー: $e');
    }
  }
}
