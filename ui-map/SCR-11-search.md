# SCR-11 — Search

- Route: `/search` (`AppRoutes.search`)
- Source: [search_screen.dart](../lib/features/catalog/presentation/screens/search_screen.dart) — 229 lines; [catalog_controller.dart](../lib/core/state/catalog_controller.dart); [catalog_api_mapper.dart](../lib/features/catalog/data/mappers/catalog_api_mapper.dart)
- Purpose: Search currently loaded catalog categories and product variants, then open a selected category or variant.

## Data

- On open, initialize input from optional `SearchArgs.initialQuery` after trimming; if catalog variants or categories are empty, call `CatalogController.refreshHomeCatalog()` (`search_screen.dart:22-39`; args `lib/core/routes/app_routes.dart:107-110`).
- No dedicated search API method/path is called. Search is performed locally against loaded data:
  - variants: case-insensitive substring matching across product name, display name, brand, SKU, category, subcategory, pipe type and spec summary (`catalog_controller.dart:88-101`);
  - categories: case-insensitive substring matching against category name (`catalog_controller.dart:104-112`).
- Catalog loading uses the endpoints documented for SCR-10: `GET /api/categories?active_only=true` and `GET /api/catalog?category=<pipes query>` with fallback `GET /api/catalog` (`catalog_repository.dart:15-61`).
- Tapping category opens `/category-browse` with category id/name (`search_screen.dart:59-67`); router may resolve pipe categories to the pipes-specific browse screen (`lib/core/routes/app_router.dart:111-130`).
- Tapping product opens `/product-detail` with product id and variant id (`search_screen.dart:49-57`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| SRC-IN-01 | Search input | Placeholder `Search products, brands or categories` | Autofocuses; typing updates query/results; search keyboard submit updates query (`search_screen.dart:83-97`) | Always | Y — query drives all result/state branches | Y |
| SRC-BTN-01 | Clear icon button | Tooltip `Clear`; no visible text (close icon) | Clears controller and query (`search_screen.dart:99-109`) | When `_query.isNotEmpty` | N | Y |
| SRC-STATE-01 | Empty-query/loading message | `Loading catalog…` or `Type to search products, brands or categories` | With blank/whitespace query, chooses loading copy when home/catalog loading, otherwise prompt (`search_screen.dart:75-124`) | When trimmed query is empty | N | Y |
| SRC-STATE-02 | No-results message | `No results for “$_query”` | Shown when query has non-whitespace text and both result lists are empty (`search_screen.dart:73-80,125-133`) | Query present, no category/product matches | N | Y |
| SRC-TXT-01 | Results section heading | `Categories` | Labels category results (`search_screen.dart:135-142`) | When category result list is non-empty | N | Y |
| SRC-ROW-01 | Category result row | Dynamic category name; `${c.itemCount} products`; trailing chevron | Tap opens category browse with category id/name (`search_screen.dart:143-169`) | One row per matching category | N | Y |
| SRC-TXT-02 | Results section heading | `Products` | Labels product results (`search_screen.dart:173-180`) | When product result list is non-empty | N | Y |
| SRC-ROW-02 | Product result row | Dynamic product name; `${brandName} · ${categoryName}` plus optional ` · ${sku}`; `₹${price.toStringAsFixed(0)}` | Tap opens product detail with product/variant ids (`search_screen.dart:181-222`) | One row per matching variant | N | Y |
| SRC-VIS-01 | Category/product thumbnail | No fixed visible text; image or fallback icon | `CategoryImage` uses API/local image and fallback icon; no handler separate from row (`search_screen.dart:145-156,188-199`) | On each category/product row | N | Y |

## States and messages

- Initial: query/controller set from trimmed `initialQuery`; search field autofocuses (`search_screen.dart:27-39,83-86`).
- Empty query: show `Loading catalog…` when `catalog.isHomeLoading || catalog.isLoading`, otherwise `Type to search products, brands or categories` (`search_screen.dart:111-124`).
- Query with no category/product matches: `No results for “$_query”` (`search_screen.dart:73-80,125-133`).
- Results: show `Categories` section only when categories match, `Products` section only when variants match; both may appear (`search_screen.dart:135-223`).
- Catalog errors are not rendered by this screen; it responds to controller loading/data values and may show empty-query prompt or no-results text (`search_screen.dart:111-133`).
- No success, validation, confirmation, or error dialog/message is defined.

## Displayed values

- Initial query is `(initialQuery ?? '').trim()` (`search_screen.dart:27-31`).
- Query match normalizes by trimming and lowercasing; variant search fields are the eight fields listed in Data (`catalog_controller.dart:88-101`).
- Category count is raw `Category.itemCount` plus literal ` products` (`search_screen.dart:160-164`).
- Product secondary line is brand + ` · ` + category, with ` · ` + SKU only when `sku.isNotEmpty` (`search_screen.dart:206-212`).
- Product price is `₹` + `variant.price.toStringAsFixed(0)` (zero decimal places; no thousands grouping in this screen) (`search_screen.dart:215-219`).
- Product title comes from `CatalogApiMapper.productFromVariant(v).name` (`search_screen.dart:194-202`).

## Style with meaning

- Search state is conveyed by prompt/loading/no-results copy and presence of result sections (`search_screen.dart:111-223`).
- Product prices use primary color; no stock/status chip or selected result state is shown (`search_screen.dart:215-220`).
- No business-state color coding is defined in this screen.

## Keyboard and focus

- Search field autofocuses and uses `TextInputAction.search`; both onChanged and onSubmitted update query (`search_screen.dart:83-97`).
- Clear icon is shown only when raw query is non-empty, and clears/refocus behavior is left to Flutter defaults (`search_screen.dart:99-109`).
- No custom Escape handler or result focus traversal order is defined.

## Responsive

- Search field is in the app bar; result list uses a vertically scrollable `ListView` (`search_screen.dart:80-110,134-223`).
- No explicit breakpoint or alternate layout is defined.

## Risk notes

- Keep `_controller` and `_query` synchronized; the displayed clear action and result branch depend on `_query` (`search_screen.dart:23-39,73-109`).
- Keep category/product rows bound to their originating ids; product route requires both product and variant id (`search_screen.dart:49-67,181-222`).
- Search order/filter behavior is the controller's current loaded list order; do not add API search or alter matching fields without owner approval (`catalog_controller.dart:88-112`).
