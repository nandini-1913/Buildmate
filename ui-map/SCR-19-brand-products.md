# SCR-19 — Brand products

- Route: `/brand-products` (`AppRoutes.brandProducts`); route argument: `BrandProductsArgs.brandId`
- Source files: [brands_screen.dart](../lib/features/catalog/presentation/screens/brands_screen.dart) (84 lines; `BrandProductsScreen` at lines 64-81); [app_router.dart](../lib/core/routes/app_router.dart); [product_list_screen.dart](../lib/features/catalog/presentation/screens/product_list_screen.dart)
- Purpose: Resolve a brand ID to a title and render that brand’s variant list.

## Data

- Router reads optional `BrandProductsArgs`; absent args yield empty brand ID (`lib/core/routes/app_router.dart:165-173`).
- `BrandProductsScreen` watches `CatalogController.brandById(brandId)` and delegates to `ProductListScreen(brandId, title)`; title is the live brand name or `Brand Products` fallback (`brands_screen.dart:64-81`).
- The brand-ID branch reads `variantsByBrand(brandId)` and displays its variant list. It does not start a fetch itself; catalog lifecycle is shared (`product_list_screen.dart:97-136`; `lib/core/state/catalog_controller.dart:127-135,154-155`).
- Variant tile navigation, loading/empty states, action bar behavior, stock state, cart/wishlist/quote behavior and displayed variant values are fully specified in the brand branch of [SCR-14](./SCR-14-product-list.md). This screen must retain that contract unchanged.
- No API call or filter request is initiated by the brand-products wrapper.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| BPR-TXT-01 | App-bar title | Dynamic brand name or `Brand Products` | Wrapper resolves brand ID and supplies title to product list (`brands_screen.dart:73-80`); displayed by shared brand branch (`product_list_screen.dart:97-108`) | Always; fallback when brand ID does not resolve | N | Y |
| BPR-STATE-01 | Loading, empty, or result list | No visible text while loading; empty text `No products found`; otherwise dynamic brand variant rows | Exact condition and row actions are the brand-ID branch of `ProductListScreen` (`product_list_screen.dart:97-136,287-374`); see SCR-14 contract | `catalog.isLoading && variants.isEmpty`, `variants.isEmpty` after loading, or variants available | Y — variant order and tile-to-variant pairing must be retained | Y |

## States and messages

- While loading with no brand variants: circular progress indicator.
- After loading with no variants for the supplied brand ID: `No products found`.
- With variants: one row per brand variant, with the shared `VariantActionBar` controls and stock labels documented in SCR-14 (`product_list_screen.dart:109-134,287-374`).
- No wrapper-specific success, error, validation, or confirmation message exists.

## Displayed values

- App-bar title resolves to `brand.name`, or exact fallback `Brand Products` (`brands_screen.dart:73-80`).
- Product/variant values and formatting are identical to SCR-14 brand variant tiles; the route’s `brandId` scopes the data (`product_list_screen.dart:97-136,287-374`).

## Style with meaning

- Reuses SCR-14 brand list’s stock and wishlist states. Preserve their distinction and control gating (`lib/shared/widgets/catalog_widgets.dart:15-58,280-375`).

## Keyboard and focus

- No wrapper-specific input, keyboard handler, focus behavior, or Escape handler. The delegated variant list uses the SCR-14 contract.

## Responsive

- Uses SCR-14’s vertically scrolling separated variant list and compact action bar; no separate breakpoint is defined (`product_list_screen.dart:115-134,287-374`).

## Risk notes

- Keep brand ID passed by router, brand title fallback, and list scope paired (`lib/core/routes/app_router.dart:165-173`; `brands_screen.dart:73-80`).
- `BrandProductsScreen` is a thin wrapper; changes to its rendered controls must match SCR-14 rather than creating a divergent list contract (`brands_screen.dart:73-81`).
