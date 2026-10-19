# SCR-28 — Wishlist placeholder

- Route: `/wishlist` (`AppRoutes.wishlist`)
- Source files: [app_router.dart](../lib/core/routes/app_router.dart) (route at lines 198-206); [feature_placeholder_screen.dart](../lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart) (99 lines)
- Purpose: Tell users to use the Wishlist tab; the standalone route contains no wishlist content or actions.

## Data

- Router creates `StandalonePlaceholderScreen` with title `Wishlist`, subtitle `Use the Wishlist tab in bottom navigation.`, and favorite icon (`lib/core/routes/app_router.dart:198-206`).
- No API, wishlist state read, or route argument is used on this standalone route.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| WLP-BTN-01 | App-bar back button | No visible text (default back arrow when navigator can pop) | Flutter `AppBar` implicit leading navigation (`lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart:68-77`) | Route can pop | N | Y |
| WLP-TXT-01 | App-bar title | `Wishlist` | Static router title (`lib/core/routes/app_router.dart:198-205`; placeholder scaffold `feature_placeholder_screen.dart:68-77`) | Always | N | Y |
| WLP-IMG-01 | Placeholder icon | No text (favorite icon) | Display-only `Icons.favorite_rounded` in icon tile (`lib/core/routes/app_router.dart:200-204`; `feature_placeholder_screen.dart:30-37`) | Always | N | Y |
| WLP-TXT-02 | Placeholder heading | `Wishlist` | Static router title passed to body (`lib/core/routes/app_router.dart:200-205`; `feature_placeholder_screen.dart:38-43`) | Always | N | Y |
| WLP-TXT-03 | Placeholder description | `Use the Wishlist tab in bottom navigation.` | Static placeholder guidance; this route has no product list (`lib/core/routes/app_router.dart:200-205`; `feature_placeholder_screen.dart:44-45`) | Always | N | Y |

## States and messages

- Only the static placeholder state is implemented.
- No loading, empty, error, success, validation, confirmation, upload, or passcode state is defined.

## Displayed values

- Title, subtitle, and icon are static router arguments (`lib/core/routes/app_router.dart:198-206`).

## Style with meaning

- Favorite icon uses the primary-container placeholder treatment; it does not indicate a selected/saved item on this route (`feature_placeholder_screen.dart:30-37`).

## Keyboard and focus

- No text input, keyboard handler, autofocus, custom focus order, or explicit Escape behavior is defined.

## Responsive

- Shared placeholder body is safe-area wrapped and vertically scrollable; no breakpoint is defined (`feature_placeholder_screen.dart:27-61`).

## Risk notes

- This standalone route is a placeholder, distinct from wishlist buttons/local state elsewhere and any wishlist tab body (`lib/core/routes/app_router.dart:198-206`).
- The shared placeholder component supports optional sign-out, but this route does not set `showSignOut` (`feature_placeholder_screen.dart:10-17,63-99`).
