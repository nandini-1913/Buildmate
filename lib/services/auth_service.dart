import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/firebase/firebase_bootstrap.dart';
import '../core/network/api_client.dart';
import '../features/auth/domain/models/auth_models.dart';
import '../features/auth/services/auth_service.dart' as auth_contract;

/// Firebase Phone OTP authentication for Buildmate 24x7.
class PhoneAuthService implements auth_contract.AuthService {
  PhoneAuthService._();

  static final PhoneAuthService instance = PhoneAuthService._();

  String? _verificationId;
  int? _resendToken;

  /// Attaches fresh Firebase ID tokens to every [ApiClient] request.
  void attachApiClient() {
    ApiClient.authTokenProvider = ({bool forceRefresh = false}) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return user.getIdToken(forceRefresh);
    };
  }

  /// Maps Firebase error codes to user-facing copy.
  static String friendlyError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Enter a valid 10-digit mobile number.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'invalid-verification-code':
        return 'Invalid code. Check the SMS and try again.';
      case 'session-expired':
      case 'code-expired':
        return 'This code has expired. Tap Resend to get a new one.';
      case 'invalid-verification-id':
        return 'Verification session expired. Request a new OTP.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static String toE164(String mobileNumber) {
    final digits = mobileNumber.replaceAll(RegExp(r'\D'), '');
    final local = digits.length > 10 && digits.startsWith('91')
        ? digits.substring(digits.length - 10)
        : digits;
    return '+91$local';
  }

  AuthUser _userFromFirebase(User user, String fallbackMobile) {
    final phone = user.phoneNumber;
    final mobile = phone != null && phone.isNotEmpty
        ? phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^91'), '')
        : fallbackMobile;
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      mobileNumber: mobile,
      fullName: user.displayName,
    );
  }

  @override
  Future<AuthResult> sendOtp({required String mobileNumber}) async {
    if (!FirebaseBootstrap.isReady) {
      return AuthResult.fail(
        'Sign-in is temporarily unavailable. Restart the app and try again.',
      );
    }
    final phone = toE164(mobileNumber);
    final completer = Completer<AuthResult>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final cred =
              await FirebaseAuth.instance.signInWithCredential(credential);
          final user = cred.user;
          if (user == null) {
            if (!completer.isCompleted) {
              completer.complete(
                AuthResult.fail('Automatic verification failed.'),
              );
            }
            return;
          }
          await user.getIdToken();
          if (!completer.isCompleted) {
            completer.complete(
              AuthResult.ok(_userFromFirebase(user, mobileNumber)),
            );
          }
        } catch (e) {
          debugPrint('verificationCompleted error: $e');
          if (!completer.isCompleted) {
            completer.complete(
              AuthResult.fail('Automatic verification failed.'),
            );
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('verificationFailed: ${e.code} ${e.message}');
        if (!completer.isCompleted) {
          completer.complete(AuthResult.fail(friendlyError(e.code)));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) {
          completer.complete(
            AuthResult.ok(
              AuthUser(
                id: 'pending',
                email: '',
                mobileNumber: mobileNumber,
              ),
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  @override
  Future<AuthResult> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      return AuthResult.fail(friendlyError('session-expired'));
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(),
      );
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) {
        return AuthResult.fail('Sign-in failed. Please try again.');
      }
      await user.getIdToken();
      return AuthResult.ok(_userFromFirebase(user, mobileNumber));
    } on FirebaseAuthException catch (e) {
      debugPrint('verifyOtp failed: ${e.code} ${e.message}');
      return AuthResult.fail(friendlyError(e.code));
    }
  }

  Future<void> signOut() async {
    _verificationId = null;
    _resendToken = null;
    await FirebaseAuth.instance.signOut();
  }

  Future<AuthUser?> currentAuthUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return _userFromFirebase(user, '');
  }

  @override
  Future<AuthResult> continueAsGuest() async {
    return AuthResult.ok(AuthUser.guest());
  }

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return AuthResult.fail('Email sign-in is not enabled.');
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    return AuthResult.fail('Google sign-in is not enabled.');
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    return AuthResult.fail('Use phone OTP to sign in.');
  }

  @override
  Future<AuthResult> sendPasswordResetCode({
    required String identifier,
    required bool isEmail,
  }) async {
    return AuthResult.fail('Password reset is not available.');
  }

  @override
  Future<AuthResult> resetPassword({
    required String identifier,
    required String newPassword,
  }) async {
    return AuthResult.fail('Password reset is not available.');
  }
}
