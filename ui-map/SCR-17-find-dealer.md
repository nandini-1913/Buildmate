# SCR-17 — Find dealer placeholder

- Route: `/dealers` (`AppRoutes.dealers`)
- Source files: [app_router.dart](../lib/core/routes/app_router.dart) (dealer route at lines 154-162); [feature_placeholder_screen.dart](../lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart) (99 lines)
- Purpose: Show the standalone Find Dealer placeholder, with no dealer search or location behavior implemented.

## Data

- Route constructs `StandalonePlaceholderScreen` with static title, subtitle, and storefront icon (`lib/core/routes/app_router.dart:154-162`).
- No API call, local data load, or route argument is used.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| DEAL-BTN-01 | App-bar back button | No visible text (default back arrow when navigator can pop) | Flutter `AppBar` implicit leading navigation (`lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart:68-77`) | Standalone route when it can pop | N | Y |
| DEAL-TXT-01 | App-bar title | `Find Dealer` | Static title supplied by route (`lib/core/routes/app_router.dart:154-161`; `feature_placeholder_screen.dart:68-77`) | Always | N | Y |
| DEAL-IMG-01 | Placeholder icon | No text (storefront icon) | Display-only `Icons.storefront_rounded` in a primary-container icon tile (`lib/core/routes/app_router.dart:156-160`; `feature_placeholder_screen.dart:30-37`) | Always | N | Y |
| DEAL-TXT-02 | Placeholder heading | `Find Dealer` | Static heading supplied to placeholder body (`lib/core/routes/app_router.dart:156-160`; `feature_placeholder_screen.dart:38-43`) | Always | N | Y |
| DEAL-TXT-03 | Placeholder description | `Locate trusted dealers near you.` | Static supporting text; no dealer lookup is connected (`lib/core/routes/app_router.dart:156-160`; `feature_placeholder_screen.dart:44-45`) | Always | N | Y |

## States and messages

- Only the static placeholder state is implemented.
- No loading, empty, error, success, validation, confirmation, upload, or passcode state is defined.

## Displayed values

- Title, subtitle, and icon are constant router arguments; no computed values or formatted data are displayed (`lib/core/routes/app_router.dart:154-162`).

## Style with meaning

- Icon tile uses primary-container styling; no business state is encoded by color or style (`lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart:30-37`).

## Keyboard and focus

- No text input, keyboard handler, autofocus, custom focus order, or explicit Escape behavior is defined.

## Responsive

- Placeholder body uses `SafeArea` and a vertically scrollable column with fixed spacing; no breakpoint is defined (`lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart:27-61`).

## Risk notes

- Route copy and icon are supplied by `AppRouter`; keep the `/dealers` route distinct from other placeholder routes (`lib/core/routes/app_router.dart:154-162`).
- The shared placeholder component supports optional sign-out, but this route uses `StandalonePlaceholderScreen`, which does not set `showSignOut` (`lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart:10-17,63-99`).
