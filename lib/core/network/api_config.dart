/// Central API configuration for the customer mobile app.
///
/// **Source of truth:** `dashboard/backend/server.py` (restore-brand-imports branch),
/// NOT the standalone `Python-API` repo which only exposes a legacy catalog schema
/// (`name`, `category`, `unit`, `standardRate`).
///
/// Configure at build/run time (optional override):
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
///
/// Android emulator → host machine: `http://10.0.2.2:8000`
/// Physical device on same Wi‑Fi → `http://<laptop-lan-ip>:8000`
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://python-api-6aft.onrender.com',
  );

  static const String apiPrefix = '/api';

  static String get catalogUrl => '$baseUrl$apiPrefix/catalog';

  /// Poll interval for near-real-time catalog refresh during customer demo.
  static const Duration catalogPollInterval = Duration(seconds: 3);
}
