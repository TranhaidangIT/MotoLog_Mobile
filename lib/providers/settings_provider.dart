import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

// Keys for settings
const String _keyUnitsSetting = 'settings_units';
const String _keyLanguageSetting = 'settings_language';

// Units option helper
enum UnitsOption {
  litersVnd('Lít (L) / VNĐ'),
  gallonsUsd('Gallon (Gal) / USD');

  final String label;
  const UnitsOption(this.label);
}

// Language option helper
enum LanguageOption {
  vietnamese('Tiếng Việt', 'vi'),
  english('English', 'en');

  final String label;
  final String code;
  const LanguageOption(this.label, this.code);
}

// ─── Units Provider ──────────────────────────────────────────────────────────
final unitsProvider = StateNotifierProvider<UnitsNotifier, UnitsOption>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UnitsNotifier(prefs);
});

class UnitsNotifier extends StateNotifier<UnitsOption> {
  final SharedPreferences _prefs;

  UnitsNotifier(this._prefs) : super(UnitsOption.litersVnd) {
    final saved = _prefs.getString(_keyUnitsSetting);
    if (saved != null) {
      state = UnitsOption.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => UnitsOption.litersVnd,
      );
    }
  }

  Future<void> setUnits(UnitsOption option) async {
    state = option;
    await _prefs.setString(_keyUnitsSetting, option.name);
  }
}

// ─── Language Provider ───────────────────────────────────────────────────────
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageOption>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<LanguageOption> {
  final SharedPreferences _prefs;

  LanguageNotifier(this._prefs) : super(LanguageOption.vietnamese) {
    final saved = _prefs.getString(_keyLanguageSetting);
    if (saved != null) {
      state = LanguageOption.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => LanguageOption.vietnamese,
      );
    }
  }

  Future<void> setLanguage(LanguageOption option) async {
    state = option;
    await _prefs.setString(_keyLanguageSetting, option.name);
  }
}
