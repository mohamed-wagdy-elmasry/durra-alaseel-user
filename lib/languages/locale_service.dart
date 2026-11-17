import 'dart:ui' show TextDirection;
import 'package:flutter/material.dart' hide TextDirection;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Supported languages configuration
class LanguageConfig {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  const LanguageConfig({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRtl,
  });

  Locale get locale => Locale(code);

  TextDirection get direction => isRtl ? TextDirection.rtl : TextDirection.ltr;

  static const List<LanguageConfig> supportedLanguages = [
    LanguageConfig(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      isRtl: false,
    ),
    LanguageConfig(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      isRtl: true,
    ),
  ];

  static LanguageConfig fromCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }

  static List<Locale> get supportedLocales =>
      supportedLanguages.map((l) => l.locale).toList();
}

/// LocaleService - Single source of truth for app localization
class LocaleService extends GetxService {
  static const String _storageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  final _storage = GetStorage();

  /// Reactive current language code
  final _currentLanguageCode = _defaultLanguage.obs;

  /// Get current language code
  String get currentLanguageCode => _currentLanguageCode.value;

  /// Get current locale
  Locale get currentLocale => Locale(_currentLanguageCode.value);

  /// Get current text direction
  TextDirection get textDirection =>
      LanguageConfig.fromCode(_currentLanguageCode.value).direction;

  /// Check if current language is RTL
  bool get isRtl => textDirection == TextDirection.rtl;

  /// Get current language config
  LanguageConfig get currentLanguage =>
      LanguageConfig.fromCode(_currentLanguageCode.value);

  /// Get all supported languages
  List<LanguageConfig> get languages => LanguageConfig.supportedLanguages;

  /// Initialize service - call once at app startup
  static Future<LocaleService> init() async {
    final service = LocaleService();
    await service._loadSavedLanguage();
    Get.put<LocaleService>(service, permanent: true);
    return service;
  }

  /// Load saved language from storage
  Future<void> _loadSavedLanguage() async {
    final savedCode = _storage.read<String>(_storageKey);
    if (savedCode != null && _isValidLanguageCode(savedCode)) {
      _currentLanguageCode.value = savedCode;
    } else {
      // Use device locale if supported, otherwise default
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null &&
          _isValidLanguageCode(deviceLocale.languageCode)) {
        _currentLanguageCode.value = deviceLocale.languageCode;
      }
    }
    _updateIntlLocale();
  }

  /// Check if language code is supported
  bool _isValidLanguageCode(String code) {
    return LanguageConfig.supportedLanguages.any((lang) => lang.code == code);
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    if (!_isValidLanguageCode(languageCode)) {
      debugPrint('LocaleService: Invalid language code: $languageCode');
      return;
    }

    if (_currentLanguageCode.value == languageCode) return;

    _currentLanguageCode.value = languageCode;
    await _storage.write(_storageKey, languageCode);
    _updateIntlLocale();

    // Update GetX locale for .tr translations
    Get.updateLocale(Locale(languageCode));

    debugPrint('LocaleService: Language changed to $languageCode');
  }

  /// Update Intl default locale for date/number formatting
  void _updateIntlLocale() {
    Intl.defaultLocale = _currentLanguageCode.value;
  }

  /// Get instance (after init)
  static LocaleService get to => Get.find<LocaleService>();

  /// Translate a key - returns the key itself if not found
  String translate(String key) {
    // Use GetX .tr for translation lookup
    final translated = key.tr;
    return translated;
  }
}

/// Extension for easy translation access
extension TranslationExtension on String {
  /// Translate this string key
  String get translated => LocaleService.to.translate(this);
}
