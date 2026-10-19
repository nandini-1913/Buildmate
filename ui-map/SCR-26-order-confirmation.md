# SCR-26 — Order confirmation

- Route: `/checkout/confirmation` (`AppRoutes.orderConfirmation`); requires `OrderConfirmationArgs.order`
- Source files: [order_confirmation_screen.dart](../lib/features/checkout/presentation/screens/order_confirmation_screen.dart) (420 lines); [order_models.dart](../lib/features/checkout/domain/models/order_models.dart); [checkout_widgets.dart](../lib/features/checkout/presentation/widgets/checkout_widgets.dart)
- Purpose: Confirm the placed order, show delivery/payment/address and item totals, and return the shopper to the originating first route.

## Data

- Router falls back to `CartScreen` if order-confirmation arguments are absent or wrong type; otherwise it builds this screen with the `PlacedOrder` snapshot (`lib/core/routes/app_router.dart:189-194`; `lib/core/routes/app_routes.dart:181-186`).
- Payment flow creates the order snapshot from cart items, address, delivery option, and payment method before clearing cart and navigating here (`lib/features/checkout/presentation/screens/payment_screen.dart:89-96`; `lib/features/checkout/domain/models/order_models.dart:32-50`).
- Screen reads cart total quantity only for shared checkout header badge; it does not fetch data or make an API call (`order_confirmation_screen.dart:26-33`).
- Continue Shopping and system-back behavior both pop to the first route (`order_confirmation_screen.dart:21-23,29-34,398-419`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| CONF-HDR-01 | Checkout header | App name `Buildmate 24x7`; `Step 4 of 4`; labels `1. Cart`, `2. Address`, `3. Payment`, `4. Confirm`; disabled cart icon and optional count badge; no back button | Shared `CheckoutStepHeader(currentStep: 3, showBack: false)` (`order_confirmation_screen.dart:37-41`; `checkout_widgets.dart:18-167`; app name `lib/core/constants/app_constants.dart:1-3`) | Always | Y — checkout sequence remains fixed | Y |
| CONF-IMG-01 | Success icon | No text (check mark inside animated circles) | Display-only success graphic (`order_confirmation_screen.dart:75-119`) | Always | N | Y |
| CONF-TXT-01 | Status badge | `ORDER PLACED SUCCESSFULLY` | Display-only confirmation status (`order_confirmation_screen.dart:120-140`) | Always | N | Y |
| CONF-TXT-02 | Greeting | `Thank You, ${order.customerFirstName}!` | Customer first name is first word of trimmed address full name; fallback `there` (`order_confirmation_screen.dart:141-151`; `order_models.dart:78-82`) | Always | N | Y |
| CONF-TXT-03 | Order ID | `Order ID: ${order.orderId}` | Displays order ID from snapshot (`order_confirmation_screen.dart:152-171`; generation `order_models.dart:32-50`) | Always | N | Y |
| CONF-INFO-01 | Delivery information row | `Estimated Delivery`; title-cased delivery ETA | ETA text transforms every space-delimited word’s first character to uppercase (`order_confirmation_screen.dart:240-252,284-289`) | Always | N | Y |
| CONF-INFO-02 | Address information row | `Shipping To`; `${address.label}, ${address.house}, ${address.city}` | Display-only selected address summary (`order_confirmation_screen.dart:253-261`) | Always | N | Y |
| CONF-INFO-03 | Payment status row | `Payment Status`; `Paid via UPI`, `Paid via Card`, `Paid via Net Banking`, or `Pay on Delivery` | Status and success/warning icon/color derive from whether COD (`order_confirmation_screen.dart:262-283`; `order_models.dart:67-76`) | Always | N | Y |
| CONF-TXT-04 | Summary heading | `Order Summary (${count} item)` or `Order Summary (${count} items)` | Count is distinct order lines (`order_confirmation_screen.dart:302-318`; `order_models.dart:65-66`) | Always | N | Y |
| CONF-ROW-01 | Order line | `${line.quantity}x ${line.name}`; formatted line total | Display-only line from order snapshot (`order_confirmation_screen.dart:319-341`; snapshot `order_models.dart:40-47`) | One row per placed order line | Y — retain line quantity/name/amount association | Y |
| CONF-TXT-05 | Total label | `Total Amount Paid` for prepaid methods; `Amount Payable` for COD | Label depends on `order.isPaid` (`order_confirmation_screen.dart:342-363`; `order_models.dart:65-76`) | Always | N | Y |
| CONF-TXT-06 | Total amount | Formatted `order.total` | Display-only snapshot total (`order_confirmation_screen.dart:342-365`; formula `order_models.dart:47-50`) | Always | N | Y |
| CONF-ACT-01 | Button | `Continue Shopping`; home icon | Calls `Navigator.popUntil(route.isFirst)` (`order_confirmation_screen.dart:398-419`) | Always | N | Y |

## States and messages

- Only the successful-order state is rendered; the route requires a `PlacedOrder`. If router arguments are missing/invalid, AppRouter shows CartScreen instead (`lib/core/routes/app_router.dart:189-194`).
- Success state displays greeting, order ID, delivery ETA/address, payment status, order lines, and total.
- No loading, empty, API error, validation, confirmation, upload, or passcode state is defined.
- System back is intercepted; it returns to the first route by calling the same behavior as Continue Shopping (`order_confirmation_screen.dart:29-34`).

## Displayed values

- Order ID is `#SC-` followed by a random six-digit number; order lines copy product name, quantity, and line total from cart (`lib/features/checkout/domain/models/order_models.dart:32-50`).
- Greeting is first whitespace-delimited word of trimmed full name, or `there` if empty (`order_models.dart:78-82`).
- Delivery ETA is title-cased by uppercasing the first character of each space-delimited token; source strings are `3 - 5 business days` and `1 - 2 business days` (`order_confirmation_screen.dart:284-289`; `address_models.dart:100-110`).
- `Shipping To` displays address label, house, and city only (`order_confirmation_screen.dart:253-261`).
- Payment status mappings: UPI → `Paid via UPI`; card → `Paid via Card`; net banking → `Paid via Net Banking`; COD → `Pay on Delivery` (`order_models.dart:67-76`).
- Count is order line count (distinct cart variants), not total quantity; singular `item` for 1, otherwise `items` (`order_confirmation_screen.dart:302-318`; `order_models.dart:65-66`).
- Total is `cart.grandTotal + delivery.fee` captured when order is placed (`order_models.dart:32-50`); line prices use `formatInr` (`order_confirmation_screen.dart:319-365`).

## Style with meaning

- Success badge/check use success-container and success colors (`order_confirmation_screen.dart:88-139`).
- Payment status uses success styling for paid and warning styling for Pay on Delivery (`order_confirmation_screen.dart:233-235,262-283`).
- Current checkout step is Confirm; shared header colors current/completed and future steps differently (`checkout_widgets.dart:113-167`).
- No interactive selected/disabled states appear in confirmation content.

## Keyboard and focus

- No text input, keyboard shortcuts, autofocus, or custom focus order.
- System back is explicitly intercepted by `PopScope` and routes to first route (`order_confirmation_screen.dart:29-34`).

## Responsive

- Main content is a vertically scrolling list centered and constrained to 720 logical pixels (`order_confirmation_screen.dart:38-69`; `checkout_widgets.dart:13-15`).
- Continue bar is fixed at bottom and constrained to the same width (`order_confirmation_screen.dart:398-419`).
- No breakpoint is defined.

## Risk notes

- This page is non-poppable by default; back must continue to first route, and Continue Shopping uses the same destination (`order_confirmation_screen.dart:21-23,29-34,398-419`).
- Header back button is hidden and cart is empty after payment completion; preserve `showBack: false` and step index 3 (`order_confirmation_screen.dart:37-41`; payment clears cart at `payment_screen.dart:89-96`).
- Payment method controls payment status, icon/color, and total label (`order_models.dart:65-76`; `order_confirmation_screen.dart:262-283,342-363`).
- Summary count is based on order lines while each row shows quantity; do not replace one count with the other (`order_models.dart:40-47,65-66`; `order_confirmation_screen.dart:302-341`).
