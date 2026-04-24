import 'package:forge/utils/config/flavor_config.dart';
import 'package:logger/logger.dart';
import 'package:forge/core/error/app_error.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  final Logger _logger = Logger();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  static String get baseUrl => FlavorConfig.instance.values.baseUrl;
  static bool get shouldShowLogs =>
      FlavorConfig.maybeValues?.enableLogging ?? false;
  static String get appTitle => FlavorConfig.instance.values.appTitle;

  static Map<String, dynamic> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-app-flavor': FlavorConfig.instance.flavor.toString().split('.').last,
      };

  Future<void> init() async {
    try {
      // Initialize any configuration settings
      _logger.i(
          'AppConfig initialized with flavor: ${FlavorConfig.instance.flavor}');
      _logger.i('Base URL: $baseUrl');
      _logger.i('Logging enabled: $shouldShowLogs');
    } catch (e, stackTrace) {
      AppError.create(
        message: 'Error initializing AppConfig',
        type: ErrorType.configuration,
        originalError: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static bool get isProduction => FlavorConfig.isProduction();
  static bool get isDevelopment => FlavorConfig.isDevelopment();
  static bool get isStaging => FlavorConfig.isStaging();

  // API Version
  static const String apiVersion = 'v1';
  static String get apiPath => '/api/$apiVersion';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Retry Configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // milliseconds

  // Cache Configuration
  static const bool enableCache = true;
  static const int cacheMaxAge =
      7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
  static const int cacheMaxSize = 10 * 1024 * 1024; // 10 MB in bytes

  // Feature Flags
  static bool get enablePushNotifications =>
      FlavorConfig.instance.values.enablePushNotifications;
  static bool get enableAnalytics =>
      FlavorConfig.instance.values.enableAnalytics;
  static bool get enableCrashReporting =>
      FlavorConfig.instance.values.enableCrashReporting;
}
