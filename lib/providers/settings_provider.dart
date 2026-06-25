import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

/// Model đại diện cho trạng thái Cài đặt chung của ứng dụng
class AppSettings {
  final bool notifOn;
  final String unit;
  final String theme;
  final String language;

  AppSettings({
    this.notifOn = true,
    this.unit = 'km',
    this.theme = 'Theo hệ thống',
    this.language = 'Tiếng Việt',
  });

  AppSettings copyWith({
    bool? notifOn,
    String? unit,
    String? theme,
    String? language,
  }) {
    return AppSettings(
      notifOn: notifOn ?? this.notifOn,
      unit: unit ?? this.unit,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = AppSettings(
      notifOn: _prefs.getBool('setting_notif_on') ?? true,
      unit: _prefs.getString('setting_unit') ?? 'km',
      theme: _prefs.getString('setting_theme') ?? 'Theo hệ thống',
      language: _prefs.getString('setting_language') ?? 'Tiếng Việt',
    );
  }

  Future<void> updateNotifOn(bool value) async {
    state = state.copyWith(notifOn: value);
    await _prefs.setBool('setting_notif_on', value);
  }

  Future<void> updateUnit(String value) async {
    state = state.copyWith(unit: value);
    await _prefs.setString('setting_unit', value);
  }

  Future<void> updateTheme(String value) async {
    state = state.copyWith(theme: value);
    await _prefs.setString('setting_theme', value);
  }

  Future<void> updateLanguage(String value) async {
    state = state.copyWith(language: value);
    await _prefs.setString('setting_language', value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
