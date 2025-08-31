import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final String themeModeKey = "theme_mode";
  final String dynamicColorKey = "dynamic_color_enabled";

  ThemeMode _themeMode;
  bool _useDynamicColor;
  ColorScheme? _dynamicLightColorScheme;
  ColorScheme? _dynamicDarkColorScheme;

  ThemeProvider() : _themeMode = ThemeMode.system, _useDynamicColor = true {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get useDynamicColor => _useDynamicColor;
  ColorScheme? get dynamicLightColorScheme => _dynamicLightColorScheme;
  ColorScheme? get dynamicDarkColorScheme => _dynamicDarkColorScheme;

  /// Get the effective theme mode considering system preference
  ThemeMode get effectiveThemeMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    }
    return _themeMode;
  }

  /// Get the effective color scheme based on current settings
  ColorScheme? get effectiveLightColorScheme {
    return _useDynamicColor ? _dynamicLightColorScheme : null;
  }

  ColorScheme? get effectiveDarkColorScheme {
    return _useDynamicColor ? _dynamicDarkColorScheme : null;
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _saveToPrefs();
    notifyListeners();
  }

  void setDynamicColorEnabled(bool enabled) {
    _useDynamicColor = enabled;
    _saveToPrefs();
    notifyListeners();
  }

  void updateDynamicColorSchemes(ColorScheme? light, ColorScheme? dark) {
    _dynamicLightColorScheme = light;
    _dynamicDarkColorScheme = dark;
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeString = prefs.getString(themeModeKey);
    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    // Load dynamic color preference
    _useDynamicColor = prefs.getBool(dynamicColorKey) ?? true;

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Save theme mode
    if (_themeMode == ThemeMode.light) {
      prefs.setString(themeModeKey, 'light');
    } else if (_themeMode == ThemeMode.dark) {
      prefs.setString(themeModeKey, 'dark');
    } else {
      prefs.remove(themeModeKey);
    }

    // Save dynamic color preference
    prefs.setBool(dynamicColorKey, _useDynamicColor);
  }

  /// Get theme data with dynamic color support
  ThemeData getThemeData({
    required Brightness brightness,
    required ColorScheme? dynamicColorScheme,
  }) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    if (dynamicColorScheme != null && _useDynamicColor) {
      return baseTheme.copyWith(colorScheme: dynamicColorScheme);
    }

    // Fallback to default theme if no dynamic colors
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE91E63), // Primary color
        brightness: brightness,
      ),
    );
  }
}
