# SCR-25 — Payment

- Route: `/checkout/payment` (`AppRoutes.payment`); requires `PaymentArgs` containing selected `DeliveryAddress` and `DeliveryOption`
- Source files: [payment_screen.dart](../lib/features/checkout/presentation/screens/payment_screen.dart) (448 lines); [payment_models.dart](../lib/features/checkout/domain/models/payment_models.dart); [order_models.dart](../lib/features/checkout/domain/models/order_models.dart); [checkout_widgets.dart](../lib/features/checkout/presentation/widgets/checkout_widgets.dart)
- Purpose: Select a payment method, collect method-specific details, and complete the mocked order flow.

## Data

- Router returns to `CartScreen` if `/checkout/payment` does not receive `PaymentArgs`; otherwise it constructs `PaymentScreen(args)` (`lib/core/routes/app_router.dart:185-188`).
- Screen starts with UPI selected and reads current cart plus address/delivery arguments; no payment gateway/API call is made (`payment_screen.dart:34-40,99-125`).
- Payment methods are UPI, card, net banking, and cash on delivery; selected method controls the details widget (`payment_screen.dart:132-143`; `payment_models.dart:4-31`).
- Place Order validates active method fields, additionally requires a bank for net banking, sets processing state, waits default 1200 ms, snapshots cart/address/delivery/method into `PlacedOrder`, clears cart, then replaces checkout routes with `/checkout/confirmation` (`payment_screen.dart:72-96`).
- Order total is `cart.grandTotal + delivery.fee`; order snapshot uses the same formula (`payment_screen.dart:102-103,157-169`; `lib/features/checkout/domain/models/order_models.dart:32-50`).
- Tapping total opens shared price breakdown sheet; no other payment action calls an API (`payment_screen.dart:157-169`; `lib/features/checkout/presentation/widgets/checkout_widgets.dart:343-432`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| PAY-BTN-01 | Icon button | Tooltip `Back`; no visible text (back arrow) | Shared checkout header calls `Navigator.maybePop()` (`checkout_widgets.dart:18-57`) | Always | N | Y |
| PAY-IMG-01 | App logo | No text | Shared checkout header logo (`checkout_widgets.dart:58-62`) | Always | N | Y |
| PAY-TXT-01 | App name | `Buildmate 24x7` | Uses `AppConstants.appName` (`checkout_widgets.dart:63-73`; `lib/core/constants/app_constants.dart:1-3`) | Always | N | Y |
| PAY-TXT-02 | Checkout step count | `Step 3 of 4` | Shared header gets `currentStep: 2` (`payment_screen.dart:127-129`; `checkout_widgets.dart:18-25,76-86`) | Always | Y — fixed step order | Y |
| PAY-BTN-02 | Disabled cart icon button | Tooltip `Cart`; cart icon and optional quantity badge | `onPressed: null`; badge hidden at zero and capped at `99+` (`checkout_widgets.dart:87-107`) | Always | N | Y |
| PAY-TXT-03 | Checkout step labels | `1. Cart`; `2. Address`; `3. Payment`; `4. Confirm` | Display-only; current step is Payment (`checkout_widgets.dart:113-146`) | Always | Y — fixed step order | Y |
| PAY-TXT-04 | Section heading | Rendered `SELECT PAYMENT METHOD` | Shared `CheckoutSectionTitle` uppercases passed `Select Payment Method` (`payment_screen.dart:130-134`; `checkout_widgets.dart:180-224`) | Always | N | Y |
| PAY-SEL-01 | Payment method card | `UPI (GPay / PhonePe / Paytm)`; `Instant payment with 0 transaction fees` | Selects UPI and reveals UPI ID field (`payment_screen.dart:132-143,171-181`; `payment_models.dart:5-9`) | One method card always; selected initially | Y — card label must map to UPI method | Y |
| PAY-SEL-02 | Payment method card | `Credit / Debit Card`; `Visa, MasterCard, RuPay` | Selects card and reveals card number/expiry/CVV/name fields (`payment_screen.dart:132-143,182-238`; `payment_models.dart:10-14`) | Always | Y — card label must map to card method | Y |
| PAY-SEL-03 | Payment method card | `Net Banking`; `All major Indian banks supported` | Selects net banking and reveals bank dropdown (`payment_screen.dart:132-143,239-249`; `payment_models.dart:15-19`) | Always | Y — card label must map to netBanking method | Y |
| PAY-SEL-04 | Payment method card | `Cash on Delivery`; `Pay at your doorstep upon arrival` | Selects COD and reveals COD instruction (`payment_screen.dart:132-143,250-255`; `payment_models.dart:20-24`) | Always | Y — card label must map to COD method | Y |
| PAY-IN-01 | UPI ID input | `Enter UPI ID (e.g. 9876543210@paytm)`; `Enter your UPI ID`; `Enter a valid UPI ID (e.g. name@okaxis)` | Validates UPI format; keyboard email-address, no autocorrect, Done action (`payment_screen.dart:171-181`; `payment_models.dart:47-54`) | UPI selected | N | Y |
| PAY-IN-02 | Card number input | `Card number`; `Enter card number`; `Enter a valid card number` | Digits-only, max 16 digits, grouped every four; validator accepts 15-16 digits passing Luhn (`payment_screen.dart:182-199`; `payment_models.dart:56-63`) | Card selected | N | Y |
| PAY-IN-03 | Expiry input | `Expiry (MM/YY)`; `MM/YY`; `Invalid month`; `Card expired` | Digits-only, max four digits, formatted `MM/YY`; rejects malformed/invalid month/past expiry (`payment_screen.dart:200-215`; `payment_models.dart:65-81`) | Card selected | N | Y |
| PAY-IN-04 | CVV input | `CVV`; `Invalid CVV` | Numeric keyboard, obscured, digits only, max four; accepts 3-4 digits (`payment_screen.dart:216-229`; `payment_models.dart:83-84`) | Card selected | N | Y |
| PAY-IN-05 | Cardholder input | `Name on card`; `Enter name on card` | Words capitalization; requires trimmed length at least 2 (`payment_screen.dart:230-238`; `payment_models.dart:86-87`) | Card selected | N | Y |
| PAY-SEL-05 | Bank dropdown | `Select your bank`; dynamic selected bank; options `State Bank of India`, `HDFC Bank`, `ICICI Bank`, `Axis Bank`, `Kotak Mahindra Bank`, `Punjab National Bank`, `Bank of Baroda`, `Canara Bank` | Stores selected bank locally; missing choice prevents order and shows `Select your bank to continue` snackbar (`payment_screen.dart:239-249,72-80`; `payment_models.dart:34-43`) | Net Banking selected | Y — bank label must map to its bank value | Y |
| PAY-TXT-05 | COD instruction | `Keep ${formatInr(total)} ready in cash or pay by UPI to the delivery partner.` | Display-only; total includes cart grand total plus delivery fee (`payment_screen.dart:250-255`; `order_models.dart:32-50`) | Cash on Delivery selected | N | Y |
| PAY-TXT-06 | Security note | `Guaranteed 256-bit SSL encrypted safe checkout` | Display-only security copy (`payment_screen.dart:145-150,355-389`) | Always | N | Y |
| PAY-BAR-01 | Tappable total row | `Total Amount: `; formatted total; up arrow | Opens shared checkout price-breakdown bottom sheet (`payment_screen.dart:157-169`; `checkout_widgets.dart:343-432,435-512`) | Always | N | Y |
| PAY-BTN-03 | Button | `Place Order (${formatInr(total)})`; lock icon; while placing, spinner replaces copy | Validates active method; net banking requires bank; after simulated processing empties cart and navigates to confirmation (`payment_screen.dart:72-96,157-169`; `checkout_widgets.dart:435-563`) | Always; disabled and spinner shown while `_placing` | N | Y |
| PAY-MSG-01 | Snackbar | `Select your bank to continue` | Stops order creation when net banking has no selected bank (`payment_screen.dart:72-80`) | Net Banking selected and no bank selected on Place Order | N | Y |
| PAY-MODAL-01 | Price breakdown | `Price Details`; `Subtotal`; conditional `Discount`; `Shipping`; `GST (18%)`; selected delivery label; `Total Amount` | Shared sheet displays item subtotal, optional coupon discount, cart shipping/GST, delivery fee, and combined total (`checkout_widgets.dart:343-432`) | Total row tapped | Y — each amount must retain its label/formula | Y |

## States and messages

- Initial state selects UPI; only that payment method’s detail widget is expanded. Selecting another method unfocuses inputs and replaces the active detail widget (`payment_screen.dart:34-40,66-70,132-143`).
- UPI validation errors: `Enter your UPI ID`; `Enter a valid UPI ID (e.g. name@okaxis)` (`payment_models.dart:49-54`).
- Card validation errors: `Enter card number`; `Enter a valid card number`; `MM/YY`; `Invalid month`; `Card expired`; `Invalid CVV`; `Enter name on card` (`payment_models.dart:56-87`).
- Net Banking without bank selection: `Select your bank to continue` floating snackbar (`payment_screen.dart:72-80`).
- During mocked order processing, `Place Order` is disabled and replaced by a spinner; default wait is 1200 ms (`payment_screen.dart:21-30,85-87,157-169`).
- Successful placement creates order snapshot, clears cart, and replaces checkout stack with confirmation route; no success snackbar is shown here (`payment_screen.dart:89-96`).
- No payment API error/response state, upload, or passcode popup is defined.

## Displayed values

- Payment methods and subtitle copy are fixed in `PaymentMethod` enum (`lib/features/checkout/domain/models/payment_models.dart:4-31`).
- Card number formatter groups digits into four-character chunks separated by spaces; expiry formatter inserts `/` after two digits (`payment_screen.dart:392-448`).
- UPI validation uses `^[\\w.\\-]{2,256}@[a-zA-Z][a-zA-Z0-9]{1,63}$`; card requires 15-16 digits and Luhn pass; expiry requires MM/YY, month 1-12, not earlier than current month; CVV is 3-4 digits; card name trimmed length ≥2 (`payment_models.dart:47-87`).
- Payment total is cart grand total plus selected delivery fee; the same total is formatted in CTA, COD note, order snapshot, and price breakdown (`payment_screen.dart:102-103,157-169,250-255`; `order_models.dart:32-50`).
- Successful order ID is `#SC-` plus a random six-digit number; order snapshot copies cart lines and selected address/delivery/payment method (`order_models.dart:22-50`).

## Style with meaning

- Selected payment method uses selected card/radio treatment; keep the active detail area associated with exactly that method (`payment_screen.dart:132-143`; `checkout_widgets.dart:226-285`).
- COD note uses warning-container styling and info icon (`payment_screen.dart:250-255,290-344`).
- Secure checkout note uses success icon/color (`payment_screen.dart:355-389`).
- Processing state replaces action label with spinner and disables the button (`checkout_widgets.dart:435-563`).

## Keyboard and focus

- UPI field uses email-address keyboard, disables autocorrect, and submits with Done. Card number/expiry/CVV use numeric keyboards; name uses word capitalization and Done (`payment_screen.dart:171-238`).
- Card number/expiry use input formatters; CVV is obscured. Changing method calls `unfocus`; Place Order also unfocuses before validation (`payment_screen.dart:66-70,72-74`).
- No autofocus, explicit Escape handler, or custom focus order is defined.

## Responsive

- Method cards and details appear in a vertically scrolling form centered to 720 logical pixels (`payment_screen.dart:128-155`).
- Card expiry/CVV fields share a row; form may wrap/scroll with keyboard via normal ListView behavior (`payment_screen.dart:198-229`).
- Shared sticky total bar and modal use 720-pixel max content width / bottom sheet behavior (`checkout_widgets.dart:435-478`).
- No breakpoint is defined.

## Risk notes

- `PaymentArgs` carries the selected delivery address and option into order snapshot; preserve those argument values (`payment_screen.dart:72-96`; `lib/core/routes/app_routes.dart:173-179`).
- Only active method detail controls are rendered inside the form; changing payment method changes which validators run (`payment_screen.dart:132-143,171-255`).
- Net Banking bank requirement is outside form validators and shows a snackbar; keep that gate separate (`payment_screen.dart:72-80`).
- Place Order is simulated and clears cart before replacing checkout route stack; do not change these effects in a visual-only redesign (`payment_screen.dart:85-96`).
