abstract final class AppConstants {
  static const String appName = 'Buildmate 24x7';
  static const String appVersion = 'v1.0.0';
  static const String taglinePrefix = 'Everything for Construction.';
  static const String taglineEmphasis = 'One Trusted Platform.';

  static const Duration splashDuration = Duration(milliseconds: 2200);
  static const Duration mockNetworkDelay = Duration(milliseconds: 900);

  /// Mock OTP accepted by [MockAuthService].
  static const String mockOtp = '123456';

  static const int otpLength = 6;
  static const int otpResendSeconds = 30;
}
