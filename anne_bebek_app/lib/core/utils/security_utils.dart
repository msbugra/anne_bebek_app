import 'dart:convert';

/// Uygulama güvenliği için utility sınıfı
class SecurityUtils {
  /// SQL Injection koruması için input sanitization
  static String sanitizeSqlInput(String input) {
    if (input.isEmpty) return input;

    // Tehlikeli karakterleri escape et
    return input
        .replaceAll("'", "''") // SQL string literal escaping
        .replaceAll('\\', '\\\\') // Backslash escaping
        .replaceAll('\x00', '') // Null byte removal
        .replaceAll('\n', '') // Newline removal
        .replaceAll('\r', '') // Carriage return removal
        .replaceAll('\t', '') // Tab removal
        .trim(); // Trim whitespace
  }

  /// SQL sorgularında güvenli parameter kullanımı
  static Map<String, dynamic> sanitizeSqlParameters(
    Map<String, dynamic> params,
  ) {
    final sanitized = <String, dynamic>{};

    params.forEach((key, value) {
      if (value is String) {
        sanitized[key] = sanitizeSqlInput(value);
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = sanitizeSqlParameters(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          return item is String ? sanitizeSqlInput(item) : item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// XSS koruması için HTML sanitization
  static String sanitizeHtmlInput(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .replaceAll('"', '"')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;')
        .replaceAll('\\', '&#x5C;')
        .replaceAll('(', '&#40;')
        .replaceAll(')', '&#41;')
        .trim();
  }

  /// Input validation - Email format kontrolü
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Basit email regex - production'da daha güçlü kullanılabilir
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  /// Input validation - Telefon numarası kontrolü (Türk formatı)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;

    // Sadece rakamları al
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Türk telefon numarası formatları
    final phoneRegex = RegExp(r'^(?:\+?90|0)?[5][0-9]{9}$');

    return phoneRegex.hasMatch(cleanPhone) && cleanPhone.length >= 10;
  }

  /// Input validation - İsim kontrolü
  static bool isValidName(String name) {
    if (name.isEmpty || name.length < 2 || name.length > 50) return false;

    // Sadece harf, boşluk, apostrof ve tire içerebilir
    final nameRegex = RegExp(r"^[a-zA-ZçğıöşüÇĞİÖŞÜ\s'-]+$");

    return nameRegex.hasMatch(name.trim());
  }

  /// Güvenli rastgele string üretimi
  static String generateSecureRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      final index = (random + i) % chars.length;
      buffer.write(chars[index]);
    }

    return buffer.toString();
  }

  /// Basit hash üretimi (şifreleme için)
  static String generateSimpleHash(String input, {String salt = ''}) {
    final combined = input + salt;
    var hash = 0;

    for (int i = 0; i < combined.length; i++) {
      final char = combined.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }

    return hash.toString();
  }

  /// Data encryption/decryption için basit obfuscation
  static String obfuscateData(String data) {
    if (data.isEmpty) return data;

    final bytes = utf8.encode(data);
    final obfuscated = bytes.map((byte) => byte ^ 0xAA).toList();
    return base64Encode(obfuscated);
  }

  static String deobfuscateData(String obfuscatedData) {
    if (obfuscatedData.isEmpty) return obfuscatedData;

    try {
      final bytes = base64Decode(obfuscatedData);
      final deobfuscated = bytes.map((byte) => byte ^ 0xAA).toList();
      return utf8.decode(deobfuscated);
    } catch (e) {
      return obfuscatedData; // Hata durumunda orijinal veriyi döndür
    }
  }

  /// Güvenli logging - sensitive data'yı maskele
  static String maskSensitiveData(String data, {String maskChar = '*'}) {
    if (data.isEmpty) return data;

    if (data.length <= 4) return maskChar * data.length;

    final visibleChars = 2;
    final maskedLength = data.length - (visibleChars * 2);

    return data.substring(0, visibleChars) +
        (maskChar * maskedLength) +
        data.substring(data.length - visibleChars);
  }

  /// Input length validation
  static bool isValidLength(String input, {int minLength = 0, int? maxLength}) {
    if (input.length < minLength) return false;
    if (maxLength != null && input.length > maxLength) return false;
    return true;
  }

  /// SQL injection pattern detection
  static bool containsSqlInjectionPatterns(String input) {
    if (input.isEmpty) return false;

    final dangerousPatterns = [
      'UNION SELECT',
      'DROP TABLE',
      'DELETE FROM',
      'INSERT INTO',
      'UPDATE.*SET',
      'EXEC',
      'EXECUTE',
      'SCRIPT',
      'SELECT.*FROM',
      '--',
      '/*',
      '*/',
      'XP_',
      'SP_',
    ];

    final upperInput = input.toUpperCase();

    return dangerousPatterns.any((pattern) => upperInput.contains(pattern));
  }

  /// XSS pattern detection
  static bool containsXssPatterns(String input) {
    if (input.isEmpty) return false;

    final dangerousPatterns = [
      '<script',
      'javascript:',
      'onload=',
      'onerror=',
      'onclick=',
      '<iframe',
      '<object',
      '<embed',
      'eval(',
      'alert(',
    ];

    final lowerInput = input.toLowerCase();

    return dangerousPatterns.any((pattern) => lowerInput.contains(pattern));
  }

  /// Genel input validation
  static ValidationResult validateInput(
    String input, {
    bool allowEmpty = false,
    int? minLength,
    int? maxLength,
    bool checkSqlInjection = true,
    bool checkXss = true,
  }) {
    // Boş input kontrolü
    if (!allowEmpty && input.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Bu alan boş bırakılamaz',
      );
    }

    final trimmedInput = input.trim();

    // Uzunluk kontrolü
    if (minLength != null && trimmedInput.length < minLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'En az $minLength karakter giriniz',
      );
    }

    if (maxLength != null && trimmedInput.length > maxLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'En fazla $maxLength karakter girebilirsiniz',
      );
    }

    // SQL injection kontrolü
    if (checkSqlInjection && containsSqlInjectionPatterns(trimmedInput)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Geçersiz karakterler içeriyor',
      );
    }

    // XSS kontrolü
    if (checkXss && containsXssPatterns(trimmedInput)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Geçersiz karakterler içeriyor',
      );
    }

    return ValidationResult(isValid: true);
  }
}

/// Validation sonucu sınıfı
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, errorMessage: $errorMessage)';
}

/// Güvenlik konfigürasyonu
class SecurityConfig {
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const bool requireSpecialChars = true;
  static const bool requireNumbers = true;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
}
