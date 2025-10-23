import 'package:ad_blocker_yeni/models/blocked_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _adBlockerEnabledKey = 'adBlockerEnabled';
  static const String _statsKey = 'blockedStats';
  static const String _customRulesKey = 'customRules';
  static const String _whitelistKey = 'whitelist';
  static const String _selectedBrowserKey = 'selectedBrowser'; // ✅ yeni eklendi

  // 🔹 Seçilen tarayıcıyı kaydet
  Future<void> saveSelectedBrowser(String browser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedBrowserKey, browser);
  }

  // 🔹 Seçilen tarayıcıyı oku
  Future<String?> getSelectedBrowser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedBrowserKey);
  }

  // Ad Blocker durumunu kaydet/oku
  Future<void> setAdBlockerEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adBlockerEnabledKey, enabled);
  }

  Future<bool> getAdBlockerEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adBlockerEnabledKey) ?? true;
  }

  // İstatistikleri kaydet/oku
  Future<void> saveStats(BlockedStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<BlockedStats> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    if (statsJson == null) {
      return BlockedStats();
    }
    return BlockedStats.fromJson(json.decode(statsJson));
  }

  // Custom rules
  Future<void> saveCustomRules(List<String> rules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customRulesKey, rules);
  }

  Future<List<String>> getCustomRules() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_customRulesKey) ?? [];
  }

  // Whitelist
  Future<void> saveWhitelist(List<String> domains) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_whitelistKey, domains);
  }

  Future<List<String>> getWhitelist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_whitelistKey) ?? [];
  }

  // Tüm verileri temizle
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
