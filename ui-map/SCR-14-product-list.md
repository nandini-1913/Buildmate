# SCR-14 — Product list

- Route: `/product-list` (`AppRoutes.productList`); also rendered by generic `/category-browse` and the brand-products wrapper
- Source files: [product_list_screen.dart](../lib/features/catalog/presentation/screens/product_list_screen.dart) (374 lines); [catalog_filter_sheet.dart](../lib/shared/widgets/catalog_filter_sheet.dart) (filter modal); [catalog_widgets.dart](../lib/shared/widgets/catalog_widgets.dart) (stock chip, brand picker, action bars)
- Purpose: Show catalog products or brand-specific variants, with local filters, product navigation, cart, wishlist, and quote actions.

## Data

- `initState` initializes `CatalogFilterState` with the incoming subcategory ID. After the first frame, if `CatalogController.pipeVariants` is empty, it calls `refreshHomeCatalog(showLoading: false)` (`product_list_screen.dart:30-44`).
- `refreshHomeCatalog` fetches categories and pipe catalog in parallel. The repository requests `GET /api/categories?active_only=true`, then first `GET /api/catalog?category=<pipesCategoryQuery>` and on filtered-fetch failure falls back to `GET /api/catalog`; the controller starts the 3-second pipe catalog polling afterward (`lib/core/state/catalog_controller.dart:358-390,394-405`; `lib/features/catalog/data/repositories/catalog_repository.dart:15-78`; `lib/core/network/api_config.dart:13-24`).
- Generic products are taken from, in priority order: filtered pipe variants for a supplied subcategory; products for supplied category; featured products when title is exactly `Featured Products`; popular products when title is exactly `Popular Products`; an empty list when title is exactly `Recently Viewed`; otherwise all catalog products (`product_list_screen.dart:48-69`).
- Generic product filtering, sorting, brand/variant resolution, and displayed variant counts are local `CatalogController` operations; the filter modal does not make an API request (`product_list_screen.dart:103-120`; `lib/core/state/catalog_controller.dart:215-278`).
- Brand-specific branch uses `variantsByBrand(brandId)` and renders one variant tile per result (`product_list_screen.dart:97-136`; `catalog_controller.dart:154-155`).
- `Filter / Sort` opens `showCatalogFilterSheet` with the current filter, category ID resolved from widget/category/pipe variant, and local subcategory/brand choices. Apply returns state to the list; Reset changes only the modal's draft state until applied (`product_list_screen.dart:71-94`; `catalog_filter_sheet.dart:29-77,280-305`).
- Search action navigates to `/search` with empty `SearchArgs`; cart action navigates to `/cart` (`product_list_screen.dart:136-151`).
- Product row actions use `ProductActionBar`: brand selection is local; add-to-cart and quote update the shared cart controller; wishlist toggles the local `WishlistController` (`lib/shared/widgets/catalog_widgets.dart:66-187`).
- Variant row actions use `VariantActionBar`: wishlist toggles locally; quantity controls call cart increase/decrease; add action adds an in-stock variant; quote action conditionally adds an in-stock variant then navigates to `/cart` (`catalog_widgets.dart:280-375`).
- Product and variant card taps navigate to `/product-detail`, passing product and optional variant IDs (`product_list_screen.dart:180-195,305-323`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| PL-BRAND-TXT-01 | App-bar title | `widget.title` or `Brand products` | Dynamic title in brand-ID branch (`product_list_screen.dart:97-108`) | `brandId != null` | N | Y |
| PL-BRAND-STATE-01 | Loading indicator | No text | Circular progress while `catalog.isLoading && variants.isEmpty` (`product_list_screen.dart:109-112`) | Brand branch loading with no variants | N | Y |
| PL-BRAND-STATE-02 | Empty state | `No products found` | Replaces variant list if no matching variants (`product_list_screen.dart:112-114`) | Brand branch has no variants after loading | N | Y |
| PL-BRAND-CARD-01 | Variant tile | Dynamic image, brand, product name, spec summary, formatted price/unit, and stock label | Whole tile tap navigates to product detail with variant ID (`product_list_screen.dart:115-134,287-374`) | Brand branch has variants | Y — each tile’s product/variant and actions remain paired | Y |
| PL-ACT-01 | Icon button | No visible text (search icon) | Opens `/search` with empty args (`product_list_screen.dart:136-146`) | Non-brand branch | N | Y |
| PL-ACT-02 | Icon button | No visible text (shopping-cart icon) | Opens `/cart` (`product_list_screen.dart:147-151`) | Non-brand branch | N | Y |
| PL-FLT-01 | Extended floating button | `Filter · On` or `Filter / Sort` | Opens filter modal; label reflects `CatalogFilterState.hasActiveFilters` (`product_list_screen.dart:153-160`; `catalog_filter_sheet.dart:56-59`) | Non-brand branch | N | Y |
| PL-STATE-01 | Loading indicator | No text | Circular progress when `catalog.isLoading && products.isEmpty` (`product_list_screen.dart:162-164`) | Non-brand branch, loading with no matching products | N | Y |
| PL-STATE-02 | Empty state | `No products found` | Replaces generic product list (`product_list_screen.dart:163-165`) | Non-brand branch has no filtered products after loading | N | Y |
| PL-CARD-01 | Product card | Dynamic image, brand name or subcategory fallback, product name, spec summary, `<n> variant(s)`, price or `From <price>`, stock label | Whole-card tap opens product detail with cheapest-variant product/variant IDs (`product_list_screen.dart:172-194,196-259`) | Non-brand branch has products | Y — keep each card’s product and nested actions paired | Y |
| PL-CARD-ACT-01 | Icon button | Tooltip `Wishlist`; no visible text (heart icon) | Opens brand picker if multiple variants, then toggles selected variant in wishlist (`catalog_widgets.dart:66-76,113-135,180-201`) | Product card action bar | N | Y |
| PL-CARD-ACT-02 | Button | `Add to Cart` | Opens brand picker (returns sole variant directly when exactly one); if selection exists and is in stock, adds variant and shows `${variant.displayName} added to cart` snackbar (`catalog_widgets.dart:66-78,139-160,206-220`) | Product card action bar; action may return without change when no variant or selected variant out of stock | N | Y |
| PL-CARD-ACT-03 | Icon button | Tooltip `Get Quote`; no visible text (quote icon) | Opens brand picker; if chosen variant is in stock and absent from cart, adds it; then navigates to `/cart` (`catalog_widgets.dart:162-176,224-231`) | Product card action bar (`showQuote` defaults to true) | N | Y |
| PL-MODAL-01 | Modal heading | `Filter / Sort` | Labels bottom-sheet filter modal (`catalog_filter_sheet.dart:29-77,135-145`) | Filter modal open | N | Y |
| PL-MODAL-ACT-01 | Icon button | No visible text (close icon) | Pops modal without returning filter state (`catalog_filter_sheet.dart:143-147`) | Filter modal open | N | Y |
| PL-FLT-02 | Filter section and chips | `Subcategory`, `All`, dynamic subcategory names | Choices update draft subcategory ID; `All` clears it (`catalog_filter_sheet.dart:156-181`) | Subcategory options were supplied | Y — each chip selects its corresponding ID | Y |
| PL-FLT-03 | Filter section and chips | `Size`, `All`, dynamic size labels | Choices update draft size; `All` clears it (`catalog_filter_sheet.dart:184-207`) | Category has size options | Y — each chip selects its value | Y |
| PL-FLT-04 | Filter section and chips | `Material`, `All`, dynamic material labels | Choices update draft material; `All` clears it (`catalog_filter_sheet.dart:210-233`) | Category has material options | Y — each chip selects its value | Y |
| PL-FLT-05 | Filter section and chips | `Brand`, `All`, dynamic brand names | Choices update draft brand ID; `All` clears it (`catalog_filter_sheet.dart:238-261`) | Brand options were supplied | Y — each chip selects its corresponding ID | Y |
| PL-FLT-06 | Filter section and chips | `Sort by`; `Popularity`; `Price Low → High`; `Price High → Low`; `Newest`; `Brand A → Z` | Choices update draft `ProductSort` (`catalog_filter_sheet.dart:264-282,309-325`) | Filter modal open | Y — labels must retain enum mapping; source enum order is popularity, low/high price, newest, brand A-Z (`lib/features/catalog/domain/models/catalog_models.dart:278-284`) | Y |
| PL-MODAL-ACT-02 | Button | `Reset` | Resets modal draft to default `CatalogFilterState()`; does not itself close or apply (`catalog_filter_sheet.dart:285-297`) | Filter modal open | N | Y |
| PL-MODAL-ACT-03 | Button | `Apply Filters` | Pops modal with current draft; caller replaces list filter state if non-null and mounted (`catalog_filter_sheet.dart:298-305`; `product_list_screen.dart:88-94`) | Filter modal open | N | Y |
| PL-VAR-ACT-01 | Icon button | No visible text (heart icon) | Toggles wishlist for this variant ID (`catalog_widgets.dart:280-318`) | Brand variant tile | N | Y |
| PL-VAR-ACT-02 | Quantity control | No visible text (minus/plus icons); dynamic quantity | Minus calls `CartController.decrease`; plus calls `increase` only when in stock (`catalog_widgets.dart:319-328`) | Variant already has quantity > 0; plus disabled when out of stock | N | Y |
| PL-VAR-ACT-03 | Button | `Add to Cart` | Adds variant and shows `${variant.displayName} added to cart`; disabled when out of stock (`catalog_widgets.dart:329-350`) | Variant tile quantity is zero | N | Y |
| PL-VAR-ACT-04 | Icon button | No visible text (quote icon) | If quantity is zero and variant is in stock, adds it; then navigates to `/cart` (`catalog_widgets.dart:352-375`) | Brand variant tile | N | Y |

## States and messages

- In either branch, a circular indicator appears only when `catalog.isLoading` and the branch’s corresponding result list is empty (`product_list_screen.dart:109-114,162-165`).
- Empty brand and generic result lists both display `No products found` (`product_list_screen.dart:112-114,163-165`).
- Product-action add-to-cart snackbar text is `${variant.displayName} added to cart`; the product action variant uses floating behavior and a 2-second duration (`catalog_widgets.dart:153-160`). The variant-row action snackbar uses the same text with floating behavior and no explicit duration (`catalog_widgets.dart:331-339`).
- Brand picker is a bottom sheet only when more than one variant exists; no variants returns null and one variant returns directly without UI. The sheet title is `Select brand`, followed by product name and each variant’s brand, price/unit, and stock label (`catalog_widgets.dart:66-137`).
- Filter sections are omitted when their option lists are empty. Filter modal has no separate loading/error/success message (`catalog_filter_sheet.dart:98-282`).
- Modal can be dismissed using close icon, platform/back dismissal, or bottom-sheet barrier; only `Apply Filters` returns the draft state (`catalog_filter_sheet.dart:29-77,143-147,298-305`).
- No confirmation, validation, upload, or passcode popup is defined by this screen or its listed actions.

## Displayed values

- Product source selection is controlled by route arguments/title, with `Recently Viewed` specifically producing an empty list (`product_list_screen.dart:48-69`).
- Product card brand is cheapest variant’s brand, or product subcategory when no cheapest variant exists. Variant count is `variants.length`; price is `From ${from.priceWithUnit}` when a cheapest variant exists, otherwise `product.priceWithUnit` (`product_list_screen.dart:172-175,222-251`).
- Base product `priceLabel` formats `basePrice` with `formatInr`; `priceWithUnit` appends ` / <unit>` (`lib/features/catalog/domain/models/catalog_models.dart:120-163`). Variant `priceWithUnit` similarly formats variant price and appends unit (`catalog_models.dart:256-272`).
- Stock chip with the bool parameter renders `In Stock` for `true` and `Out of Stock` for `false`. Its status-parameter form supports `Limited Stock`; product list passes only `inStock` bool, so this screen’s list rows do not show that third state (`lib/shared/widgets/catalog_widgets.dart:15-58`; `product_list_screen.dart:173-175,236-258,341-355`).
- Wishlist icon switches between filled and outline according to the selected product/variant’s current local wishlist state (`catalog_widgets.dart:184-203,294-318`).
- Variant tile quantity is `CartController.quantityOf(variant.id)`; it replaces `Add to Cart` when greater than zero (`catalog_widgets.dart:286-348`).
- Filter button shows `Filter · On` if any filter or non-default sort is active; otherwise `Filter / Sort` (`catalog_filter_sheet.dart:56-59`; `product_list_screen.dart:153-160`).
- Filter-modal size and material option labels come from category attributes; brand and subcategory labels come from supplied catalog metadata (`catalog_filter_sheet.dart:98-132,156-261`).

## Style with meaning

- Stock chips encode stock state by label and color: `In Stock`/success, `Limited Stock`/warning, `Out of Stock`/error (`catalog_widgets.dart:15-58`). Keep states distinguishable; this list currently passes a boolean and only renders the first/third state.
- Wishlist heart fill and error color distinguish saved from unsaved (`catalog_widgets.dart:184-203,294-318`).
- Selected filter chips represent draft selection. The active filter button’s `Filter · On` copy represents whether any filter or non-default sort is applied (`catalog_filter_sheet.dart:56-59,160-282`; `product_list_screen.dart:153-160`).
- Out-of-stock variant Add to Cart and quantity plus controls are disabled; preserve disabled feedback and gating (`catalog_widgets.dart:329-350`).
- Loading and empty states replace the list; retain their mutual exclusivity and copy.

## Keyboard and focus

- No text input or custom keyboard shortcut/focus behavior is defined in ProductListScreen or its filter/brand sheets.
- No explicit Escape handler or custom focus order is defined. Modal back/barrier dismissal follows Flutter bottom-sheet behavior. Buttons and cards use Material/InkWell interaction feedback.

## Responsive

- Generic list and brand-specific list use vertically scrolling separated lists; cards have no fixed cross-axis column count (`product_list_screen.dart:114-134,165-177`).
- Filter modal is scroll-controlled, accounts for keyboard inset, and caps height at 78% of available screen height (`catalog_filter_sheet.dart:79-109`).
- Brand picker height is 45% of screen height clamped between 220 and 420 logical pixels (`catalog_widgets.dart:85-91`).
- Compact product action bar uses a wrapping/expanded row layout; variant action bar is a row (`catalog_widgets.dart:180-279,286-375`).
- No breakpoint or alternate navigation layout is defined.

## Risk notes

- The same `ProductListScreen` is delegated to by generic `/category-browse`; `/brand-products` can also supply `brandId`. Preserve argument-driven branch selection and use the same contract when styling those routes (`category_browse_screen.dart:14-27`; `lib/core/routes/app_router.dart:130-157`).
- Product cards are tappable while containing nested action controls; retain the independent child action hit targets and each action’s callback (`product_list_screen.dart:180-258`).
- Product card navigation selects the cheapest available variant, while nested product actions can show a brand picker; do not conflate these independent flows (`product_list_screen.dart:172-194`; `catalog_widgets.dart:66-176`).
- Brand picker cardinality matters: zero/one/multiple variants lead respectively to no result/direct selection/modal (`catalog_widgets.dart:66-137`).
- Filter selections are draft state inside the bottom sheet until Apply; Reset resets that draft, and close/cancel does not apply it (`catalog_filter_sheet.dart:75-77,285-305`).
- Variant quantity controls depend on each variant’s cart quantity and stock state; their layout may change but IDs, stock gating, and button semantics must remain paired (`catalog_widgets.dart:286-375`).
