# SCR-08 — Reset password

- Route: `/reset-password` (`AppRoutes.resetPassword`)
- Source: [reset_password_screen.dart](../lib/features/auth/presentation/screens/reset_password_screen.dart) — 155 lines; [auth_text_field.dart](../lib/features/auth/presentation/widgets/auth_text_field.dart); [auth_validators.dart](../lib/features/auth/presentation/widgets/auth_validators.dart); [mock_auth_service.dart](../lib/features/auth/services/mock_auth_service.dart)
- Purpose: Validate and submit a new password and confirmation for the identifier verified in the prior OTP step.

## Data

- Screen open: reads `ResetPasswordArgs.identifier` and `isEmail`; no API request is made by this screen (`reset_password_screen.dart:13-23`; args declared in `lib/core/routes/app_routes.dart:97-108`).
- Default service is `MockAuthService()`; optional `authService` can be injected (`reset_password_screen.dart:27-39`).
- `Update Password`: validates both form fields, then calls `resetPassword(identifier: args.identifier, newPassword: _passwordController.text)` (`reset_password_screen.dart:47-54`).
- Default mock service waits 900 ms and succeeds when password length is at least six; if shorter, returns `Password must be at least 6 characters.` (`mock_auth_service.dart:10,129-140`). No app API method/path is called. The production `PhoneAuthService` implementation returns `Password reset is not available.` (`lib/services/auth_service.dart:212-217`).
- On failure, show red snackbar with service message or fallback `Could not update password` (`reset_password_screen.dart:58-64`).
- On success, clear the navigation stack and navigate to `/password-updated` (`reset_password_screen.dart:67-70`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| RSP-BTN-01 | Back icon button | No visible text (arrow-back icon) | Pops current route (`reset_password_screen.dart:91-96`) | Always | N | Y |
| RSP-VIS-01 | Password icon | No visible text (password icon) | Decorative lock/password icon (`reset_password_screen.dart:97-112`) | Always | N | Y |
| RSP-TXT-01 | Heading | `Reset Password` | Static heading (`reset_password_screen.dart:114`) | Always | N | Y |
| RSP-TXT-02 | Instruction | `Create a new password for your Shivani Constructions account.` | Static supporting text (`reset_password_screen.dart:116-120`) | Always | N | Y |
| RSP-IN-01 | Password input | `New Password` | Writes `_passwordController`; obscured by default; `AuthValidators.password` validates (`reset_password_screen.dart:122-129`; `auth_text_field.dart:7-19,53-87`) | Always | Y — value is sent and compared on submit | Y |
| RSP-BTN-02 | Visibility icon button | No visible text; icon toggles between visibility and visibility-off | Toggles obscuring for New Password (`auth_text_field.dart:72-86`; used at `reset_password_screen.dart:122-129`) | Always alongside New Password input | N | Y |
| RSP-IN-02 | Password confirmation input | `Confirm New Password` | Writes `_confirmController`; obscured by default; validates non-empty and exact equality with New Password (`reset_password_screen.dart:131-140`; validator `auth_validators.dart:20-24`) | Always | Y — comparison and submit depend on New Password | Y |
| RSP-BTN-03 | Visibility icon button | No visible text; icon toggles between visibility and visibility-off | Toggles obscuring for Confirm New Password (`auth_text_field.dart:72-86`; used at `reset_password_screen.dart:131-140`) | Always alongside confirmation input | N | Y |
| RSP-BTN-04 | Primary button | `Update Password` (check-circle icon) | `_submit` → validate, invoke reset service, show failure snackbar or replace stack with `/password-updated` (`reset_password_screen.dart:47-70,143-148`) | Always; disabled while loading (`auth_primary_button.dart:27-64`) | Y — submits both fields | Y |
| RSP-STATE-01 | Loading indicator | No visible text | Replaces primary button child with spinner during service call (`reset_password_screen.dart:49-56,143-148`; `auth_primary_button.dart:45-62`) | During request | N | Y |
| RSP-MSG-01 | Error snackbar | Service result message or fallback `Could not update password` | Shown on unsuccessful reset result (`reset_password_screen.dart:58-64`) | Only after service failure | N | Y |

## States and messages

- Initial: both controllers are empty; passwords obscured; no loading/error message (`reset_password_screen.dart:27-33`; `auth_text_field.dart:25-41`).
- New Password validation: `Password is required`; `Password must be at least 6 characters` (`auth_validators.dart:15-18`).
- Confirmation validation: `Confirm your password`; `Passwords do not match` (`auth_validators.dart:20-24`).
- Loading: primary button disabled and shows spinner (`reset_password_screen.dart:49-56,143-148`; `auth_primary_button.dart:27-64`).
- Service failure: red snackbar contains service message or fallback `Could not update password` (`reset_password_screen.dart:58-64`). The default mock can return `Password must be at least 6 characters.` (`mock_auth_service.dart:129-140`); the default phone service returns `Password reset is not available.` (`lib/services/auth_service.dart:212-217`).
- Success: navigates to password-updated screen; no success message on this screen (`reset_password_screen.dart:67-70`).

## Displayed values

- `identifier` comes from `ResetPasswordArgs.identifier`; it is sent unchanged to service and is not displayed (`reset_password_screen.dart:50-53`).
- Password and confirmation are raw controller values; password validator requires length >= 6, confirmation must match exactly (`auth_validators.dart:15-24`).
- No computed values are displayed.

## Style with meaning

- Password masking/visibility icon state is meaningful and independently controlled for each field (`auth_text_field.dart:25-27,72-86`).
- Field focus and enabled state use shared `AuthTextField` styling (`auth_text_field.dart:54-111`).
- Validation/service errors, loading/disabled button states must remain distinguishable (`reset_password_screen.dart:58-64,143-148`).
- Palette may change; password visibility, errors, and request state may not be lost.

## Keyboard and focus

- Both fields use the shared `AuthTextField`; `obscureText: true`, visibility controls enabled, no explicit keyboard type or text action (`reset_password_screen.dart:122-140`; `auth_text_field.dart:7-19,53-87`).
- No autofocus or explicit Enter submit callback. Scroll view dismisses keyboard on drag (`reset_password_screen.dart:77-87`).
- No Escape handler or custom focus traversal order is defined.

## Responsive

- `SafeArea` and `SingleChildScrollView` wrap the form; keyboard dismissal is on drag (`reset_password_screen.dart:75-87`).
- No breakpoint or alternate layout is defined.

## Risk notes

- Preserve distinct visibility controllers: each toggle controls only its associated field (`auth_text_field.dart:25-27,72-86`; `reset_password_screen.dart:122-140`).
- Preserve form validation and confirm-password comparison before service invocation (`reset_password_screen.dart:47-54`; `auth_validators.dart:15-24`).
- Preserve `args.identifier` submission and stack replacement on success (`reset_password_screen.dart:50-53,67-70`).
- Default implementation is mock; changing which auth service is used changes behavior (`reset_password_screen.dart:35-39`).
