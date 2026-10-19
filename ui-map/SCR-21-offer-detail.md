# SCR-21 — Offer detail

- Route: `/offer-detail` (`AppRoutes.offerDetail`); route argument: `OfferDetailArgs.offerId`
- Source files: [offers_screen.dart](../lib/features/catalog/presentation/screens/offers_screen.dart) (181 lines; detail screen at lines 93-180); [app_router.dart](../lib/core/routes/app_router.dart); [catalog_controller.dart](../lib/core/state/catalog_controller.dart)
- Purpose: Show an offer’s discount/details, eligible catalog products, and optional category navigation.

## Data

- Router reads optional `OfferDetailArgs`; missing args yield an empty offer ID (`lib/core/routes/app_router.dart:173-180`).
- Screen resolves the offer from `CatalogController.offerById(offerId)`. The controller rebuilds the offer list from discounted variants and returns the matching ID (`offers_screen.dart:95-99`; `lib/core/state/catalog_controller.dart:317-343`).
- Eligible products are each `offer.productIds` value mapped through `catalog.productById`, with null results removed (`offers_screen.dart:107-111`; `catalog_controller.dart:136-145`).
- Current catalog-derived offers set `productIds: [variant.id]` but omit `categoryId`; `Browse category` is conditionally rendered only if an offer has a category ID (`catalog_controller.dart:326-335`; `offers_screen.dart:151-174`).
- Tapping an eligible product pushes `/product-detail` with both `productId: p.id` and `variantId: p.id` (`offers_screen.dart:123-139`). Product detail’s ID resolution behavior is documented in SCR-15.
- `Browse category` pushes `/category-browse` with category ID (`offers_screen.dart:151-174`).
- No API request or data mutation is initiated by this screen.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| OFD-STATE-01 | Not-found app bar | `Offer` | App bar shown when offer ID does not resolve (`offers_screen.dart:95-103`) | Offer lookup returns null | N | Y |
| OFD-STATE-02 | Not-found state | `Offer not found` | Centered message; no retry action (`offers_screen.dart:95-103`) | Offer lookup returns null | N | Y |
| OFD-TXT-01 | App-bar title | Dynamic `offer.title` | Displays resolved offer title (`offers_screen.dart:114-119`) | Offer exists | N | Y |
| OFD-TXT-02 | Discount heading | Dynamic `offer.discountText` | Display-only offer discount copy (`offers_screen.dart:120-127`) | Offer exists | N | Y |
| OFD-TXT-03 | Offer description | Dynamic `offer.description` | Display-only offer description (`offers_screen.dart:128-130`) | Offer exists | N | Y |
| OFD-TXT-04 | Section heading | `Eligible products` | Labels product rows (`offers_screen.dart:131-136`) | Offer exists; heading remains even if no product maps | N | Y |
| OFD-ROW-01 | Eligible-product row | Dynamic product name; `${variantCount} variant(s) · ${priceWithUnit}`; chevron icon | Tap pushes `/product-detail` with the product ID in both `productId` and `variantId` fields (`offers_screen.dart:137-150`) | One row per offer product ID that resolves through `productById` | Y — row and product arguments must remain paired | Y |
| OFD-ACT-01 | Button | `Browse category` | Navigates to `/category-browse` with `CategoryBrowseArgs(categoryId)` (`offers_screen.dart:151-174`) | `offer.categoryId != null`; current generated offers omit category ID, so it is not shown for those offers | N | Y |

## States and messages

- Unresolved offer: app bar title `Offer`, centered `Offer not found` (`offers_screen.dart:95-103`).
- Resolved offer: title, discount, description, Eligible products heading, and zero or more rows.
- No loading indicator, empty-products message, error, success, validation, confirmation, upload, or passcode state is defined.

## Displayed values

- Offer title, discount text, description, category ID, and product IDs come from `Offer` (`offers_screen.dart:114-174`; `lib/features/catalog/domain/models/catalog_models.dart:310-331`).
- Variant count is `catalog.variantsForProduct(p.id).length`; row price is `p.priceWithUnit` (`offers_screen.dart:137-146`).
- Base product price uses `formatInr(basePrice)` and `priceWithUnit` appends ` / <unit>` (`lib/features/catalog/domain/models/catalog_models.dart:120-163`).
- Current derived offer descriptions and discounts are constructed from variant brand/display name and rounded percent by `CatalogController` (see SCR-20; `lib/core/state/catalog_controller.dart:326-335`).

## Style with meaning

- Discount is rendered in headline style using secondary color; preserve its role as the offer rate (`offers_screen.dart:120-127`).
- No selected or availability state is represented.
- Not-found state replaces all resolved-offer content (`offers_screen.dart:95-103`).

## Keyboard and focus

- No text input, custom keyboard handler, autofocus, explicit focus order, or Escape handler is defined.
- Eligible product rows use `ListTile` interaction; category action is a `FilledButton`.

## Responsive

- Resolved offer content uses a vertically scrolling `ListView`; no breakpoint is defined (`offers_screen.dart:114-179`).

## Risk notes

- `Browse category` is conditional on non-null category ID and is absent for currently generated offers, which omit that field (`catalog_controller.dart:326-335`; `offers_screen.dart:151-174`).
- Product row passes `p.id` as both `productId` and `variantId`; preserve those exact arguments unless behavior change is approved (`offers_screen.dart:137-150`).
- Product rows are derived from offer product IDs and filtered for successful product resolution; maintain row-to-product association (`offers_screen.dart:107-111,137-150`).
