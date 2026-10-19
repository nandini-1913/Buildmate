# SCR-27 — Quotation review

- Routes: `/quotation` and `/quotation-review` (`AppRoutes.quotation`, `AppRoutes.quotationReview`)
- Source files: [cart_screen.dart](../lib/features/catalog/presentation/screens/cart_screen.dart) (1276 lines; quotation review at lines 1144-1276); [quotation_controller.dart](../lib/core/state/quotation_controller.dart); [catalog_models.dart](../lib/features/catalog/domain/models/catalog_models.dart)
- Purpose: Review cart materials, capture customer name/phone/notes, and create a local pending quotation enquiry.

## Data

- Both quotation routes resolve to `QuotationReviewScreen` (`lib/core/routes/app_router.dart:195-197`).
- Screen reads cart items and current `SessionController.user`. Name and phone text controllers are seeded once from user profile (`cart_screen.dart:1151-1178`).
- `Submit Enquiry` calls local `QuotationController.createFromCart` with cart items, requester ID, trimmed customer name fallback to profile name, trimmed phone, and trimmed notes (`cart_screen.dart:1248-1267`).
- Quotation controller inserts an in-memory pending quotation with generated IDs/date; no API request is made (`lib/core/state/quotation_controller.dart:11-52`).
- Submission displays exact snackbar and pops the current screen. It does not clear the cart (`cart_screen.dart:1248-1274`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| QR-BTN-01 | App-bar back button | No visible text (default back arrow when navigator can pop) | Flutter `AppBar` implicit leading navigation (`cart_screen.dart:1182-1188`) | Route can pop | N | Y |
| QR-TXT-01 | App-bar title | `Quotation Review` | Static app-bar title (`cart_screen.dart:1182-1188`) | Always | N | Y |
| QR-STATE-01 | Empty-cart state | `Add materials to cart first.` | Replaces quotation form (`cart_screen.dart:1186-1188`) | Cart empty | N | Y |
| QR-TXT-02 | Section heading | `Materials` | Labels cart line list (`cart_screen.dart:1190-1194`) | Cart non-empty | N | Y |
| QR-ROW-01 | Material row | Dynamic product name; `${brandName} · ${quantity} ${unit}`; `₹${item.totalPrice.toStringAsFixed(0)}` | Display-only cart material/quantity and line total (`cart_screen.dart:1195-1210`) | One row per cart item | Y — keep line details and total paired | Y |
| QR-TXT-03 | Total display | `Estimated Total`; `₹${cart.estimatedTotal.toStringAsFixed(0)}` | Displays cart estimated total (`cart_screen.dart:1211-1225`) | Cart non-empty | N | Y |
| QR-TXT-04 | Section heading | `Customer information` | Labels customer fields (`cart_screen.dart:1227-1231`) | Cart non-empty | N | Y |
| QR-IN-01 | Text input | `Name` | Prefilled with session user name; submitted value is trimmed, falling back to session name if blank (`cart_screen.dart:1158-1164,1232-1235,1248-1260`) | Cart non-empty | N | Y |
| QR-IN-02 | Phone input | `Phone` | Prefilled with session user phone or empty string; phone keyboard; submitted value is trimmed (`cart_screen.dart:1158-1164,1236-1241,1248-1263`) | Cart non-empty | N | Y |
| QR-IN-03 | Multiline text input | `Notes (optional)` | Captures optional notes, trimmed when submitted (`cart_screen.dart:1242-1247,1260-1264`) | Cart non-empty | N | Y |
| QR-ACT-01 | Button | `Submit Enquiry` | Creates local quotation draft with current cart/user/fields, shows snackbar and pops route (`cart_screen.dart:1248-1274`; `quotation_controller.dart:26-52`) | Cart non-empty; no validation or disabled state | N | Y |
| QR-MSG-01 | Snackbar | `Quotation enquiry saved locally (pending — no rewards yet)` | Floating confirmation (`cart_screen.dart:1260-1271`) | Submit button tapped | N | Y |

## States and messages

- Empty cart: `Add materials to cart first.` and no form/button (`cart_screen.dart:1186-1188`).
- Non-empty cart: material lines, estimated total, customer fields, and Submit Enquiry button.
- Submit creates a pending in-memory quotation and shows `Quotation enquiry saved locally (pending — no rewards yet)` before popping the screen (`cart_screen.dart:1248-1274`; `quotation_controller.dart:26-52`).
- No loading indicator, validation, error, confirmation, API response, upload, or passcode state is defined.

## Displayed values

- Name/phone fields seed from `SessionController.user.name` and `.phone ?? ''`; blank submitted name falls back to current profile name (`cart_screen.dart:1158-1164,1250-1260`).
- Line subtitle uses variant brand, quantity, and unit. Line price is `item.totalPrice` formatted with `toStringAsFixed(0)` and prefixed with `₹` (`cart_screen.dart:1195-1210`).
- Estimated total is `cart.estimatedTotal`, which equals cart subtotal (`cart_screen.dart:1211-1225`; `lib/core/state/cart_controller.dart:39-45`).
- Quotation controller assigns ID `qt-<current milliseconds>`, display ID `QT-2026-<sequence padded to 3>`, current creation time, and pending status (`lib/core/state/quotation_controller.dart:26-52`).

## Style with meaning

- No selection or business-status color coding is displayed.
- Empty state replaces all form content; preserve state distinction and exact copy.

## Keyboard and focus

- Name, phone, and notes use plain `TextField`s with no explicit autofocus, action, validation, input formatter, or focus chain (`cart_screen.dart:1232-1247`).
- Phone field uses phone keyboard. Notes allows three lines (`cart_screen.dart:1236-1247`).
- No Escape handler or custom focus order is defined.

## Responsive

- The non-empty form is a vertically scrolling `ListView` with fixed outer padding; no breakpoint is defined (`cart_screen.dart:1186-1247`).

## Risk notes

- Route aliases intentionally map to the same screen (`lib/core/routes/app_router.dart:195-197`).
- User profile seeds input once in `didChangeDependencies`; do not reseed over edits on subsequent dependency changes (`cart_screen.dart:1158-1165`).
- Submission uses trimmed fields and fallback name, saves a pending local draft, then pops; preserve all four effects and do not clear cart (`cart_screen.dart:1248-1274`; `quotation_controller.dart:26-52`).
- `cart_screen.dart` contains both CartScreen and QuotationReviewScreen; keep this contract scoped to lines 1144 onward.
