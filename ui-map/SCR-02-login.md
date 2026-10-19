# SCR-02 — Login

- Route: `/login` (`AppRoutes.login`)
- Source: [login_screen.dart](../lib/features/auth/presentation/screens/login_screen.dart) — 229 lines; [login_flow_widgets.dart](../lib/features/auth/presentation/widgets/login_flow_widgets.dart) — shared login widgets; [auth_validators.dart](../lib/features/auth/presentation/widgets/auth_validators.dart); [auth_service.dart](../lib/services/auth_service.dart)
- Purpose: Collect a mobile number, start phone OTP sign-in/registration, or continue as a guest.

## Data

- Screen open: no API request is made by `LoginScreen`. The default auth implementation is `PhoneAuthService.instance`; its OTP action calls Firebase `FirebaseAuth.instance.verifyPhoneNumber` with `+91`-formatted mobile, a 60-second timeout, and optional resend token (`lib/services/auth_service.dart:70-82`). There is no app API path for this operation.
- `Send OTP`: calls `AuthService.sendOtp(mobileNumber: mobile)` where `mobile` is trimmed (`login_screen.dart:47-54`). Firebase may verify automatically or return a pending user for OTP verification (`lib/services/auth_service.dart:83-126`).
- If auto-verification returns a non-pending user, it stores the auth user in `SessionController` then clears the route stack into `/home-placeholder` (`login_screen.dart:64-76`).
- If OTP is pending, navigates to `/otp-verification` with formatted contact display, raw mobile, and `mobileLogin` or `registration` purpose depending on the selected mode (`login_screen.dart:79-84`).
- `Skip login`: calls `AuthService.continueAsGuest()` (`login_screen.dart:85-87`). The current `PhoneAuthService` returns an in-memory guest user (`lib/services/auth_service.dart:181-183`); on success, stores it in `SessionController` and clears the route stack into `/home-placeholder` (`login_screen.dart:88-94`). No network request is made in the current implementation.
- The `Login`/`Sign Up` selector changes `_isLogin`; the choice changes the intro string and OTP purpose but does not change the button or send a different service operation (`login_screen.dart:32,164-169,177-178,215-218`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| LGN-BTN-01 | Button | `Skip login` | `_skipLogin` → request guest result; on success save session and replace navigation stack with `/home-placeholder` (`login_screen.dart:86-94,126-144`) | Always enabled | N | Y |
| LGN-VIS-01 | Brand image | unknown (asset: `assets/images/branding/app logo.png`) | Static image in `LoginFlowIconBadge`; no handler (`login_screen.dart:146-151`; widget in `login_flow_widgets.dart:433-480`) | Always | N | Y |
| LGN-TXT-01 | Brand name | `Buildmate 24x7` | Static `loginAppDisplayName` (`login_screen.dart:154-162`; `login_flow_widgets.dart:629`) | Always | N | Y |
| LGN-TGL-01 | Segmented selector | `Login` | `_ModeToggleOption.onTap` → `onChanged(true)` → `_isLogin = true` (`login_flow_widgets.dart:128-188`; `login_screen.dart:177-178`) | Always; initially selected | Y — selected mode affects subsequent OTP purpose | Y |
| LGN-TGL-02 | Segmented selector | `Sign Up` | `_ModeToggleOption.onTap` → `onChanged(false)` → `_isLogin = false` (`login_flow_widgets.dart:128-188`; `login_screen.dart:177-178`) | Always; initially unselected | Y — selected mode affects subsequent OTP purpose | Y |
| LGN-TXT-02 | Mode-dependent intro | `Welcome back! Login to continue` / `Create an account to get started` | Text is selected from `_isLogin` (`login_screen.dart:164-172`) | First text for Login; second for Sign Up | N | Y |
| LGN-TXT-03 | Field label | `Mobile Number` | Label for the phone input (`login_screen.dart:180-188`) | Always | N | Y |
| LGN-IN-01 | Phone input | `+91` prefix; no hint text | Accepts phone-keyboard input, max length 10; `onChanged` rebuilds validation/button state (`login_screen.dart:189-194`; `login_flow_widgets.dart:240-333`) | Always | Y — value is sent when Send OTP is pressed | Y |
| LGN-TXT-04 | Helper text | `We'll send a 6-digit OTP to verify this number` | Static helper copy (`login_screen.dart:195-203`) | Always | N | Y |
| LGN-MSG-01 | Error message | `Could not send OTP.` (fallback); otherwise auth result message | `_continue` sets `_error` on an unsuccessful result; displayed below helper (`login_screen.dart:59-60,204-212`). Current service messages include `Sign-in is temporarily unavailable. Restart the app and try again.`, `Automatic verification failed.`, `Enter a valid 10-digit mobile number.`, `Too many attempts. Please wait and try again.`, and `Something went wrong. Please try again.` (`lib/services/auth_service.dart:30-45,72-74,91-106`) | Only after unsuccessful sendOtp result | N | Y |
| LGN-BTN-02 | Primary button | `Send OTP` | `_continue` → validate mobile, invoke `sendOtp`, show error or navigate/complete session as above (`login_screen.dart:42-84,213-220`) | Always shown; enabled when `AuthValidators.mobile` returns null; disabled while loading (`login_screen.dart:38-40,215-219`; `login_flow_widgets.dart:26-89`) | Y — follows chosen mode and current input | Y |
| LGN-STATE-01 | Button loading indicator | No visible text | Shown inside Send OTP button while `_loading`; button disabled (`login_screen.dart:51-56,215-219`; `login_flow_widgets.dart:35-88`) | During sendOtp request | N | Y |
| LGN-LINK-01 | Inline link | `Terms of Services & Privacy Policy` | `TapGestureRecognizer` handler is an empty function; no navigation/action currently occurs (`login_flow_widgets.dart:93-116`) | Always, in footer after `By continuing, you agree to our ` | N | Y |
| LGN-TXT-05 | Footer text | `By continuing, you agree to our ` | Static prefix preceding the inline link (`login_flow_widgets.dart:106-107`) | Always | N | Y |

## States and messages

- Initial state: `_isLogin = true`, no error, not loading, empty phone field; Send OTP disabled until mobile validation passes (`login_screen.dart:25-29,38-40`).
- Toggle: Login displays `Welcome back! Login to continue`; Sign Up displays `Create an account to get started`. The selected value controls OTP purpose (`login_screen.dart:164-178,79-84`).
- Invalid mobile: Send OTP is disabled. `AuthValidators.mobile` defines `Mobile number is required` and `Enter a valid 10-digit mobile number` (`auth_validators.dart:34-40`), but this screen does not attach a field validator or render those strings; tapping the disabled button cannot submit.
- Sending: `_loading` is true, `_error` is cleared, and the button shows a spinner (`login_screen.dart:51-57,215-219`; `login_flow_widgets.dart:70-87`).
- OTP send failure: displays the returned service message, or fallback `Could not send OTP.` (`login_screen.dart:59-60,204-212`). Current service copy also includes:
  - `Sign-in is temporarily unavailable. Restart the app and try again.` — Firebase is not ready (`lib/services/auth_service.dart:70-74`).
  - `Automatic verification failed.` — auto-verification has no user or throws (`lib/services/auth_service.dart:83-107`).
  - `Enter a valid 10-digit mobile number.`; `Too many attempts. Please wait and try again.`; `Something went wrong. Please try again.` — Firebase error mapping (`lib/services/auth_service.dart:30-45`).
- Guest success: no success message; stores guest session and navigates to shell. Guest failure has no displayed error (`login_screen.dart:85-94`).
- OTP success: no success message; auto-verification routes to shell; pending verification routes to OTP screen (`login_screen.dart:64-84`).
- If `sendOtp` throws rather than returning a result, no catch is present in this screen; loading is not explicitly cleared on that path (`login_screen.dart:42-60`).

## Displayed values

- Brand name: `loginAppDisplayName` returns `AppConstants.appName`, currently `Buildmate 24x7` (`login_screen.dart:154-162`; `login_flow_widgets.dart:629`; `lib/core/constants/app_constants.dart:3`).
- Phone display passed to OTP screen: `AuthValidators.formatMobileDisplay(mobile)`; removes non-digits, takes the last 10 digits if longer, and formats 10 digits as `+91 ` + first five + space + last five (`login_screen.dart:81-83`; `auth_validators.dart:46-53`).
- `_canContinue`: mobile validator removes whitespace, strips leading `+91`, removes nondigits, requires 10 digits matching `^[6-9]\d{9}$` (`login_screen.dart:38-40`; `auth_validators.dart:6,34-41`).
- OTP mode is `OtpPurpose.mobileLogin` for Login and `OtpPurpose.registration` for Sign Up (`login_screen.dart:79-84`).
- Firebase service converts submitted mobile to E.164 `+91` form and uses a 60-second phone-verification timeout (`lib/services/auth_service.dart:48-54,79-82`).

## Style with meaning

- Selected Login/Sign Up segment is communicated through the sliding pill and text treatment (`login_flow_widgets.dart:128-188`); selected state must remain distinguishable.
- Focused phone input uses accent border/shadow; unfocused input uses field border (`login_flow_widgets.dart:240-285`).
- Send OTP enabled/disabled and loading appearances communicate validation/request state (`login_flow_widgets.dart:35-89`). Palette may change, but states must remain distinguishable.
- Error message uses the error color (`login_screen.dart:204-211`).

## Keyboard and focus

- Phone field uses `TextInputType.phone`, max length 10; no explicit autofocus or `onSubmitted`/Enter submit handler is set (`login_flow_widgets.dart:240-333`).
- Dragging the scroll view dismisses the keyboard (`login_screen.dart:109-111`).
- No explicit Escape behavior or custom focus traversal order is defined.
- Buttons use Flutter Material tap/disabled/loading states; focused field styling is present. Hover behavior is platform/default; no custom hover handler is defined.

## Responsive

- Screen content is a `SingleChildScrollView` with `keyboardDismissBehavior: onDrag`, in `SafeArea` (`login_screen.dart:104-115`).
- Main column stretches to available width; no explicit breakpoint is defined (`login_screen.dart:117-124`).
- No responsive mode/layout branching is defined.

## Risk notes

- Preserve the selected mode’s relation to the OTP purpose and intro text; changing the layout must not detach either selector callback from its corresponding segment (`login_screen.dart:79-84,164-178`).
- Preserve phone input controller wiring, max length, onChanged rebuild, validator gating, and current field value passed into `_continue` (`login_screen.dart:25,38-40,47-54,189-194`; `login_flow_widgets.dart:240-333`).
- The terms/privacy link is currently a no-op. Giving it a destination would change behavior.
- `_continue` has no exception handler around `sendOtp`; avoid changing its loading/navigation ordering without owner approval.
- The logo is an asset; its embedded text/content is unknown from source.
