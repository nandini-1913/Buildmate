# SCR-33 — Quantity estimator placeholder

- **Route:** `/quantity-estimator`.
- **Files:** `lib/features/placeholders/presentation/screens/feature_placeholder_screen.dart` (99 lines); `lib/core/routes/app_router.dart` (300); `lib/core/routes/app_routes.dart` (201).
- **Purpose:** Display a placeholder for the not-yet-implemented quantity estimator.
- **Line-count convention:** physical source lines counted from the files listed above.

## Data

- No API call, local data load, controller subscription, or feature-specific state is present (`feature_placeholder_screen.dart:72-99`; route construction `app_router.dart:235-242`).
- The route supplies title `Quantity Estimator`, subtitle `Project-based material planning (coming soon).`, and icon `Icons.architecture_rounded` (`app_router.dart:235-242`).
- The route constant is `/quantity-estimator` (`app_routes.dart:43`). Home mock data contains a tile titled `Quantity Estimator` with subtitle `Project-based material planning`; catalog mock data also has that title/subtitle, but its `routeName` is `AppRoutes.search`, not this estimator route (`home_mock_data.dart:281-286`; `catalog_mock_data.dart:481-485`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect; evidence) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| QES-APP-01 | App bar title | `Quantity Estimator` | Title passed to `StandalonePlaceholderScreen`; shown by its `AppBar` (`app_router.dart:235-242`; `feature_placeholder_screen.dart:81-90`). | On `/quantity-estimator`. | N | Y |
| QES-BTN-01 | App bar back affordance | No explicit app-defined visible text; default `AppBar` leading behavior | `AppBar` has no explicit leading widget or callback; framework behavior applies (`feature_placeholder_screen.dart:81-88`). | Framework determines from navigation state. | N | ASK |
| QES-ICO-01 | Decorative icon | Architecture icon; no text | Route passes `Icons.architecture_rounded` to shared placeholder; displayed as a non-interactive `Icon` (`app_router.dart:240`; `feature_placeholder_screen.dart:35-43`). | Always on this route. | N | Y |
| QES-TXT-01 | Body heading | `Quantity Estimator` | Shared placeholder displays its title argument as body heading (`app_router.dart:238`; `feature_placeholder_screen.dart:46`). | Always. | N | Y |
| QES-TXT-02 | Body subtitle | `Project-based material planning (coming soon).` | Shared placeholder displays its subtitle argument below heading (`app_router.dart:239`; `feature_placeholder_screen.dart:48`). | Always. | N | Y |

## States and messages

- The route always displays the same title, subtitle, and icon. No quantity inputs, estimates, loading/error/success/empty state, validation, confirmation, or sign-out button is implemented (`app_router.dart:235-242`; `feature_placeholder_screen.dart:11-68,72-99`).
- Back navigation is framework-provided through the app bar; no custom back handler/message is defined (`feature_placeholder_screen.dart:81-88`).

## Displayed values

- No computed or formatted values are displayed.

## Style with meaning

- The architecture icon indicates the placeholder topic. No state/status color or conditional visual encoding is used in this screen.

## Keyboard and focus

- No inputs, autofocus, keyboard shortcuts, or custom focus order are defined.
- No custom Enter/Escape handlers are defined; the framework app bar provides back navigation when applicable.

## Responsive

- Shared body is wrapped in `SafeArea` and `SingleChildScrollView` with design-system padding; no width breakpoint or alternate layout is defined (`feature_placeholder_screen.dart:28-32`).

## Risk notes

- This is a shared `StandalonePlaceholderScreen` configured by route constructor arguments. Keep the exact route-specific title, subtitle, and icon when changing appearance (`app_router.dart:235-242`; `feature_placeholder_screen.dart:11-24,35-49`).
- No estimator behavior exists behind this route. Adding quantity inputs, formulas, state, or API calls changes functionality and is outside the visual-only contract.
- The catalog mock tile's `routeName` currently points to search; do not silently change that navigation while applying this screen's visual redesign (`catalog_mock_data.dart:481-485`).
