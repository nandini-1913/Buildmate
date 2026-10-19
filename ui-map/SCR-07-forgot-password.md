# SCR-07 — Forgot password

- Route: `/forgot-password` (`AppRoutes.forgotPassword`)
- Source: [forgot_password_screen.dart](../lib/features/auth/presentation/screens/forgot_password_screen.dart) — 263 lines; [auth_validators.dart](../lib/features/auth/presentation/widgets/auth_validators.dart); [mock_auth_service.dart](../lib/features/auth/services/mock_auth_service.dart)
- Purpose: Select email or mobile, validate the registered identifier, and request a reset code before OTP verification.

## Data

- Screen open: no API request. Default service is `MockAuthService()` (`forgot_password_screen.dart:27-40`).
- `Send Reset Code`: validates the active form field; on valid input calls `sendPasswordResetCode(identifier: trimmed active field, isEmail: _isEmail)` (`forgot_password_screen.dart:45-56`).
- Mock service waits `AppConstants.mockNetworkDelay` (900 ms), fails only for blank identifier, otherwise returns a `reset-pending` user (`mock_auth_service.dart:10,109-126`; constant `lib/core/constants/app_constants.dart:8`). No app API method/path is called.
- On service success, navigates to `/otp-verification` with purpose `passwordReset`, raw identifier, `resetIsEmail`, and contact display (email unchanged; mobile formatted) (`forgot_password_screen.dart:68-82`).
- On service failure, shows a red snackbar with `result.message` or fallback `Failed to send reset code` (`forgot_password_screen.dart:59-65`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| FGP-BTN-01 | Back button | `Back to Login` (arrow-back icon) | Pops current route (`forgot_password_screen.dart:101-114`) | Always | N | Y |
| FGP-VIS-01 | Lock-reset icon | No visible text | Decorative icon (`forgot_password_screen.dart:117-128`) | Always | N | Y |
| FGP-TXT-01 | Heading | `Forgot Password?` | Static heading (`forgot_password_screen.dart:131`) | Always | N | Y |
| FGP-TXT-02 | Instruction | `Enter your registered email address or mobile number. We'll send you a verification code.` | Static instruction (`forgot_password_screen.dart:133-137`) | Always | N | Y |
| FGP-TAB-01 | Tab/chip | `Email Address` | Selects email mode (`_isEmail = true`), showing email input (`forgot_password_screen.dart:143-150`) | Always; selected initially | Y — determines active input/validator and request type | Y |
| FGP-TAB-02 | Tab/chip | `Mobile Number` | Selects mobile mode (`_isEmail = false`), showing mobile input (`forgot_password_screen.dart:151-158`) | Always | Y — determines active input/validator and request type | Y |
| FGP-IN-01 | Email input | `Registered Email Address` | Writes `_emailController`; email keyboard and `AuthValidators.email` (`forgot_password_screen.dart:160-168`; validator at `auth_validators.dart:8-12`) | Only when Email Address selected | Y — selected value is submitted | Y |
| FGP-IN-02 | Mobile input | `Registered Mobile Number` | Writes `_mobileController`; phone keyboard and `AuthValidators.mobile` (`forgot_password_screen.dart:169-176`; validator at `auth_validators.dart:34-41`) | Only when Mobile Number selected | Y — selected value is submitted | Y |
| FGP-BTN-02 | Primary button | `Send Reset Code` (send icon) | `_submit` → validate, call reset-code service, show failure snackbar or route to OTP verification (`forgot_password_screen.dart:45-82,177-184`) | Always; disabled while loading (`AuthPrimaryButton`, `auth_primary_button.dart:27-64`) | Y — submits current mode and field | Y |
| FGP-STATE-01 | Loading indicator | No visible text | Replaces button child with spinner while service call runs (`forgot_password_screen.dart:51-57,177-184`; `auth_primary_button.dart:45-62`) | During request | N | Y |
| FGP-MSG-01 | Error snackbar | Service result message or fallback `Failed to send reset code` | Shown on unsuccessful result (`forgot_password_screen.dart:59-65`) | Only after service failure | N | Y |
| FGP-VIS-02 | Informational notice | `Check your inbox or messages folder. The code expires in 10 minutes.` | Static informational copy with info icon (`forgot_password_screen.dart:188-214`) | Always | N | Y |

## States and messages

- Initial state: Email Address selected; email field shown; no loading state (`forgot_password_screen.dart:31-32,143-168`).
- Switching tabs changes selected styling and swaps which input/validator is present (`forgot_password_screen.dart:143-176,223-261`).
- Email validation: `Email address is required` when blank; `Enter a valid email address` for invalid format (`auth_validators.dart:8-12`). Mobile validation: `Mobile number is required`; `Enter a valid 10-digit mobile number` (`auth_validators.dart:34-41`). Form validation is run on submit (`forgot_password_screen.dart:45-47`).
- Loading: `AuthPrimaryButton` shows spinner and disables itself while `_loading` (`forgot_password_screen.dart:51-57,177-184`; `auth_primary_button.dart:27-38,45-71`).
- Service failure: snackbar displays service message or `Failed to send reset code` (`forgot_password_screen.dart:59-65`). Default mock service's blank-identifier messages are `Email address is required.` or `Mobile number is required.` (`mock_auth_service.dart:109-117`); normal UI validation prevents a blank value reaching service.
- Success: navigates to OTP verification; no success message (`forgot_password_screen.dart:68-82`).
- Informational copy states the code expires in 10 minutes; the default mock service itself has no expiry implementation (`forgot_password_screen.dart:206-207`; `mock_auth_service.dart:155-169`).

## Displayed values

- Active request identifier is `.trim()` of the email or mobile controller according to `_isEmail` (`forgot_password_screen.dart:49-53`).
- OTP contact display is the trimmed email unchanged, or mobile formatted by `AuthValidators.formatMobileDisplay` (`forgot_password_screen.dart:73-76`; formatter at `auth_validators.dart:46-53`).
- OTP route purpose is always `OtpPurpose.passwordReset`; raw identifier and email/mobile boolean are also passed through (`forgot_password_screen.dart:75-81`).

## Style with meaning

- Selected/unselected tabs differ by surface elevation, color, and label weight (`forgot_password_screen.dart:223-261`); selection must remain distinguishable.
- Error validation appears under active input through `TextFormField` validator; request error uses red snackbar (`forgot_password_screen.dart:59-65,160-176`; `AuthTextField`, `auth_text_field.dart:53-113`).
- Informational notice is differentiated as informational (`forgot_password_screen.dart:188-214`).
- Palette may change, but selected mode, validation/request errors, loading/disabled, and informational notice must remain distinct.

## Keyboard and focus

- Email uses email keyboard; mobile uses phone keyboard (`forgot_password_screen.dart:160-176`).
- Shared `AuthTextField` has no explicit autofocus. No explicit text action or Enter submission callback is set (`auth_text_field.dart:7-21,53-87`).
- Scroll view dismisses keyboard on drag (`forgot_password_screen.dart:88-97`).
- No explicit Escape handler or custom focus traversal is defined. Tab chips/buttons use Material/InkWell interaction defaults.

## Responsive

- `SafeArea` and `SingleChildScrollView` contain the form and dismiss keyboard on drag (`forgot_password_screen.dart:86-97`).
- No breakpoint or alternate layout is defined.

## Risk notes

- Keep `_isEmail` coupled to selected tab, active field, validator, `isEmail` argument, and contact display formatting (`forgot_password_screen.dart:31-32,49-56,143-176,73-81`).
- Form key and validation must remain attached to the active field; changing the conditional field or form hierarchy changes submit validation (`forgot_password_screen.dart:25,45-47,89-95`).
- Default reset-code implementation is mock, and reset OTP route uses password-reset purpose (`forgot_password_screen.dart:35-40,68-82`; mock method `mock_auth_service.dart:109-126`).
