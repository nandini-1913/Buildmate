# SCR-18 — Brands

- Route: `/brands` (`AppRoutes.brands`)
- Source files: [brands_screen.dart](../lib/features/catalog/presentation/screens/brands_screen.dart) (84 lines); [brand_logo.dart](../lib/shared/widgets/brand_logo.dart); [catalog_controller.dart](../lib/core/state/catalog_controller.dart)
- Purpose: List live catalog brands and navigate to the selected brand’s products.

## Data

- Screen reads `CatalogController.catalogBrands`, which derives unique brands from current API variants (`brands_screen.dart:14-18`; `lib/core/state/catalog_controller.dart:133-135,476-502`).
- No fetch is initiated by this screen. Catalog loading/refresh is handled by shared `CatalogController` app flows; the view uses `catalog.isLoading` only to decide whether to show the empty-list loading state (`brands_screen.dart:22-29`).
- Brand rows display the brand name and `Brand.productCount`; controller computes `productCount` as the count of variants with matching brand ID, not distinct base products (`brands_screen.dart:37-54`; `catalog_controller.dart:491-501`).
- Tapping a row navigates to `/brand-products` and passes that row’s `brandId` (`brands_screen.dart:50-59`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| BRD-TXT-01 | App-bar title | `Top Brands` | Static screen title (`brands_screen.dart:19-23`) | Always | N | Y |
| BRD-STATE-01 | Loading indicator | No text | Circular progress indicator (`brands_screen.dart:24-26`) | `catalog.isLoading && brands.isEmpty` | N | Y |
| BRD-STATE-02 | Empty state | `No brands from server yet` | Replaces brand list (`brands_screen.dart:26-29`) | Brand list empty and not in loading branch | N | Y |
| BRD-ROW-01 | Brand row | Dynamic logo/abbreviation, brand name, `${brand.productCount} products`, chevron icon | Tap opens `/brand-products` with the row brand ID (`brands_screen.dart:30-60`) | One row per catalog brand | Y — row content and brand ID must remain paired; current list sorts brand name ascending in controller | Y |
| BRD-IMG-01 | Brand logo | No text when logo loads; dynamic abbreviation fallback | `BrandLogo` displays local asset when supplied; empty/missing asset falls back to circle with abbreviation (`brands_screen.dart:40-47`; `lib/shared/widgets/brand_logo.dart:15-53`) | Each brand row | N | Y |

## States and messages

- Empty while loading: centered circular progress indicator (`brands_screen.dart:24-26`).
- Empty after loading: `No brands from server yet` (`brands_screen.dart:26-29`).
- Loaded state: vertically separated brand rows; no error, confirmation, success, validation, or snackbar message is defined.

## Displayed values

- Brand name and ID come from unique catalog variant brands; ordering is ascending by brand name (`lib/core/state/catalog_controller.dart:476-502`).
- Product count is `number of _apiVariants where variant.brandId == brand.id` (`catalog_controller.dart:491-501`); displayed literally as `${brand.productCount} products` (`brands_screen.dart:49-51`).
- Logo uses `logoAsset`, `abbreviation`, `color`, and fixed size 44 (`brands_screen.dart:40-47`; `lib/shared/widgets/brand_logo.dart:8-14`).
- Fallback logo circle uses brand color at 12% alpha and abbreviation text; image load failure also uses this fallback (`brand_logo.dart:15-53`).

## Style with meaning

- The brand’s configured color is used for its initials fallback; retain per-brand association if the logo asset is unavailable (`brands_screen.dart:40-47`; `brand_logo.dart:15-53`).
- Loading and empty states replace the list and must remain distinguishable. No selected or stock state is represented.

## Keyboard and focus

- No text input, keyboard shortcut, explicit focus order, autofocus, or Escape handler is defined.
- Brand rows use Material `ListTile` tap behavior.

## Responsive

- Brand list uses a vertically scrolling `ListView.separated` with fixed padding and spacing; no breakpoint is defined (`brands_screen.dart:30-35`).
- Brand logo size is fixed at 44 logical pixels (`brands_screen.dart:40-47`).

## Risk notes

- Each brand tile navigates with that tile’s ID; preserve row-to-brand argument pairing (`brands_screen.dart:50-59`).
- `BrandProductsScreen` is defined in the same file but is a separate `/brand-products` route and delegates to `ProductListScreen`; its list/variant behavior is covered by SCR-14 (`brands_screen.dart:64-81`; `lib/core/routes/app_router.dart:163-173`).
- Brand product count is computed from variants despite its `products` label; preserve the existing value/formula unless approved (`lib/core/state/catalog_controller.dart:491-501`).
