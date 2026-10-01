import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../domain/models/auth_models.dart';
import 'auth_service.dart';
import 'mock_auth_service.dart';

/// Phone login through Firebase Authentication.
///
/// Email, guest, and password-reset flows stay on [MockAuthService].
class FirebasePhoneAuthService implements AuthService {
  FirebasePhoneAuthService({FirebaseAuth? auth, AuthService? fallback})
      : _authOverride = auth,
        _fallback = fallback ?? MockAuthService();

  final FirebaseAuth? _authOverride;
  final AuthService _fallback;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  String _e164(String mobileNumber) {
    final trimmed = mobileNumber.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (trimmed.startsWith('+') && digits.length > 10) return '+$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return '+91$digits';
  }

  @override
  Future<AuthResult> sendOtp({required String mobileNumber}) async {
    final phone = _e164(mobileNumber);
    final completer = Completer<AuthResult>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (credential) async {
          _verificationId = null;
          try {
            final signedIn = await _auth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(AuthResult.ok(_userFromFirebase(signedIn, phone)));
            }
          } catch (error) {
            if (!completer.isCompleted) {
              completer.complete(
                AuthResult.fail('Could not complete automatic verification.'),
              );
            }
          }
        },
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.complete(
              AuthResult.fail(error.message ?? 'Could not send the OTP.'),
            );
          }
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!completer.isCompleted) {
            completer.complete(
              AuthResult.ok(
                AuthUser(id: 'pending', email: '', mobileNumber: phone),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId ??= verificationId;
        },
      );
    } catch (error) {
      return AuthResult.fail('Could not send the OTP.');
    }

    return completer.future.timeout(
      const Duration(seconds: 70),
      onTimeout: () => AuthResult.fail('OTP request timed out. Try again.'),
    );
  }

  @override
  Future<AuthResult> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final phone = _e164(mobileNumber);
    final current = _auth.currentUser;
    if (current != null && current.phoneNumber == phone) {
      return AuthResult.ok(_userFromFirebaseUser(current, phone));
    }

    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      return AuthResult.fail('Request a new OTP first.');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(),
      );
      final signedIn = await _auth.signInWithCredential(credential);
      return AuthResult.ok(_userFromFirebase(signedIn, phone));
    } on FirebaseAuthException catch (error) {
      return AuthResult.fail(error.message ?? 'Invalid OTP.');
    } catch (_) {
      return AuthResult.fail('Invalid OTP.');
    }
  }

  AuthUser _userFromFirebase(UserCredential credential, String phone) {
    final user = credential.user;
    if (user == null) {
      return AuthUser(id: 'user-otp', email: '', mobileNumber: phone, fullName: 'Verified User');
    }
    return _userFromFirebaseUser(user, phone);
  }

  AuthUser _userFromFirebaseUser(User user, String phone) {
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      fullName: (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : 'Verified User',
      mobileNumber: user.phoneNumber ?? phone,
    );
  }

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _fallback.signInWithEmail(email: email, password: password);

  @override
  Future<AuthResult> signInWithGoogle() => _fallback.signInWithGoogle();

  @override
  Future<AuthResult> continueAsGuest() => _fallback.continueAsGuest();

  @override
  Future<AuthResult> register(RegisterRequest request) =>
      _fallback.register(request);

  @override
  Future<AuthResult> sendPasswordResetCode({
    required String identifier,
    required bool isEmail,
  }) =>
      _fallback.sendPasswordResetCode(identifier: identifier, isEmail: isEmail);

  @override
  Future<AuthResult> resetPassword({
    required String identifier,
    required String newPassword,
  }) =>
      _fallback.resetPassword(identifier: identifier, newPassword: newPassword);
}
