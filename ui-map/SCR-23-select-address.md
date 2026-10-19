# SCR-23 — Select address

- Route: `/checkout/address` (`AppRoutes.selectAddress`)
- Source files: [select_address_screen.dart](../lib/features/checkout/presentation/screens/select_address_screen.dart) (353 lines); [checkout_widgets.dart](../lib/features/checkout/presentation/widgets/checkout_widgets.dart); [address_models.dart](../lib/features/checkout/domain/models/address_models.dart)
- Purpose: Select a shipping address and delivery speed, review the checkout total, and proceed to payment.

## Data

- Router constructs `SelectAddressScreen` without arguments; absent an explicit `initialAddresses` override, screen initializes local addresses from `MockAddresses.saved` (`lib/core/routes/app_router.dart:181-184`; `select_address_screen.dart:15-31`; `lib/features/checkout/domain/models/address_models.dart:112-141`).
- No address API is called. Add New navigates to `/checkout/address/new`; returned `DeliveryAddress` is appended or inserted first if default, selected, and acknowledged with `${address.label} address saved` (`select_address_screen.dart:38-59`).
- Default selection is the first `isDefault` address; if none is default, first address is selected; empty list leaves selection at -1 (`select_address_screen.dart:24-33`).
- Delivery options are local enum values: Standard Delivery / `3 - 5 business days` / ₹0; Express Delivery / `1 - 2 business days` / ₹99. Initial selection is Standard Delivery (`address_models.dart:100-110`; `select_address_screen.dart:26-27`).
- Address selection and delivery selection change local state. Proceed navigates to `/checkout/payment` with selected address and delivery in `PaymentArgs`; if no address is selected, it shows `Add a shipping address to continue` (`select_address_screen.dart:61-74`).
- Screen reads shared `CartController`; total bar and price breakdown use local cart totals plus selected delivery fee. No API call is made here (`select_address_screen.dart:77-156`; `lib/features/checkout/presentation/widgets/checkout_widgets.dart:343-432`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| ADR-BTN-01 | Icon button | Tooltip `Back`; no visible text (back arrow) | Calls `Navigator.maybePop()` via shared checkout header (`lib/features/checkout/presentation/widgets/checkout_widgets.dart:18-57`) | Header `showBack` defaults true | N | Y |
| ADR-IMG-01 | App logo | No text | Displays `assets/images/branding/app logo.png` (`checkout_widgets.dart:58-62`) | Always | N | Y |
| ADR-TXT-01 | App name | `Buildmate 24x7` | Uses `AppConstants.appName` (`checkout_widgets.dart:63-73`; `lib/core/constants/app_constants.dart:1-3`) | Always | N | Y |
| ADR-TXT-02 | Checkout step counter | `Step 2 of 4` | Shared header receives `currentStep: 1` (`select_address_screen.dart:79-81`; `checkout_widgets.dart:18-25,76-86`) | Always | Y — fixed checkout progress | Y |
| ADR-BTN-02 | Disabled cart icon button | Tooltip `Cart`; cart icon with badge | Disabled `onPressed`; badge shows cart total quantity, capped at `99+` and hidden at zero (`checkout_widgets.dart:87-107`) | Always | N | Y |
| ADR-TXT-03 | Checkout step labels | `1. Cart`; `2. Address`; `3. Payment`; `4. Confirm` | Display-only; current step 2 is primary/bold (`checkout_widgets.dart:113-146`) | Always | Y — preserve checkout step order | Y |
| ADR-TXT-04 | Section heading | Rendered `SHIPPING ADDRESS` | `CheckoutSectionTitle` uppercases the supplied `Shipping Address` (`select_address_screen.dart:94-96`; `checkout_widgets.dart:180-224`) | Always | N | Y |
| ADR-ACT-01 | Button | `Add New` | Pushes `/checkout/address/new`; consumes returned `DeliveryAddress`, selects it and shows `${address.label} address saved` snackbar (`select_address_screen.dart:38-59,97-106`) | Always | N | Y |
| ADR-STATE-01 | Empty address action | `Add a shipping address` | Opens same Add New route (`select_address_screen.dart:109-110,326-351`) | Address list empty | N | Y |
| ADR-CARD-01 | Address choice | Dynamic address label; conditional `Default`; full name; `<house>, <area>`; `<city> - <pincode>, <state>`; formatted phone | Tap selects address index locally (`select_address_screen.dart:111-124,176-234`) | One card per address; `Default` only when address.isDefault | Y — each address’s details/default status must remain paired | Y |
| ADR-IMG-02 | Address icon/radio indicator | No text (location and selected-radio icon) | Display-only card selection feedback (`select_address_screen.dart:176-234`; `checkout_widgets.dart:226-285`) | Each address card | N | Y |
| ADR-TXT-05 | Section heading | Rendered `DELIVERY OPTIONS` | Shared title uppercases `Delivery Options` (`select_address_screen.dart:131-134`; `checkout_widgets.dart:180-224`) | Always | N | Y |
| ADR-DEL-01 | Delivery option card | `Standard Delivery`; `3 - 5 business days`; `FREE` | Tap sets `_delivery` to Standard Delivery (`address_models.dart:100-110`; `select_address_screen.dart:135-142,258-323`) | Always | Y — each label, ETA, and fee are one option | Y |
| ADR-DEL-02 | Delivery option card | `Express Delivery`; `1 - 2 business days`; `₹99` formatted | Tap sets `_delivery` to Express Delivery (`address_models.dart:100-110`; `select_address_screen.dart:135-142,258-323`) | Always | Y — each label, ETA, and fee are one option | Y |
| ADR-BAR-01 | Tappable total row | `Total Amount: `; formatted `cart.grandTotal + delivery.fee`; up arrow | Opens shared price breakdown bottom sheet (`select_address_screen.dart:148-156`; `checkout_widgets.dart:343-432,435-512`) | Always | N | Y |
| ADR-BAR-ACT-01 | Button | `Proceed to Payment` | Calls `_proceed`; navigates with selected address/delivery or shows no-address snackbar (`select_address_screen.dart:61-74,148-156`; `checkout_widgets.dart:435-563`) | Always enabled by current call site | N | Y |
| ADR-MODAL-01 | Bottom-sheet heading | `Price Details` | Labels checkout price breakdown (`checkout_widgets.dart:343-432`) | Total row tapped | N | Y |
| ADR-MODAL-02 | Summary row | `Subtotal`; formatted cart subtotal | Reads cart subtotal (`checkout_widgets.dart:391-402`) | Breakdown open | N | Y |
| ADR-MODAL-03 | Conditional summary row | `Discount`; `- ${formatInr(cart.discount)}` | Shown only when cart discount > 0 (`checkout_widgets.dart:403-409`) | Positive cart discount | N | Y |
| ADR-MODAL-04 | Summary row | `Shipping`; `FREE` or formatted cart shipping | Reads cart shipping (`checkout_widgets.dart:410-414`) | Breakdown open | N | Y |
| ADR-MODAL-05 | Summary row | `GST (18%)`; formatted cart GST | Reads `cart.gst` (`checkout_widgets.dart:415-416`) | Breakdown open | N | Y |
| ADR-MODAL-06 | Summary row | Dynamic delivery label; `FREE` or formatted delivery fee | Shows currently selected delivery option and fee (`checkout_widgets.dart:417-420`) | Breakdown open | N | Y |
| ADR-MODAL-07 | Summary row | `Total Amount`; formatted cart grand total plus delivery fee | Displays same total as bottom bar (`checkout_widgets.dart:422-429`) | Breakdown open | N | Y |
| ADR-MSG-01 | Snackbar | `${address.label} address saved` | Success feedback after Add New returns a `DeliveryAddress` (`select_address_screen.dart:38-59`) | Address returned and screen mounted | N | Y |
| ADR-MSG-02 | Snackbar | `Add a shipping address to continue` | Prevents payment navigation when no address selected (`select_address_screen.dart:61-68`) | Proceed tapped with `_selected < 0` | N | Y |

## States and messages

- Default route uses two mock addresses: Home, `Nandini Sharma`, `123, Green Park`, `Near City Mall`, `Bangalore - 560076, Karnataka`, `+91 98765 43210` (Default); Office, `Nandini Sharma`, `Plot No. 45`, `Tech Park Road`, `Bangalore - 560001, Karnataka`, `+91 98765 43210` (`lib/features/checkout/domain/models/address_models.dart:112-141`).
- Empty address list shows `Add a shipping address`; there is no loading or error state (`select_address_screen.dart:109-110`).
- New address returned from add-address route is selected. A returned default address clears old defaults and is inserted at index zero; non-default address is appended (`select_address_screen.dart:38-59`).
- Default delivery is Standard Delivery; exactly one delivery option is selected at a time (`select_address_screen.dart:26-27,135-142`).
- Proceed with no selected address shows `Add a shipping address to continue`; otherwise it navigates to payment with the selected address and delivery option (`select_address_screen.dart:61-74`).
- Address save feedback is `${address.label} address saved`. Snackbars hide the current snackbar before showing the next (`select_address_screen.dart:34-37,56-59`).
- No confirmation, form validation, upload, or passcode state is defined on this screen.

## Displayed values

- Address label comes from type `Home`, `Office`, `Other`, or for Other a non-empty custom label (`lib/features/checkout/domain/models/address_models.dart:5-9,41-45`).
- Phone is formatted `+91 XXXXX XXXXX` for a 10-digit number, otherwise `+91 <mobile>` (`address_models.dart:88-95`).
- Delivery prices are enum fees (0, 99); address-screen total is `cart.grandTotal + delivery.fee` (`address_models.dart:100-110`; `select_address_screen.dart:148-156`).
- Shared breakdown total includes cart grand total plus delivery fee; lines show subtotal, optional coupon discount, shipping, GST, and selected delivery (`checkout_widgets.dart:343-432`).
- Cart grand total and GST formulas are specified in SCR-22.

## Style with meaning

- Selected address and delivery cards have selected border/background and selected radio dot; keep selected and unselected distinguishable (`checkout_widgets.dart:226-285`; `select_address_screen.dart:176-234,258-323`).
- Default address badge uses success styling (`select_address_screen.dart:195-212`).
- Free delivery is labeled `FREE` with success styling; paid delivery uses formatted fee (`select_address_screen.dart:277-320`).
- Checkout progress distinguishes completed/current steps from future steps (`checkout_widgets.dart:113-167`).

## Keyboard and focus

- No text inputs, keyboard shortcuts, autofocus, explicit focus order, or Escape handler on this screen.
- Modal price breakdown uses Flutter bottom-sheet drag/back/barrier dismissal; selectable cards use Material interaction feedback.

## Responsive

- Main checkout content and shared total bar are centered and constrained to 720 logical pixels (`select_address_screen.dart:87-93,148-156`; `checkout_widgets.dart:435-478`).
- Main content is vertically scrollable. Price breakdown is vertically scrollable within a safe area (`checkout_widgets.dart:365-432`).
- No breakpoint is defined.

## Risk notes

- Address selection is index-based; inserting a new default address at index zero resets selection to zero, while non-default insertion selects the appended last item (`select_address_screen.dart:24-31,38-59`).
- Delivery fee affects both bottom total and price breakdown; preserve the selected delivery object passed to payment (`select_address_screen.dart:61-74,148-156`; `checkout_widgets.dart:343-432`).
- Section headings are uppercased by shared `CheckoutSectionTitle`; rendered exact text is all caps although screen passes title case (`checkout_widgets.dart:180-224`).
- Header back, progress labels, and disabled cart icon are shared checkout chrome; preserve their shared behavior and current-step argument.
