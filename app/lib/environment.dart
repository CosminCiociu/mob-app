class Environment {
/* ATTENTION Please update your desired data. */

  static const String appName = 'Dating';
  static const String version = '1.0.0';

  static String defaultLangCode = "en";
  static String defaultLanguageName = "English";

  static String defaultPhoneCode = "1";
  static String defaultCountryCode = "US";
  static int otpTime = 60;

  // Stream Chat Configuration
  // TODO: Replace with your actual Stream Chat credentials from dashboard
  static const String streamChatApiKey =
      'ny57pb8j3rns'; // From Stream Dashboard > General > API Key
  static const String streamChatAppId =
      '1455164'; // From Stream Dashboard > General > App ID
  List<String> mobileRechargeQuickAmount = [
    "10",
    "20",
    "30",
    "40",
    "50",
    "60",
    "100",
    "500"
  ]; // it's a static amount you can change its for yourself
}
