/// Configuration class for API keys and constants
/// This allows you to easily manage API keys from one place
class AppConfig {
  /// Google Maps API Key
  /// This key is also configured in android/app/src/main/AndroidManifest.xml
  /// You can override this with environment variables when building:
  /// flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue:
        'AIzaSyBg_Vof3rcoYR5-NdOZxKDk7QBntEOQZ2U', // Your API key from manifest
  );

  /// Other configuration constants can be added here
  static const String appName = 'Clubbie';
  static const String supportEmail = 'support@clubbie.com';
}
