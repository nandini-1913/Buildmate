# SCR-01 — Splash

- Route: `/` (`AppRoutes.splash`)
- Source: [splash_screen.dart](../lib/features/auth/presentation/screens/splash_screen.dart) — 95 lines; [app_router.dart](../lib/core/routes/app_router.dart), [app_routes.dart](../lib/core/routes/app_routes.dart)
- Purpose: Show app branding and loading feedback, then replace the route with the login screen or main shell according to the restored session.

## Data

- No API method/path is called by this screen (`splash_screen.dart:25-35`).
- Before the app displays its initial route, startup awaits `SessionController.restore()` and `syncFromFirebase()` (`lib/main.dart:21-23`). The splash reads `SessionController.isLoggedIn` after a 2,200 ms delay (`splash_screen.dart:25-34`; `lib/core/constants/app_constants.dart:7`).
- No user action sends data.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| SPL-VIS-01 | Brand image | unknown (asset: `assets/images/branding/app logo.png`) | Static image; no handler (`splash_screen.dart:52-56`) | Always | N | Y |
| SPL-TXT-01 | Tagline | `Everything for Construction. One Trusted Platform.` | Static rich text; prefix and emphasis come from constants (`splash_screen.dart:58-73`; `lib/core/constants/app_constants.dart:4-5`) | Always | N | Y |
| SPL-STATE-01 | Loading indicator | No visible text | `CircularProgressIndicator`; no handler (`splash_screen.dart:75-83`) | Always during splash | N | Y |
| SPL-TXT-02 | Version label | `v1.0.0` | Static value from `AppConstants.appVersion` (`splash_screen.dart:85-88`; `lib/core/constants/app_constants.dart:3`) | Always | N | Y |

## States and messages

- Splash/loading: branding, tagline, progress indicator, and version are built immediately (`splash_screen.dart:41-89`).
- After `AppConstants.splashDuration` (2,200 ms), if the widget remains mounted, replace the splash route with `/home-placeholder` when `isLoggedIn` is true, otherwise `/login` (`splash_screen.dart:25-35`; routes declared in `lib/core/routes/app_routes.dart:5,14`). No textual loading, error, success, or confirmation message is defined here.
- Other states/messages: none defined in this screen.

## Displayed values

- Tagline is the exact concatenation of `taglinePrefix`, one literal space, and `taglineEmphasis`: `Everything for Construction. One Trusted Platform.` (`splash_screen.dart:62-64`; constants at `lib/core/constants/app_constants.dart:4-5`).
- Version is `AppConstants.appVersion`, currently `v1.0.0` (`splash_screen.dart:85-87`; `lib/core/constants/app_constants.dart:3`).
- Loading duration is 2,200 ms (`splash_screen.dart:26`; `lib/core/constants/app_constants.dart:7`).

## Style with meaning

- The progress indicator represents the timed splash/loading state; its presence and role must remain distinguishable. Palette and styling may change (`splash_screen.dart:75-83`).
- No status, error, selected, or disabled colour state is defined here.

## Keyboard and focus

- No input or keyboard handler is defined.
- No explicit autofocus or focus traversal order is defined.
- Scrollable body is inside `SafeArea` (`splash_screen.dart:43-48`); hover/pressed/disabled control feedback does not apply.

## Responsive

- `SafeArea` and `SingleChildScrollView` provide insets and scrolling (`splash_screen.dart:43-48`).
- No breakpoint is defined. Logo width is fixed at 220 logical pixels and the progress indicator is sized using `AppSpacing.space8` (`splash_screen.dart:52-55,75-77`).

## Risk notes

- Preserve the `initState` → delayed `_navigate()` lifecycle, mounted check, session-dependent destination, and `pushReplacementNamed`; changing these changes startup/navigation behavior (`splash_screen.dart:18-35`).
- The brand image is an asset, so its embedded text/content cannot be established from this source alone.
