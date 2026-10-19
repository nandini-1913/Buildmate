# SCR-22 — Cart

- Route: `/cart` (`AppRoutes.cart`)
- Source files: [cart_screen.dart](../lib/features/catalog/presentation/screens/cart_screen.dart) (1276 lines; cart UI at lines 18-1142; quotation review begins at line 1144); [cart_controller.dart](../lib/core/state/cart_controller.dart); [catalog_models.dart](../lib/features/catalog/domain/models/catalog_models.dart)
- Purpose: Review and change cart items, apply/remove coupons, review totals, and proceed to address selection.

## Data

- Screen watches shared in-memory `CartController`; cart items, quantities, coupons, and totals do not trigger an API call here (`cart_screen.dart:98-168`; `lib/core/state/cart_controller.dart:18-174`).
- Item quantity changes call `increase`/`decrease`; removal calls `remove` and shows snackbar with `Undo`, which calls `restore(item, originalIndex)` (`cart_screen.dart:67-77,125-136`; `cart_controller.dart:119-174`).
- `Clear All` opens a confirmation dialog; confirmation calls `cart.clear()` (`cart_screen.dart:79-96`; `cart_controller.dart:167-171`).
- Coupon codes accepted are case-insensitive `BUILD10` and `FREESHIP`. `BUILD10` applies 10% subtotal discount; `FREESHIP` waives shipping. Coupon application updates local cart state (`lib/core/state/cart_controller.dart:4-15,51-84`).
- `Proceed to Address` pushes `/checkout/address` (`cart_screen.dart:96-97,1040-1078`).
- Empty-cart `Browse materials` pushes `/category-browse` without args (`cart_screen.dart:1123-1128`); generic route resolution is covered in SCR-13/SCR-14.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| CART-BTN-01 | Icon button | Tooltip `Back`; no visible text (back arrow) | Calls `Navigator.maybePop()` (`cart_screen.dart:211-219`) | Navigator can pop | N | Y |
| CART-IMG-01 | App logo | No text | Displays `assets/images/branding/app logo.png` (`cart_screen.dart:220-224`) | Always | N | Y |
| CART-TXT-01 | App name | `Buildmate 24x7` | `AppConstants.appName` (`cart_screen.dart:225-235`; `lib/core/constants/app_constants.dart:1-3`) | Always | N | Y |
| CART-TXT-02 | Checkout step count | `Step 1 of 4` | Derived from current-step constant 0 and four `_steps` (`cart_screen.dart:188-195,237-251`) | Cart non-empty | Y — fixed checkout step order | Y |
| CART-ACT-01 | Disabled icon button | Tooltip `Cart`; cart icon with optional badge | `onPressed: null`; badge shows total quantity, capped at `99+` (`cart_screen.dart:256-274`) | Always; badge only when count > 0 | N | Y |
| CART-TXT-03 | Checkout step labels | `1. Cart`; `2. Address`; `3. Payment`; `4. Confirm` | Display-only progress labels; current step is index 0 (`cart_screen.dart:188-195,278-318`) | Cart non-empty | Y — preserve step sequence | Y |
| CART-STATE-01 | Empty-cart icon and heading | No text (cart icon); `Your cart is empty` | Display-only empty state (`cart_screen.dart:1081-1111`) | `cart.isEmpty` | N | Y |
| CART-STATE-02 | Empty-cart description | `Add cement, bricks, steel and more to get started.` | Static empty-state guidance (`cart_screen.dart:1112-1120`) | `cart.isEmpty` | N | Y |
| CART-ACT-02 | Button | `Browse materials` | Pushes `/category-browse` with no arguments (`cart_screen.dart:1121-1128`) | `cart.isEmpty` | N | Y |
| CART-TXT-04 | Items heading | `Review Items (${cart.items.length})` | Shows number of cart rows, not total quantity (`cart_screen.dart:341-359`) | Cart non-empty | N | Y |
| CART-ACT-03 | Button | `Clear All` | Opens dialog; only confirmation clears cart and coupon (`cart_screen.dart:79-96,360-370`; `cart_controller.dart:167-171`) | Cart non-empty | N | Y |
| CART-ROW-01 | Cart item card | Dynamic category tile/icon, variant display name, price/unit, line total, quantity | Display-only item values; one row per item (`cart_screen.dart:373-481`) | Cart non-empty | Y — preserve item and variant ID pairing | Y |
| CART-ACT-04 | Icon button | Tooltip `Remove`; no visible text (delete icon) | Removes item and displays `${productName} removed` snackbar with Undo restoring item at its original index (`cart_screen.dart:67-77,430-451`) | Each cart item | N | Y |
| CART-ACT-05 | Quantity button | Tooltip `Decrease quantity`; no visible text (minus icon) | Calls cart decrease; disabled at quantity 1 (`cart_screen.dart:537-590`) | Each cart item | N | Y |
| CART-ACT-06 | Quantity display | Dynamic item quantity | Shows `CartItem.quantity` (`cart_screen.dart:537-590`) | Each cart item | N | Y |
| CART-ACT-07 | Quantity button | Tooltip `Increase quantity`; no visible text (plus icon) | Calls cart increase; disabled at `CartController.maxQuantity` (99) (`cart_screen.dart:537-590`; `cart_screen.dart:125-136`; `cart_controller.dart:20-22`) | Each cart item | N | Y |
| CART-COUPON-01 | Coupon prompt | `Have a promo coupon?` | Display-only prompt (`cart_screen.dart:730-749`) | Cart non-empty and no coupon applied | N | Y |
| CART-COUPON-ACT-01 | Toggle button | `Apply` or `Cancel` | Expands/collapses coupon input and clears current error (`cart_screen.dart:750-765`) | No coupon currently applied | N | Y |
| CART-COUPON-IN-01 | Text input | `Enter code, e.g. BUILD10`; dynamic validation error | Uppercase-character capitalization; Enter/Done submits; editing clears prior error (`cart_screen.dart:766-791`) | Coupon prompt expanded | N | Y |
| CART-COUPON-ACT-02 | Button | `Apply` | Validates/applies coupon; empty input sets `Enter a coupon code`; unknown code sets `Invalid coupon code`; valid code clears/closes input and shows coupon success message (`cart_screen.dart:644-665,792-800`; `cart_controller.dart:4-15,69-84`) | Coupon prompt expanded | N | Y |
| CART-COUPON-02 | Applied coupon state | `BUILD10 applied` or `FREESHIP applied`; `You save ${formatInr(cart.discount)}` or `Shipping is on us` | Display of applied coupon and savings (`cart_screen.dart:676-725`) | Coupon applied | N | Y |
| CART-COUPON-ACT-03 | Button | `Remove` | Removes applied coupon (`cart_screen.dart:713-716`; `cart_controller.dart:86-91`) | Coupon applied | N | Y |
| CART-SUM-01 | Summary heading | `Price Details` | Labels totals area (`cart_screen.dart:814-861`) | Cart non-empty | N | Y |
| CART-SUM-02 | Summary row | `Subtotal`; formatted subtotal | `cart.subtotal` (`cart_screen.dart:862-864`; `cart_controller.dart:37-45`) | Cart non-empty | N | Y |
| CART-SUM-03 | Summary row | `Coupon (${cart.coupon!.code})`; negative formatted discount | Shown only when `cart.discount > 0` (`cart_screen.dart:864-869`) | Positive coupon discount (not `FREESHIP`) | N | Y |
| CART-SUM-04 | Summary row | `Shipping Charges`; `FREE` or formatted shipping | Shipping is free with `FREESHIP` or subtotal at least ₹10,000; otherwise ₹250 (`cart_screen.dart:870-875`; `cart_controller.dart:19-20,53-61`) | Cart non-empty | N | Y |
| CART-SUM-05 | Shipping threshold message | `Add ${formatInr(toFreeShipping)} more for free shipping` | Difference is free-shipping threshold minus subtotal (`cart_screen.dart:876-884`) | Shipping not free and difference > 0 | N | Y |
| CART-SUM-06 | Summary row | `Tax (GST ${(CartController.gstRate * 100).round()}%)`; formatted tax | GST is rounded 18% of subtotal after coupon discount, excluding shipping (`cart_screen.dart:885-890`; `cart_controller.dart:19-20,63-68`) | Cart non-empty | N | Y |
| CART-SUM-07 | Summary total | `Total Amount`; formatted grand total | `subtotal - discount + shipping + gst` (`cart_screen.dart:892-913`; `cart_controller.dart:63-68`) | Cart non-empty | N | Y |
| CART-BAR-01 | Tappable total row | `Total Amount: `; formatted total; up arrow icon | Calls `_scrollToSummary`, scrolls summary into view, briefly highlights it (`cart_screen.dart:35-52,958-1042`) | Non-empty cart; bottom bar shown | N | Y |
| CART-BAR-ACT-01 | Button | `Proceed to Address` | Pushes `/checkout/address` (`cart_screen.dart:96-97,1043-1078`) | Non-empty cart; currently passed `enabled: true` | N | Y |
| CART-DLG-01 | Confirmation dialog | `Clear cart?`; `All items will be removed from your cart.` | Confirmation before removing all items (`cart_screen.dart:79-96`) | `Clear All` tapped | N | Y |
| CART-DLG-ACT-01 | Dialog button | `Cancel` | Pops dialog with false; leaves cart unchanged (`cart_screen.dart:85-89`) | Clear confirmation open | N | Y |
| CART-DLG-ACT-02 | Dialog button | `Clear All` | Pops dialog with true; caller clears cart if confirmed (`cart_screen.dart:90-96`) | Clear confirmation open | N | Y |
| CART-MSG-01 | Snackbar | `${item.variant.productName} removed`; action `Undo` | Appears after removing row; Undo restores the item at its prior index (`cart_screen.dart:67-77`) | Item removed | N | Y |
| CART-MSG-02 | Coupon error | `Enter a coupon code`; `Invalid coupon code` | Appears as text-field `errorText`; typing clears error (`cart_screen.dart:644-656,779-783`) | Expanded coupon field submitted with blank/invalid code | N | Y |
| CART-MSG-03 | Coupon success snackbar | `10% off applied` or `Free shipping applied` | Shown via `_showSnack(coupon.successMessage)` after successful apply (`cart_screen.dart:659-674`; `cart_controller.dart:4-15`) | Valid coupon applied | N | Y |

## States and messages

- Empty cart: empty-cart icon, `Your cart is empty`, supporting sentence, and `Browse materials`; checkout stepper, item list, summary, and bottom bar are absent (`cart_screen.dart:105-168,1081-1128`).
- Non-empty cart: app header and four static progress labels, item count/list, coupon control, price summary, and fixed bottom bar (`cart_screen.dart:104-166,184-339`).
- Clear confirmation uses title `Clear cart?`, content `All items will be removed from your cart.`, and `Cancel`/`Clear All` actions (`cart_screen.dart:79-96`).
- Remove item shows `${productName} removed` with `Undo`; restoring is blocked if same variant is already present (`cart_screen.dart:67-77`; `cart_controller.dart:154-162`).
- Coupon blank/invalid errors are exact strings `Enter a coupon code` and `Invalid coupon code`; errors clear on editing and when toggling form (`cart_screen.dart:644-665,750-783`).
- Applied coupon state shows `<code> applied`; BUILD10 shows `You save <formatted discount>`, FREESHIP shows `Shipping is on us`; Remove clears it (`cart_screen.dart:676-725`).
- Valid coupon success snackbar copy is `10% off applied` for BUILD10 and `Free shipping applied` for FREESHIP (`lib/core/state/cart_controller.dart:4-15`; `cart_screen.dart:659-674`).
- Cart total tap scrolls summary into view and highlights it for 1.5 seconds (`cart_screen.dart:35-52,814-841`).
- No API loading/error, upload, or passcode state is defined.

## Displayed values

- Header count is total item quantity; badge omitted at zero and capped at `99+` (`cart_screen.dart:184-195,256-274`).
- `Review Items` count is `cart.items.length`, distinct from total quantity (`cart_screen.dart:341-359`).
- Line total is `CartItem.totalPrice` = variant unit price × quantity (`cart_screen.dart:445-464`; `lib/features/catalog/domain/models/catalog_models.dart:295-300`).
- Quantity limits: CartController max quantity 99; addVariant raises requested quantity to at least variant minimum order quantity and caps at 99; this screen’s decrease button itself floors at 1 (`cart_controller.dart:20-22,99-116`; `cart_screen.dart:537-590`).
- Subtotal is sum of item line totals. BUILD10 discount is rounded 10% of subtotal. Shipping is zero for empty cart, FREESHIP, or subtotal ≥ 10000; otherwise 250. GST is rounded `(subtotal - discount) * 0.18`. Grand total is `subtotal - discount + shipping + gst` (`cart_controller.dart:37-68`).
- Free-shipping message amount is `10000 - subtotal`, only while shipping is not free and that difference is positive (`cart_screen.dart:818-819,870-884`; `cart_controller.dart:19-20,53-61`).
- Currency uses `formatInr` in app model for whole rupees with Western digit grouping (`lib/features/catalog/domain/models/catalog_models.dart:444-454`).
- Coupon summary discount row only appears when discount is positive; FREESHIP therefore has no coupon discount row (`cart_screen.dart:864-869`).

## Style with meaning

- Current checkout step is primary-colored/bold; future steps are outline-colored; progress indicator is 1/4 (`cart_screen.dart:278-339`).
- Applied coupon/savings use success styling; invalid coupon text is the input’s error state (`cart_screen.dart:676-725,766-791`).
- Shipping `FREE` uses success color; coupon discount uses success color; free-shipping progress copy uses info color (`cart_screen.dart:864-890`).
- The summary card briefly uses highlighted background/border/shadow after the bottom-bar total is tapped (`cart_screen.dart:35-52,825-845`).
- Disabled quantity controls use disabled feedback; preserve lower/upper bounds (`cart_screen.dart:537-590`).

## Keyboard and focus

- Coupon form autofocuses on expansion, capitalizes characters, submits on `TextInputAction.done`, and hides keyboard after successful apply. Editing clears an existing error (`cart_screen.dart:644-674,766-791`).
- No custom Escape handler or explicit focus order is defined. Confirmation dialog and snackbars use Flutter platform behavior.

## Responsive

- Cart content and bottom bar are centered/constrained to maximum width 720 logical pixels (`cart_screen.dart:25-27,142-168,958-1080`).
- Content scrolls vertically; bottom checkout bar remains in `Scaffold.bottomNavigationBar` while cart is non-empty.
- Header wraps safely around app name and count badge; no alternate breakpoint is defined.

## Risk notes

- Item cards use `ValueKey(item.variantId)`; keep stable variant keys to preserve row identity through quantity/removal changes (`cart_screen.dart:125-136`).
- Clear-all confirmation and item removal/Undo are distinct flows; do not merge them or silently change undo ordering (`cart_screen.dart:67-96`; `cart_controller.dart:154-171`).
- Cart pricing labels depend on CartController formulas and conditional visibility; preserve total consistency across summary, header, and bottom bar (`cart_screen.dart:814-913,958-1078`; `cart_controller.dart:37-68`).
- Bottom total row is a scroll-to-summary action rather than a checkout action; `Proceed to Address` is a separate navigation button (`cart_screen.dart:35-52,1005-1078`).
- `Browse materials` supplies no category args; retain that call shape unless navigation behavior is explicitly changed (`cart_screen.dart:1121-1128`).
- `cart_screen.dart` also defines `QuotationReviewScreen` after line 1144; that separate route is SCR-27 and must not be conflated with cart UI.
