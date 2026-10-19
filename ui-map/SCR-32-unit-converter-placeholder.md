# SCR-32 — Unit converter placeholder

- **Route:** `/unit-converter`.
- **Files:** `lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart` (99 lines); `lib/core/routes/app_router.dart` (300); `lib/core/routes/app_routes.dart` (201).
- **Purpose:** Display a placeholder for the not-yet-implemented unit converter.
- **Line-count convention:** physical source lines counted from the files listed above.

## Data

- No API call, local data load, controller subscription, or feature-specific state is present (`feature_placeholder_screen.dart:72-99`; route construction `app_router.dart:226-233`).
- The route supplies title `Unit Converter`, subtitle `Convert units across standards (coming soon).`, and icon `Icons.swap_horiz_rounded` (`app_router.dart:226-233`).
- Home and catalog mock feature entries are titled `Unit Converter`, have subtitle `Convert units across standards`, and use the named route in catalog mock data (`home_mock_data.dart:275-276`; `catalog_mock_data.dart:474-477`). The route is `/unit-converter` (`app_routes.dart:42`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect; evidence) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| UCV-APP-01 | App bar title | `Unit Converter` | Title passed to `StandalonePlaceholderScreen`; shown by its `AppBar` (`app_router.dart:226-233`; `feature_placeholder_screen.dart:81-90`). | On `/unit-converter`. | N | Y |
| UCV-BTN-01 | App bar back affordance | No explicit app-defined visible text; default `AppBar` leading behavior | `AppBar` has no explicit leading widget or callback; framework behavior applies (`feature_placeholder_screen.dart:81-88`). | Framework determines from navigation state. | N | ASK |
| UCV-ICO-01 | Decorative icon | Swap-horiz icon; no text | Route passes `Icons.swap_horiz_rounded` to shared placeholder; displayed as a non-interactive `Icon` (`app_router.dart:230`; `feature_placeholder_screen.dart:35-43`). | Always on this route. | N | Y |
| UCV-TXT-01 | Body heading | `Unit Converter` | Shared placeholder displays its title argument as body heading (`app_router.dart:229`; `feature_placeholder_screen.dart:46`). | Always. | N | Y |
| UCV-TXT-02 | Body subtitle | `Convert units across standards (coming soon).` | Shared placeholder displays its subtitle argument below heading (`app_router.dart:230`; `feature_placeholder_screen.dart:48`). | Always. | N | Y |

## States and messages

- The route always displays the same title, subtitle and icon. No converter inputs, conversion result, loading/error/success/empty state, validation, confirmation, or sign-out button is implemented (`app_router.dart:226-233`; `feature_placeholder_screen.dart:11-68,72-99`).
- Back navigation is framework-provided through the app bar; no custom back handler/message is defined (`feature_placeholder_screen.dart:81-88`).

## Displayed values

- No computed or formatted values are displayed.

## Style with meaning

- The swap-horiz icon indicates the placeholder's topic. No state/status color or conditional visual encoding is used in this screen.

## Keyboard and focus

- No inputs, autofocus, keyboard shortcuts, or custom focus order are defined.
- No custom Enter/Escape handlers are defined; the framework app bar provides back navigation when applicable.

## Responsive

- Shared body is wrapped in `SafeArea` and `SingleChildScrollView` with design-system padding; no width breakpoint or alternate layout is defined (`feature_placeholder_screen.dart:28-32`).

## Risk notes

- This is a shared `StandalonePlaceholderScreen` configured by route constructor arguments. Keep the exact route-specific title, subtitle, and icon when changing appearance (`app_router.dart:226-233`; `feature_placeholder_screen.dart:11-24,35-49`).
- No conversion behavior exists behind this route. Adding unit input, conversion formulas, state, or API calls changes functionality and is outside the visual-only contract.
