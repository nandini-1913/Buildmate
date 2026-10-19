# SCR-15 — Product detail

- Route: `/product-detail` (`AppRoutes.productDetail`); arguments are `productId` and optional `variantId`
- Source files: [product_detail_screen.dart](../lib/features/catalog/presentation/screens/product_detail_screen.dart) (615 lines); [catalog_controller.dart](../lib/core/state/catalog_controller.dart); [catalog_widgets.dart](../lib/shared/widgets/catalog_widgets.dart); [catalog_models.dart](../lib/features/catalog/domain/models/catalog_models.dart)
- Purpose: Display a catalog product, let the shopper select a brand variant, set quantity, add it to cart or request a quote, and browse compatible products.

## Data

- On first frame, if `CatalogController.pipeVariants` is empty, the screen calls `refreshHomeCatalog(showLoading: false)` (`product_detail_screen.dart:30-40`). The controller fetches `GET /api/categories?active_only=true` and the pipe catalog using `GET /api/catalog?category=<pipesCategoryQuery>` with fallback to `GET /api/catalog`, then starts 3-second polling (`lib/core/state/catalog_controller.dart:358-390,394-405`; `lib/features/catalog/data/repositories/catalog_repository.dart:15-78`; `lib/core/network/api_config.dart:13-24`).
- Product variants resolve by `productId`; if no variants are found for that ID and `variantId` was passed, the screen looks up that variant and resolves its product’s variant group (`product_detail_screen.dart:48-61`). Product heading data is mapped from the selected/first variant (`product_detail_screen.dart:63-81`).
- Selecting a variant, quantity changes, system-size filtering, wishlist, cart, and recently viewed updates are local controller/widget state; these actions do not make a screen-specific API call (`product_detail_screen.dart:83-105,284-303,414-463`; `lib/core/state/catalog_controller.dart:272-317`).
- Selecting a variant records it in `RecentlyViewedController` once for the current selection; selecting another resets the guard before recording that variant (`product_detail_screen.dart:83-94,284-303`).
- System-size options are distinct sorted `Size` specifications from variants in the product’s category (`lib/core/state/catalog_controller.dart:272-280`). Compatible products are other products in the same category; an optional system-size filter matches size, spec summary, or product name, and at most 12 are returned (`catalog_controller.dart:295-317`).
- `Filter System` with no category sizes shows a floating snackbar and returns. Otherwise it opens a bottom sheet; choosing `All sizes` clears the filter, and choosing a dynamic size stores it locally (`product_detail_screen.dart:107-185`).
- `Add to Cart` adds the selected variant with `_qty` when in stock and shows a floating snackbar. `Get Quote` adds it only when in stock and not already in the cart, then navigates to `/cart` (`product_detail_screen.dart:414-463`).
- Compatible tile `Add` opens the shared brand picker and adds the selected in-stock variant to cart with snackbar; tapping its tile navigates to its product detail route (`product_detail_screen.dart:496-515,528-540,590-615`).
- Header cart opens `/cart`; header wishlist toggles the selected variant (`product_detail_screen.dart:218-239`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| PD-STATE-01 | Loading/not-found text | `Loading product…` or `Product not found` | Displays based on `catalog.isLoading || catalog.isHomeLoading` when product/variants are unresolved (`product_detail_screen.dart:191-207`) | Product unresolved; spinner is not used in this branch | N | Y |
| PD-TXT-01 | App-bar title | `Product` while unresolved; otherwise dynamic product name | Display-only title (`product_detail_screen.dart:195-196,218-221`) | Always | N | Y |
| PD-ACT-01 | Icon button | No visible text (heart icon) | Toggles selected variant in local wishlist (`product_detail_screen.dart:222-231`) | Resolved product and selected variant exists | N | Y |
| PD-ACT-02 | Icon button | No visible text (cart icon); badge label is `${cart.totalQuantity}` | Opens `/cart`; badge visible only when total cart quantity is greater than zero (`product_detail_screen.dart:232-240`) | Resolved product | N | Y |
| PD-IMG-01 | Product image | No text; product/variant image or fallback | Display-only `CategoryImage`; selected variant URL takes precedence over product URL (`product_detail_screen.dart:247-260`) | Product resolved | N | Y |
| PD-TXT-02 | Product metadata | Dynamic category name; product name; `${subCategoryName} · SKU ${sku}`; optional spec summary | Display-only product data (`product_detail_screen.dart:258-273`) | Product resolved; summary omitted when empty | N | Y |
| PD-TXT-03 | Section heading | `Select brand` | Labels variant choices (`product_detail_screen.dart:275-277`) | Product resolved | N | Y |
| PD-SEL-01 | Variant choice | Dynamic brand name, spec summary, price/unit, and stock label | Selecting a row updates selected variant ID, sets `_qty` to that variant’s minimum order quantity, resets the recently-viewed guard, and records the selected variant (`product_detail_screen.dart:278-337`) | One row per resolved variant | Y — each option must remain paired with its variant ID and details | Y |
| PD-STATE-02 | Unselected-variant guidance | `Choose a brand to view details, set quantity, and add to cart.` | Informational prompt; selected-variant detail controls are hidden (`product_detail_screen.dart:342-350`) | No variant selected (multiple variants and no valid initial variant ID) | N | Y |
| PD-RATING-01 | Rating display | Five star icons; `${selected.rating} (${selected.reviewCount})` | Display-only. Number of filled stars is `i < selected.rating.round()` (`product_detail_screen.dart:352-369`) | Variant selected | N | Y |
| PD-TXT-04 | Selected variant details | Dynamic price/unit; description | Display-only selected variant data (`product_detail_screen.dart:371-381`) | Variant selected | N | Y |
| PD-TXT-05 | Section heading and specification rows | `Specifications`; dynamic key/value rows | Displays all entries from `selected.specifications` (`product_detail_screen.dart:382-405`) | Variant selected | Y — each key remains paired with its value | Y |
| PD-TXT-06 | Minimum order display | `Minimum order: ${selected.minimumOrderQuantity} ${selected.unit}` | Display-only minimum quantity and unit (`product_detail_screen.dart:407-411`) | Variant selected | N | Y |
| PD-TXT-07 | Quantity label/value | `Quantity`; dynamic `_qty` | Quantity is initialized to 1; selecting a variant via its row sets it to that variant’s minimum order quantity (`product_detail_screen.dart:28-31,288-303,412-430`) | Variant selected | N | Y |
| PD-ACT-03 | Icon button | No visible text (minus icon) | Decrements `_qty` by one when `_qty > minimumOrderQuantity`; otherwise disabled (`product_detail_screen.dart:414-422`) | Variant selected | N | Y |
| PD-ACT-04 | Icon button | No visible text (plus icon) | Increments `_qty` by one when selected variant is in stock; otherwise disabled (`product_detail_screen.dart:422-430`) | Variant selected | N | Y |
| PD-ACT-05 | Button | `Add to Cart` | If selected variant is in stock, adds it with `_qty` and shows `${selected.displayName} added to cart`; disabled out of stock (`product_detail_screen.dart:432-451`) | Variant selected | N | Y |
| PD-ACT-06 | Button | `Get Quote` | If in stock and quantity currently in cart is zero, adds selected variant with `_qty`; then opens `/cart` (`product_detail_screen.dart:452-464`) | Variant selected; button itself remains enabled out of stock | N | Y |
| PD-TXT-08 | Section heading | `Complete System` | Labels compatible-product area (`product_detail_screen.dart:467-473`) | Product resolved | N | Y |
| PD-ACT-07 | Filter button | `Filter System` or selected system size | Opens system-size bottom sheet; no size options causes `No size filters available for this category` snackbar (`product_detail_screen.dart:107-185,474-482`) | Product resolved | N | Y |
| PD-TXT-09 | Supporting text | `Compatible products for building a complete system. The main product above stays unchanged.` | Display-only guidance (`product_detail_screen.dart:484-489`) | Product resolved | N | Y |
| PD-STATE-03 | Empty compatible-products state | `No compatible products found for this filter.` | Replaces compatible list when `compatible` is empty (`product_detail_screen.dart:490-497`) | Product resolved, compatibility result empty | N | Y |
| PD-COMP-01 | Compatible product tile | Dynamic brand/subcategory, product name, size/spec, price/unit | Tile tap opens product detail with the compatible product ID and no variant ID (`product_detail_screen.dart:498-515,528-589`) | Up to 12 compatible products | Y — each row and its product ID/action remain paired | Y |
| PD-COMP-ACT-01 | Button | `Add` | Opens brand picker; if selected in-stock variant exists, adds it to cart and shows `${variant.displayName} added to cart` snackbar (`product_detail_screen.dart:590-615`) | Each compatible product tile | N | Y |
| PD-MODAL-01 | Bottom-sheet heading | `Filter System (Size)` | Labels system-size chooser (`product_detail_screen.dart:125-146`) | System-size filter opened with available choices | N | Y |
| PD-MODAL-02 | Bottom-sheet choice | `All sizes`; dynamic size labels | `All sizes` returns empty string to clear selected size; each size returns that size and updates page filter after modal closes (`product_detail_screen.dart:149-176`) | System-size chooser open | Y — each option returns its corresponding filter value | Y |
| PD-MSG-01 | Snackbar | `No size filters available for this category` | Floating snackbar; chooser is not opened (`product_detail_screen.dart:107-116`) | Product category has no size options | N | Y |
| PD-MSG-02 | Snackbar | `${selected.displayName} added to cart` or `${variant.displayName} added to cart` | Success feedback after selected product or compatible product add action; behavior floating (`product_detail_screen.dart:439-447,596-603`) | An in-stock variant is added | N | Y |

## States and messages

- If product cannot be resolved, the screen shows `Loading product…` while catalog loading/home loading is true; otherwise `Product not found` (`product_detail_screen.dart:191-207`).
- Product with multiple variants and no selected initial variant shows `Choose a brand to view details, set quantity, and add to cart.`; variant-dependent specifications, quantity and cart controls are not shown until selection (`product_detail_screen.dart:342-350,352-464`).
- No category size options: `No size filters available for this category` floating snackbar and no modal (`product_detail_screen.dart:107-116`).
- Complete System with no matching compatible products: `No compatible products found for this filter.` (`product_detail_screen.dart:490-497`).
- Adding an in-stock selected/compatible variant shows dynamic `... added to cart` snackbar (`product_detail_screen.dart:432-451,590-615`).
- No confirmation, form validation, upload, or passcode popup is defined.

## Displayed values

- Title/product name, category, SKU, subcategory, specifications, image, description, and variant data come from resolved catalog product/variant (`product_detail_screen.dart:48-81,218-405`).
- Variant row and primary selected price use `ProductVariant.priceWithUnit`, with `priceLabel` via `formatInr(price)` and suffix ` / <unit>` (`lib/features/catalog/domain/models/catalog_models.dart:256-272`).
- Rating text shows the unrounded rating and review count; filled stars use rounded rating, with five total icons (`product_detail_screen.dart:352-369`).
- Minimum order line shows minimum quantity and variant unit. Quantity is a local integer, has a floor at minimum order quantity for decrement, and plus is stock-gated (`product_detail_screen.dart:28-31,288-303,407-430`).
- Cart badge displays total cart quantity and is hidden at zero (`product_detail_screen.dart:232-240`).
- System size list is sorted unique category size values (`lib/core/state/catalog_controller.dart:272-280`). Compatible list filters same-category products by size text in specification, summary, or name, then truncates to 12 (`catalog_controller.dart:295-317`).
- Compatible row displays cheapest variant brand or subcategory fallback; size field or `specSummary` fallback; cheapest variant price/unit or base product price/unit (`product_detail_screen.dart:546-589`).

## Style with meaning

- Selected brand row uses selected styling and a checked radio icon; unselected rows use the alternate surface and radio icon (`product_detail_screen.dart:284-310`).
- Header wishlist icon fill/error color indicates whether the selected variant is saved (`product_detail_screen.dart:222-231`).
- Rating stars distinguish rounded rating from the remaining stars (`product_detail_screen.dart:352-364`).
- Stock state uses `StockStatusChip`; this caller passes `inStock`, so the visible state is `In Stock` or `Out of Stock` (`product_detail_screen.dart:325-337`; `lib/shared/widgets/catalog_widgets.dart:15-58`).
- Out-of-stock selected variants disable plus and Add to Cart, but Get Quote remains enabled and still navigates to cart (`product_detail_screen.dart:422-464`). Keep stock distinction and gating.

## Keyboard and focus

- No text entry, custom keyboard shortcut, explicit focus order, autofocus, or Escape handler is defined.
- Filter chooser and brand picker use Flutter modal bottom-sheet back/barrier behavior. Buttons and selectable rows use standard Material interaction feedback.

## Responsive

- Product detail content is a vertically scrolling `ListView` with full-width content and no breakpoint (`product_detail_screen.dart:241-252`).
- System-size chooser is capped at 55% of screen height and uses a flexible scrolling list (`product_detail_screen.dart:119-179`).
- Compatible list is limited to 12 products, not viewport-sized (`lib/core/state/catalog_controller.dart:295-317`).

## Risk notes

- Product and variant resolution are route-argument dependent; preserve both `productId` and optional `variantId` (`product_detail_screen.dart:48-81`).
- Variant row tap changes selected variant, quantity minimum, and recent-view recording; keep row tap and variant identity paired (`product_detail_screen.dart:284-303`).
- The selected variant guards most detail actions, while Get Quote remains available out of stock and still opens cart; preserve this actual behavior (`product_detail_screen.dart:342-464`).
- `_qty` starts at 1 and is reset to `minimumOrderQuantity` only when a variant row is tapped; a route-preselected/auto-selected variant does not run that handler at initialization (`product_detail_screen.dart:28-31,70-81,284-303`).
- System-size selection affects only compatible-product results; explanatory text explicitly states the main product remains unchanged (`product_detail_screen.dart:211-214,484-489`; `catalog_controller.dart:295-317`).
- Compatible tile tap and nested `Add` have distinct navigation/cart effects; retain separate hit targets (`product_detail_screen.dart:528-540,590-615`).
