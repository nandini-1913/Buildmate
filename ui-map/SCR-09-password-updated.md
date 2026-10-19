# SCR-09 — Password updated

- Route: `/password-updated` (`AppRoutes.passwordUpdated`)
- Source: [password_updated_screen.dart](../lib/features/auth/presentation/screens/password_updated_screen.dart) — 82 lines; [password_success_illustration.dart](../lib/features/auth/presentation/widgets/password_success_illustration.dart) — 111 lines
- Purpose: Confirm password-reset completion and provide a route back to login.

## Data

- Screen open: no data load or API call; the screen has no arguments.
- `Go to Login`: clears the route stack and navigates to `/login` (`password_updated_screen.dart:62-69`).
- No data is sent.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| PWD-VIS-01 | Success illustration | No visible text | Static custom-painted shield/check illustration (`password_updated_screen.dart:27-30`; `password_success_illustration.dart:5-16`) | Always | N | Y |
| PWD-VIS-02 | Success icon | No visible text (check-circle icon) | Decorative confirmation icon (`password_updated_screen.dart:31-46`) | Always | N | Y |
| PWD-TXT-01 | Status heading | `Password Updated` then `Successfully` (line break between) | Static success heading (`password_updated_screen.dart:49-53`) | Always | N | Y |
| PWD-TXT-02 | Supporting text | `Your password has been changed successfully. You can now sign in with your new password.` | Static success explanation (`password_updated_screen.dart:55-60`) | Always | N | Y |
| PWD-BTN-01 | Primary button | `Go to Login` (login icon) | Clears route stack and navigates to `/login` (`password_updated_screen.dart:62-69`) | Always enabled | Y — commits the return-to-login navigation | Y |
| PWD-TXT-03 | Footer/security label | `SHIVANI CONSTRUCTIONS · SECURE ✓` | Static label (`password_updated_screen.dart:72-75`) | Always | N | Y |

## States and messages

- The screen always renders its password-success confirmation; there are no loading, empty, error, validation, or confirmation-dialog states (`password_updated_screen.dart:17-78`).
- The heading is `Password Updated\nSuccessfully` in source; the line break is part of the displayed text (`password_updated_screen.dart:49-53`).

## Displayed values

- No computed/formatted user values. All text is static.

## Style with meaning

- The shield/check illustration, check-circle, success heading, and secure footer encode completion/success (`password_updated_screen.dart:31-75`; illustration painter `password_success_illustration.dart:19-111`). Palette may change, but success must remain distinguishable.

## Keyboard and focus

- No text input or keyboard handler.
- No explicit autofocus, Escape handler, or focus traversal order.
- Primary button uses shared Material pressed feedback; no custom hover state.

## Responsive

- `SafeArea` and `SingleChildScrollView`; no breakpoint or alternate layout (`password_updated_screen.dart:20-28`).
- Illustration uses a fixed 200 × 180 logical-pixel canvas (`password_success_illustration.dart:9-13`).

## Risk notes

- Preserve the button's `pushNamedAndRemoveUntil` behavior; it removes prior routes and opens login (`password_updated_screen.dart:64-68`).
- Illustration/icon are status meaning, not interactive controls.
