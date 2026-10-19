# SCR-12 — Categories

- Route: `/categories` (`AppRoutes.categories`)
- Source: [category_browse_screen.dart](../lib/features/catalog/presentation/screens/category_browse_screen.dart) — 142 lines; [catalog_controller.dart](../lib/core/state/catalog_controller.dart); [catalog_repository.dart](../lib/features/catalog/data/repositories/catalog_repository.dart)
- Purpose: Display the loaded category grid and open the selected category's product browse route.

## Data

- Screen itself reads `CatalogController.homeCategories`, `isHomeLoading`, and `error`; it does not initiate a fetch (`category_browse_screen.dart:56-79`).
- Catalog data is loaded by the app-level `CatalogController` startup/polling and Home refresh. Category repository method is `fetchCategories(activeOnly: true)` → `GET /api/categories?active_only=true` (`lib/main.dart:53-63`; `catalog_controller.dart:358-388,402-430`; `catalog_repository.dart:15-31`; API prefix `lib/core/network/api_config.dart:13-20`).
- Tapping category sends `categoryId` and `categoryName` to `/category-browse` (`category_browse_screen.dart:93-106`). Router may render `PipesFittingCategoryScreen` instead for a pipes category; otherwise it opens generic `CategoryBrowseScreen` (`lib/core/routes/app_router.dart:111-130`).
- No additional request is made directly by this screen on open or card tap.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| CAT-BTN-01 | App-bar back button | No visible text (default back arrow, if route can pop) | Flutter `AppBar` implicit leading navigation; no explicit callback in source (`category_browse_screen.dart:44-53`) | Standalone `/categories` route when navigator can pop; absent in shell tab body | N | Y |
| CAT-TXT-01 | App-bar title | `Categories` | Static `AppBar.title` (`category_browse_screen.dart:44-53`) | Standalone `/categories` route; no tab title from this widget in shell body | N | Y |
| CAT-STATE-01 | Loading indicator | No visible text | Circular progress while `catalog.isHomeLoading && categories.isEmpty` (`category_browse_screen.dart:68-72`) | Loading and no categories | N | Y |
| CAT-STATE-02 | Empty/error message | `catalog.error` or fallback `No categories from server` | Centered text when category list empty and not in loading branch (`category_browse_screen.dart:74-82`) | Categories empty, not currently loading | N | Y |
| CAT-CARD-01 | Category card | Dynamic category name; `${category.itemCount} products`; category image/fallback icon | Whole card tap navigates to `/category-browse` with matching category id/name (`category_browse_screen.dart:84-137`) | One card per loaded category | Y — card tap must submit that category's ids/name | Y |

## States and messages

- Loading with no category data: centered spinner (`category_browse_screen.dart:68-72`).
- Empty after loading: displays `catalog.error` if non-null; otherwise exact fallback `No categories from server` (`category_browse_screen.dart:74-82`). Catalog controller sets error to `e.toString()` on refresh failure (`catalog_controller.dart:378-391`).
- Categories loaded: grid of category cards (`category_browse_screen.dart:84-137`).
- No success, validation, confirmation, or snackbar message is defined.

## Displayed values

- Category title is `Category.name`; item count is `${Category.itemCount} products` (`category_browse_screen.dart:124-133`).
- Card image prefers `imageUrl`/`imageAsset`, then fallback icon/color/background (`category_browse_screen.dart:108-121`; `category_image.dart`).
- Category ordering follows `CatalogController.homeCategories`; this screen does not sort (`category_browse_screen.dart:62-64,84-105`).

## Style with meaning

- Loading and empty/error states replace the grid (`category_browse_screen.dart:68-84`).
- No selected, availability, or business-status color coding is defined.
- Category image may fall back to icon; preserve fallback distinction if images fail (`category_browse_screen.dart:108-121`).

## Keyboard and focus

- No text input, keyboard handler, or custom focus order.
- No explicit Escape behavior. Category cards use Flutter `InkWell` feedback.

## Responsive

- Grid has two fixed columns, spacing from `AppSpacing`, child aspect ratio 0.92 (`category_browse_screen.dart:84-94`).
- No breakpoint or alternate layout is defined.

## Risk notes

- The exact category ID/name pair is passed to route resolution; keep each card callback tied to its own category (`category_browse_screen.dart:93-106`).
- `CategoriesGrid` is also embedded as `CategoriesTabBody` in `MainShell`; there it has no enclosing `CategoriesScreen` app bar (`category_browse_screen.dart:31-37,40-53`; `main_shell.dart:149-166`).
- Pipe categories resolve to a different screen through `AppRouter`; visual changes must not bypass that routing condition (`app_router.dart:111-130`).
