import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Uygulama genelinde tutarlı hata yönetimi için utility sınıfı
class ErrorHandler {
  /// Hata türleri
  static const String networkError = 'network_error';
  static const String databaseError = 'database_error';
  static const String validationError = 'validation_error';
  static const String authenticationError = 'authentication_error';
  static const String permissionError = 'permission_error';
  static const String unknownError = 'unknown_error';
  // Extended error types
  static const String serverError = 'server_error';
  static const String timeoutError = 'timeout_error';
  static const String parseError = 'parse_error';
  static const String cacheError = 'cache_error';

  /// Hata mesajları
  static const Map<String, String> _errorMessages = {
    networkError: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
    databaseError:
        'Veritabanı hatası oluştu. Lütfen uygulamayı yeniden başlatın.',
    validationError: 'Girilen bilgiler geçersiz. Lütfen kontrol edin.',
    authenticationError: 'Kimlik doğrulama hatası. Lütfen tekrar giriş yapın.',
    permissionError: 'Bu işlem için gerekli izinlere sahip değilsiniz.',
    unknownError:
        'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
    serverError: 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
    timeoutError: 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
    parseError:
        'Veri işlenirken hata oluştu. Lütfen destek ile iletişime geçin.',
    cacheError: 'Önbellek hatası oluştu. Lütfen uygulamayı yeniden başlatın.',
  };

  /// Hata kodundan kullanıcı dostu mesaj döndürür
  static String getErrorMessage(String errorCode, {String? customMessage}) {
    return customMessage ??
        _errorMessages[errorCode] ??
        _errorMessages[unknownError]!;
  }

  /// Exception'dan hata kodunu belirler
  static String getErrorCodeFromException(dynamic exception) {
    if (exception is SocketException || exception is HttpException) {
      return networkError;
    } else if (exception is TimeoutException) {
      return timeoutError;
    } else if (exception is DatabaseException ||
        exception.toString().contains('database')) {
      return databaseError;
    } else if (exception is FormatException || exception is ArgumentError) {
      return parseError;
    } else if (exception is FileSystemException ||
        exception.toString().contains('cache')) {
      return cacheError;
    } else if (exception.toString().contains('404') ||
        exception.toString().contains('500')) {
      return serverError;
    } else {
      return unknownError;
    }
  }

  /// Hata loglama
  static void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    final errorMessage =
        '''
Error: $error
Context: ${context ?? 'Unknown'}
StackTrace: ${stackTrace ?? 'No stack trace'}
Time: ${DateTime.now()}
    '''
            .trim();

    if (kDebugMode) {
      print('🚨 APP ERROR: $errorMessage');
    } else {
      // Production'da Firebase Crashlytics kullan
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: context,
          information: [errorMessage],
        );
      } catch (e) {
        // If Firebase fails, at least print to console
        debugPrint('Failed to log to Firebase Crashlytics: $e');
      }
    }
  }

  /// Async operation wrapper - tutarlı hata yönetimi sağlar
  static Future<T> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
    bool showUserMessage = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final errorCode = getErrorCodeFromException(error);
      final errorMessage = getErrorMessage(errorCode);

      logError(error, stackTrace, context: context);

      if (showUserMessage && kDebugMode) {
        // Debug modunda kullanıcıya hata mesajı göster
        _showDebugErrorDialog(errorMessage);
      }

      if (defaultValue != null) {
        return defaultValue;
      }

      // AppException olarak yeniden fırlat
      if (error is AppException) {
        rethrow;
      } else {
        throw AppException(errorCode, errorMessage, originalError: error);
      }
    }
  }

  /// Sync operation wrapper
  static T handleSyncOperation<T>(
    T Function() operation, {
    String? context,
    T? defaultValue,
    bool showUserMessage = true,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      final errorCode = getErrorCodeFromException(error);
      final errorMessage = getErrorMessage(errorCode);

      logError(error, stackTrace, context: context);

      if (showUserMessage && kDebugMode) {
        _showDebugErrorDialog(errorMessage);
      }

      if (defaultValue != null) {
        return defaultValue;
      }

      // AppException olarak yeniden fırlat
      if (error is AppException) {
        rethrow;
      } else {
        throw AppException(errorCode, errorMessage, originalError: error);
      }
    }
  }

  /// Debug modunda hata dialog'u göster
  static void _showDebugErrorDialog(String message) {
    if (!kDebugMode) return;

    // Bu metod sadece debug için kullanılır
    // Production'da snackbar veya toast mesajı kullanılabilir
    debugPrint('Error Dialog: $message');
  }

  /// Kullanıcı dostu hata widget'ı
  static Widget buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
    String? title,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Bir Hata Oluştu',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading state widget
  static Widget buildLoadingWidget({String? message, double? size}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Network bağlantı kontrolü
  static Future<bool> checkNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Retry mechanism
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }

    throw Exception('Maximum retry attempts exceeded');
  }
}

/// Custom exception sınıfları
class AppException implements Exception {
  final String code;
  final String message;
  final dynamic originalError;

  AppException(this.code, this.message, {this.originalError});

  @override
  String toString() => 'AppException: $code - $message';
}

class NetworkException extends AppException {
  NetworkException(String message, {dynamic originalError})
    : super(ErrorHandler.networkError, message, originalError: originalError);
}

class DatabaseException extends AppException {
  DatabaseException(String message, {dynamic originalError})
    : super(ErrorHandler.databaseError, message, originalError: originalError);
}

class ValidationException extends AppException {
  ValidationException(String message, {dynamic originalError})
    : super(
        ErrorHandler.validationError,
        message,
        originalError: originalError,
      );
}

class ServerException extends AppException {
  ServerException(String message, {dynamic originalError})
    : super(ErrorHandler.serverError, message, originalError: originalError);
}

class TimeoutException extends AppException {
  TimeoutException(String message, {dynamic originalError})
    : super(ErrorHandler.timeoutError, message, originalError: originalError);
}

class ParseException extends AppException {
  ParseException(String message, {dynamic originalError})
    : super(ErrorHandler.parseError, message, originalError: originalError);
}

class CacheException extends AppException {
  CacheException(String message, {dynamic originalError})
    : super(ErrorHandler.cacheError, message, originalError: originalError);
}
