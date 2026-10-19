# SCR-30 — Notifications placeholder

- **Route:** `/notifications`.
- **Files:** `lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart` (99 lines); `lib/core/routes/app_router.dart` (300); `lib/core/routes/app_routes.dart` (201); entry point `lib/features/home/presentation/widgets/home_app_bar.dart` (169) and `lib/features/home/presentation/screens/home_dashboard_screen.dart` (304).
- **Purpose:** Standalone placeholder stating that alerts and enquiry updates are a future feature.
- **Line-count convention:** physical source lines from the files listed above.

## Data

- No API method/path, local data load, controller subscription, or screen-specific state is present in the placeholder (`feature_placeholder_screen.dart:72-99`; route construction `app_router.dart:215-222`).
- The Home notification icon routes to `AppRoutes.notifications` (`home_dashboard_screen.dart:115`; `app_routes.dart:40`).
- The Home header's notification badge defaults to `notificationCount = 3`, displays only when count is greater than zero, and formats values over 99 as `99+` (`home_app_bar.dart:19,127-145`). This badge belongs to the entry point, not the notifications screen.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect; evidence) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| NTF-APP-01 | App bar title | `Notifications` | Title supplied to `StandalonePlaceholderScreen`; Flutter `AppBar` displays it (`app_router.dart:215-222`; `feature_placeholder_screen.dart:85-95`). | On `/notifications`. | N | Y |
| NTF-BTN-01 | App bar back affordance | No explicit app-defined text; default `AppBar` leading behavior | The `Scaffold` uses an `AppBar` without an explicit leading widget. Back handling/tooltip is framework-provided, not customized here (`feature_placeholder_screen.dart:81-88`). | Framework determines from navigation state. | N | ASK |
| NTF-ICO-01 | Decorative icon | Notifications icon; no text | The route passes `Icons.notifications_rounded` to the generic placeholder, which displays it in a non-interactive `Container` (`app_router.dart:218-220`; `feature_placeholder_screen.dart:35-43`). | Always on this route. | N | Y |
| NTF-TXT-01 | Body heading | `Notifications` | `FeaturePlaceholderScreen` displays its `title` parameter as the body heading (`app_router.dart:218`; `feature_placeholder_screen.dart:46`). | Always. | N | Y |
| NTF-TXT-02 | Body subtitle | `Alerts and enquiry updates.` | Static subtitle parameter displayed below the heading (`app_router.dart:219`; `feature_placeholder_screen.dart:48`). | Always. | N | Y |

## States and messages

- The route always displays the same placeholder heading, subtitle, and icon; no loading, empty, error, success, validation, confirmation, or notification-list state is implemented (`app_router.dart:215-222`; `feature_placeholder_screen.dart:11-68`).
- Back navigation is supplied by the framework AppBar; no custom back handler or message is defined (`feature_placeholder_screen.dart:81-88`).

## Displayed values

- There are no computed or formatted values in the notifications body.
- On the Home entry point only: badge is hidden at count 0, shows the decimal count for 1–99, and shows `99+` above 99; default count is 3 (`home_app_bar.dart:19,127-145`).

## Style with meaning

- The icon and subtitle identify the placeholder; no color, badge, or style encodes a notification's read/unread or severity state in this screen.

## Keyboard and focus

- No inputs, explicit autofocus, keyboard shortcuts, or custom focus order are defined.
- The framework AppBar provides back navigation when applicable; there are no screen-defined Enter/Escape handlers.

## Responsive

- Body is wrapped in `SafeArea` and `SingleChildScrollView`, with fixed design-system padding; no screen-width breakpoint or alternate layout is defined (`feature_placeholder_screen.dart:28-32`).

## Risk notes

- The body is a shared `FeaturePlaceholderScreen`; its title, subtitle and icon are constructor inputs. Keep the notifications route's exact values intact when redesigning this route (`app_router.dart:215-222`; `feature_placeholder_screen.dart:11-24,35-49`).
- There is no notification feature logic behind this route. Adding list interactions, API requests, unread state, or altering the Home badge behavior would change functionality, not just appearance.
