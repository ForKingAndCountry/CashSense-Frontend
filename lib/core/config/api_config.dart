/// Base URL for the Pocket Accountant Next.js API.
///
/// Production default: Vercel deployment.
/// Override for local dev, e.g.:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000`
abstract final class ApiConfig {
  static const productionBaseUrl = 'https://pocket-accountant-backend.vercel.app';

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: productionBaseUrl,
  );
}
