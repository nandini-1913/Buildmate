# SCR-06 — OTP verification

- Route: `/otp-verification` (`AppRoutes.otpVerification`)
- Source: [otp_verification_screen.dart](../lib/features/auth/presentation/screens/otp_verification_screen.dart) — 292 lines; [auth_otp_fields.dart](../lib/features/auth/presentation/widgets/auth_otp_fields.dart); [auth_service.dart](../lib/services/auth_service.dart); [mock_auth_service.dart](../lib/features/auth/services/mock_auth_service.dart)
- Purpose: Verify a six-digit code and route to password reset, login completion, or account creation according to `OtpPurpose`.

## Data

- Screen open: reads `OtpVerificationArgs` (`contactDisplay`, `purpose`, optional `resetIdentifier`, `resetIsEmail`, and `mobileNumber`) and starts a 60-second resend countdown (`otp_verification_screen.dart:51-59`; `lib/core/routes/app_routes.dart:50-65`).
- Default service: password-reset purpose uses `MockAuthService`; other purposes use `PhoneAuthService.instance` (`otp_verification_screen.dart:51-59`).
- `Enter 6-digit code` or automatic six-digit completion: calls `AuthService.verifyOtp(mobileNumber: _rawMobile, otp: otp)` (`otp_verification_screen.dart:80-90,210-216,237-245`). `_rawMobile` uses `args.mobileNumber`, or strips nondigits and a leading `91` from displayed contact (`otp_verification_screen.dart:45-48`).
- For mobile login, real service verifies via Firebase phone credentials; default password reset verifies with mock service and `AppConstants.mockOtp` (`lib/services/auth_service.dart:141-166`; `lib/features/auth/services/mock_auth_service.dart:87-107`; `lib/core/constants/app_constants.dart:10-14`). No app API method/path is called by this screen.
- On successful password-reset verification, replace screen with `/reset-password`, passing `resetIdentifier ?? contactDisplay` and `resetIsEmail` (`otp_verification_screen.dart:99-109`).
- On successful mobile login, store returned user via `SessionController.setFromAuth()` and clear stack into `/home-placeholder` (`otp_verification_screen.dart:110-119`).
- On successful registration OTP, replace with `/create-account`, passing mobile and an empty full name (`otp_verification_screen.dart:120-130`).
- `Resend OTP`: calls `AuthService.sendOtp(mobileNumber: _rawMobile)` (`otp_verification_screen.dart:133-139`); on success clears fields, restarts countdown and shows snackbar (`otp_verification_screen.dart:146-153`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| OTP-BTN-01 | Back icon button | No visible text (arrow-back icon) | `Navigator.pop()` (`otp_verification_screen.dart:177-179`; `login_flow_widgets.dart:603-621`) | Always | N | Y |
| OTP-TXT-01 | Header title | `Verify Code` / `Verify your number` | Password-reset purpose selects `Verify Code`; other purposes select `Verify your number` (`otp_verification_screen.dart:157-158,180-188`) | Always; text depends on purpose | N | Y |
| OTP-VIS-01 | Verification icon | No visible text; OTP-themed icon | Decorative `LoginFlowOtpIcon` (`otp_verification_screen.dart:191-193`; `login_flow_widgets.dart:510-527`) | Always | N | Y |
| OTP-TXT-02 | Instruction | `We've sent a 6-digit code to` | Static instruction (`otp_verification_screen.dart:195-201`) | Always | N | Y |
| OTP-TXT-03 | Contact value | `args.contactDisplay` (exact runtime value varies) | Displays the destination passed in route args (`otp_verification_screen.dart:203-209`) | Always | N | Y |
| OTP-IN-01 | Six-digit code input | No placeholder text; six digit boxes | Each box accepts a digit; input change updates `_otp`, clears error, advances focus; pasted multi-character digits populate boxes; six digits automatically call `_verify` (`otp_verification_screen.dart:210-218`; `auth_otp_fields.dart:10-72,89-151`) | Always | Y — digit order is the verification code | Y |
| OTP-MSG-01 | Error message | Resend service result message, fallback `Could not resend OTP.`; verification fallback is `Invalid OTP` | Resend failure sets `_error`, displayed under the boxes. Verification failure briefly sets its result message then clears fields; `AuthOtpFields.clear()` calls `onChanged('')`, which resets `_error`, so no verification-failure message remains visible (`otp_verification_screen.dart:94-97,141-144,220-228`; `auth_otp_fields.dart:33-39`; parent callback at `otp_verification_screen.dart:214-218`) | Resend failure; verification failure text is not visible after clear callback | N | Y |
| OTP-TXT-04 | Helper text | `Tap the boxes to enter or paste your code` | Static helper (`otp_verification_screen.dart:231-236`) | Always | N | Y |
| OTP-BTN-02 | Primary button | `Enter 6-digit code` | Calls `_verify()`; enabled when exactly six digits are entered and shows loading indicator while verifying (`otp_verification_screen.dart:157,237-245`; `login_flow_widgets.dart:26-89`) | Always; disabled unless code length is six; disabled while loading | Y — submits the entered code | Y |
| OTP-STATE-01 | Loading indicator | No visible text | Spinner shown inside primary button while `_loading` (`otp_verification_screen.dart:85-91,237-245`; `login_flow_widgets.dart:70-88`) | Verification or resend request in progress | N | Y |
| OTP-TXT-05 | Countdown text | `Didn't receive the code? ` + `Resend OTP in 0:<two-digit seconds>` | Updates every second until zero (`otp_verification_screen.dart:61-70,247-263`) | While `_seconds > 0` | N | Y |
| OTP-LINK-01 | Inline link | `Resend OTP` preceded by `Didn't receive the code? ` | Tap calls `_resend()`; on success clears OTP, restarts countdown, and shows snackbar (`otp_verification_screen.dart:133-153,264-280`) | When `_seconds == 0` | Y — resend precedes a fresh code entry | Y |
| OTP-MSG-02 | Success snackbar | `A new verification code has been sent.` | Shown after successful resend (`otp_verification_screen.dart:146-153`) | After resend succeeds | N | Y |

## States and messages

- Initial: `_otp` empty, `_seconds = 60`, not loading, no error; timer ticks once per second (`otp_verification_screen.dart:37-44,61-70`; `AppConstants.otpResendSeconds` at `lib/core/constants/app_constants.dart:14`).
- Title: `Verify Code` for password reset; otherwise `Verify your number` (`otp_verification_screen.dart:157-158`).
- Input: six digit-only cells; after six digits `_verify` is invoked automatically. Manually pressing the button also invokes it (`auth_otp_fields.dart:89-151`; `otp_verification_screen.dart:80-90,210-245`).
- Verifying/resending: `_loading` true, `_error` cleared; primary button displays spinner (`otp_verification_screen.dart:84-88,133-139`).
- Verification failure: code attempts to set service message or fallback `Invalid OTP`, then clears all OTP boxes. Clearing calls `onChanged('')`, which immediately sets `_error = null`; therefore no verification-failure text or error border remains visible after this sequence (`otp_verification_screen.dart:94-97,214-218`; `auth_otp_fields.dart:33-39`). The default mock reset service message is `Invalid OTP. Please enter 123456.` (`mock_auth_service.dart:87-95`); real Firebase verification can return `This code has expired. Tap Resend to get a new one.`, `Verification session expired. Request a new OTP.`, `Invalid code. Check the SMS and try again.`, `Too many attempts. Please wait and try again.`, or `Something went wrong. Please try again.` (`lib/services/auth_service.dart:30-45,147-166`), but the screen clears these on failed verification.
- Resend unavailable/failure: `_error` shows returned message or fallback `Could not resend OTP.` (`otp_verification_screen.dart:141-144`). Default real-service failures include `Sign-in is temporarily unavailable. Restart the app and try again.`, `Enter a valid 10-digit mobile number.`, `Too many attempts. Please wait and try again.`, and `Something went wrong. Please try again.` (`lib/services/auth_service.dart:30-45,70-74`); mock service may show `Mobile number is required.` (`mock_auth_service.dart:76-83`).
- Countdown state: while > 0, `Didn't receive the code? ` and `Resend OTP in 0:<two-digit seconds>` are displayed; at zero the tappable `Resend OTP` replaces countdown (`otp_verification_screen.dart:247-280`).
- Successful resend: fields cleared, 60-second timer restarted, snackbar text `A new verification code has been sent.` (`otp_verification_screen.dart:146-153`).
- Successful verification: route depends on `passwordReset`, `mobileLogin`, or `registration`; no success message (`otp_verification_screen.dart:99-130`).

## Displayed values

- Countdown uses `0:${_seconds.toString().padLeft(2, '0')}`; at initial 60 it reads `0:60` (`otp_verification_screen.dart:256`; timer initialized by `AppConstants.otpResendSeconds = 60`, `lib/core/constants/app_constants.dart:14`).
- Contact value is `args.contactDisplay` exactly (`otp_verification_screen.dart:203-209`).
- `_rawMobile`: `args.mobileNumber` when non-null; otherwise strip non-digits from `_contact` and strip leading `91` (`otp_verification_screen.dart:45-48`).
- OTP length is `AppConstants.otpLength` (6); mock reset OTP is `123456` (`auth_otp_fields.dart:11-13`; `lib/core/constants/app_constants.dart:10-13`).

## Style with meaning

- OTP fields distinguish filled/unfilled cells and show error-colored borders when `_error != null` (`auth_otp_fields.dart:89-151`). This applies to resend failures; verification failures clear `_error` as noted above.
- Rendered error text uses error color (`otp_verification_screen.dart:220-228`).
- Disabled/loading submit button and resend countdown/link represent code completeness, request activity, and timer state (`otp_verification_screen.dart:237-280`; `login_flow_widgets.dart:26-89`).
- Palette may change, but error, focus, filled, disabled, loading, and countdown/link states must remain distinguishable.

## Keyboard and focus

- Each code cell uses numeric keyboard, digits-only formatter, max length 1, centered text (`auth_otp_fields.dart:99-151`).
- Typing a digit advances focus; after the sixth digit focus is removed. Pasting distributes digits across cells. Backspace on an empty cell clears/focuses the previous cell (`auth_otp_fields.dart:41-72,89-151`).
- `clear()` resets all fields and focuses the first (`auth_otp_fields.dart:25-31`).
- No autofocus is set. Screen scroll view dismisses keyboard on drag (`otp_verification_screen.dart:171-177`).
- No explicit Escape handler or custom screen focus order beyond cell-to-cell progression.

## Responsive

- `SafeArea` + `SingleChildScrollView`; no breakpoint/alternate layout (`otp_verification_screen.dart:168-177`).
- Six cells share row width equally and adapt to available width (`auth_otp_fields.dart:89-98`).

## Risk notes

- Preserve six-cell order, paste distribution, backspace navigation, onChanged/onCompleted callbacks, and `GlobalKey` clear behavior (`otp_verification_screen.dart:34,210-218`; `auth_otp_fields.dart:25-72,89-151`).
- Preserve timer lifecycle and 60-second resend gating; timer is cancelled on dispose (`otp_verification_screen.dart:61-78`).
- Preserve purpose-specific destinations and payloads; registration passes an empty full name to Create Account and mobile login saves the user before clearing the route stack (`otp_verification_screen.dart:99-130`).
- Password-reset code uses `MockAuthService` by default; other purposes use Firebase phone authentication (`otp_verification_screen.dart:51-59`).
