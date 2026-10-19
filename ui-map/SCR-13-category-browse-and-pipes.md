# SCR-13 — Category browse / pipes category

- Route: `/category-browse` (`AppRoutes.categoryBrowse`)
- Source files: [app_router.dart](../lib/core/routes/app_router.dart) (route selection); [category_browse_screen.dart](../lib/features/catalog/presentation/screens/category_browse_screen.dart) (generic branch, 142 lines); [pipes_fitting_category_screen.dart](../lib/features/catalog/presentation/screens/pipes_fitting_category_screen.dart) (pipe branch, 2505 lines); [pipes_filter_panel.dart](../lib/features/catalog/presentation/widgets/pipes_filter_panel.dart) (filter enums/options/helpers)
- Purpose: Resolve a category browse request to the generic product list or to the pipes-specific catalog, then let shoppers filter groups and configure a pipe product.

## Route branches

- `AppRouter` chooses `PipesFittingCategoryScreen` when the category ID is exactly `pipes`, the category name matches `CatalogApiMapper.isPipesCategory`, or the name is empty and the ID matches the UUID regex; otherwise it builds `CategoryBrowseScreen` (`lib/core/routes/app_router.dart:106-123`).
- Generic `CategoryBrowseScreen` looks up category name by ID, falls back to `Category`, and delegates the complete UI to `ProductListScreen(categoryId, title)` (`lib/features/catalog/presentation/screens/category_browse_screen.dart:14-27`). Its element, state, and display contract is therefore the `/product-list` contract in [SCR-14](./SCR-14-product-list.md); do not create a second, divergent version for this route.

## Data

- Pipe branch: `initState` schedules `CatalogController.startPipeCatalogSync()` and also calls `refreshPipeCatalog(showLoading: pipesFittingCatalog == null)` (`pipes_fitting_category_screen.dart:177-186`). The controller starts initial loading if its API variants are empty, then starts polling at `ApiConfig.catalogPollInterval` (3 seconds) (`lib/core/state/catalog_controller.dart:394-405`; `lib/core/network/api_config.dart:22-24`). Because the screen separately invokes refresh, the initial state can issue overlapping refreshes; preserve both invocations unless the owner approves a behavior change.
- Each pipe refresh calls `CatalogRepository.fetchPipeCatalog()`: first `GET /api/catalog?category=<pipesCategoryQuery>`, then `GET /api/catalog` if the filtered request throws; items are filtered/mapped into the tree (`lib/features/catalog/data/repositories/catalog_repository.dart:33-78`; API prefix and catalog URL: `lib/core/network/api_config.dart:13-20`).
- Refresh also attempts `GET /api/categories?active_only=true` to update category metadata (`lib/core/state/catalog_controller.dart:423-435`; `lib/features/catalog/data/repositories/catalog_repository.dart:15-31`). A categories-refresh exception is caught and the last good categories are retained (`catalog_controller.dart:427-435`).
- `Retry` calls `refreshPipeCatalog(showLoading: true)` (`pipes_fitting_category_screen.dart:568-580`).
- Filtering, group sorting, configurator selections, and opening the search route are local state/navigation; no filter-specific API request is sent (`pipes_fitting_category_screen.dart:236-320,421-516,2072-2080`).
- Adding a configured item calls shared `CartController.addVariant` (using the live variant by ID when available, otherwise constructing a `ProductVariant`); it does not invoke a cart API here. It shows a snackbar and its `View Cart` action navigates to `/cart` (`pipes_fitting_category_screen.dart:1954-1980`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| PIP-BTN-01 | Icon button | No text (back arrow) | `Navigator.maybePop()` (`pipes_fitting_category_screen.dart:728-744,1250-1265`) | Pipe branch always | N | Y |
| PIP-TXT-01 | Header title | `Plumbing Pipes & Fittings` | Static header text (`pipes_fitting_category_screen.dart:745-755`) | Pipe branch always | N | Y |
| PIP-BTN-02 | Icon button | No text (search icon) | Pushes `/search` with empty `SearchArgs` (`pipes_fitting_category_screen.dart:760-764,552-558`) | Pipe branch always | N | Y |
| PIP-FLT-01 | Filter button | `Sort By` or selected option: `All`, `Discount`, `Price (lowest first)`, `What’s New`, `Price (highest first)`, `Ratings` | Opens sort overlay; selecting an option updates `_sort`, closes menu and locally filters/reorders groups. `Discount` and `Ratings` cases currently do not reorder; `What’s New` reverses current groups (`pipes_fitting_category_screen.dart:287-319,421-439,771-779,882-916`) | Pipe branch always; selected option replaces button label except `All`, which displays `Sort By` | Y — preserve the listed option sequence and each option’s value | Y |
| PIP-FLT-02 | Filter button | `Size` or selected size | Opens searchable size overlay. `All Sizes` clears selection; a size filters groups with `pipeSizeMmValue` equality or numeric substring matching (`pipes_fitting_category_screen.dart:280-285,442-464,946-960`; size source: `lib/features/catalog/presentation/widgets/pipes_filter_panel.dart:16-34`) | Pipe branch always | N | Y |
| PIP-FLT-03 | Filter button | `Brand` or selected brand | Opens searchable brand overlay. `All Brands` clears selection; brand options are distinct, non-empty trimmed live brands, sorted case-insensitively (`pipes_fitting_category_screen.dart:466-489,986-1012`; `pipes_filter_panel.dart:37-72`) | Pipe branch always | N | Y |
| PIP-FLT-04 | Filter button | `Class` or selected class | Opens searchable class overlay. `All Classes` clears selection; options are selected-type classes, or distinct classes across types when `All` is selected (`pipes_fitting_category_screen.dart:491-516,1037-1057`; `pipes_filter_panel.dart:74-98`) | Pipe branch always | N | Y |
| PIP-MENU-01 | Search input | `Search sort options...` | `onChanged` filters the sort-option labels case-insensitively in the current overlay (`pipes_fitting_category_screen.dart:893-916,1125-1170`) | Sort overlay open | N | Y |
| PIP-MENU-02 | Search input | `Search size...` | `onChanged` filters the fixed options case-insensitively; options are `15 mm`, `20 mm`, `25 mm`, `32 mm`, `40 mm`, `50 mm`, `65 mm`, `80 mm`, `100 mm`, `150 mm`, `200 mm`, `250 mm`, `300 mm` (`pipes_fitting_category_screen.dart:929-960`; `pipes_filter_panel.dart:16-34`) | Size overlay open | Y — preserve option labels and selection mapping | Y |
| PIP-MENU-03 | Search input | `Search brand...` | `onChanged` filters live brand labels case-insensitively (`pipes_fitting_category_screen.dart:976-1012,1125-1170`) | Brand overlay open | N | Y |
| PIP-MENU-04 | Search input | `Search class...` | `onChanged` filters class labels case-insensitively (`pipes_fitting_category_screen.dart:1028-1057,1125-1170`) | Class overlay open | N | Y |
| PIP-MENU-05 | Filter option | `All`, `All Sizes`, `All Brands`, `All Classes`; dynamic size, brand, and class labels | Selects the option and closes its corresponding overlay; “All” sort is a sort enum value, while the three “All …” choices clear their filters (`pipes_fitting_category_screen.dart:882-916,946-960,986-1012,1037-1057`) | Relevant overlay open; option list may be narrowed by that overlay’s search | Y — options map to specific filter values | Y |
| PIP-MENU-06 | Empty/no-result text | `No brands in catalog`; `No matches found` | `No brands in catalog` is a non-actionable row when live brand list is empty and query empty; `No matches found` appears when the searched option list is empty (`pipes_fitting_category_screen.dart:1000-1004,1082-1110`) | Brand overlay has no brand data; or any overlay search yields no choices | N | Y |
| PIP-NAV-01 | Sidebar choice | `All` | Selects `_CatSection.all`, clears subcategory, and clears selected class if incompatible with the all-type class list (`pipes_fitting_category_screen.dart:1418-1442,604-616`) | Catalog loaded | N | Y |
| PIP-TXT-02 | Sidebar section label | `Type` | Non-interactive label for the type choices (`pipes_fitting_category_screen.dart:1421-1428`) | Catalog loaded | N | Y |
| PIP-NAV-02 | Sidebar choice | `PVC`, `CPVC`, `UPVC` | Selects the corresponding type section; incompatible selected class is cleared (`pipes_fitting_category_screen.dart:141-158,1423-1428,604-616`) | Catalog loaded | Y — each label maps to its type enum | Y |
| PIP-TXT-03 | Sidebar section label | `Sub-category` | Non-interactive label (`pipes_fitting_category_screen.dart:1430-1440`) | Catalog loaded and selected type is not `All` | N | Y |
| PIP-NAV-03 | Sidebar choice | `All`; dynamic catalog subcategory name | Selects no subcategory or the selected subcategory, updating product groups locally (`pipes_fitting_category_screen.dart:216-234,1430-1443`) | Catalog loaded and selected type is not `All`; names are distinct case-insensitively from catalog data | Y — each label selects its matching subcategory | Y |
| PIP-STATE-01 | Loading indicator | No text | Circular progress indicator while pipe catalog is loading and no pipe catalog is available (`pipes_fitting_category_screen.dart:560-568`) | `isLoading && pipesFittingCatalog == null` | N | Y |
| PIP-STATE-02 | Catalog error | `Unable to load catalog`; `Please check your connection and try again.` or dynamic `catalogCtrl.error`; `Retry` | Retry action refreshes pipe catalog (`pipes_fitting_category_screen.dart:570-580`) | No pipe catalog is available after loading; subtitle uses controller error when non-null | N | Y |
| PIP-STATE-03 | Refresh indicator | No text | Small indicator over catalog content while a refresh runs (`pipes_fitting_category_screen.dart:675-685`) | Catalog data exists and `isLoading` is true | N | Y |
| PIP-TXT-04 | Catalog heading | Dynamic title and subtitle | Title/subtitle derive from selected type, subcategory, and selected brand (`pipes_fitting_category_screen.dart:322-348,630-633`) | Catalog data loaded | N | Y |
| PIP-STATE-04 | Empty filtered result | `No products here yet`; `Try another category or adjust your filters.` | Informational state replacing product grid (`pipes_fitting_category_screen.dart:635-644`) | Catalog loaded but filtered group list is empty | N | Y |
| PIP-CARD-01 | Product-group card | Dynamic group title; `ADD`; `${group.products.length} Products`; dynamic price/unit and optional discount label | Tapping anywhere on card opens `_PipeConfiguratorScreen` with first product in the group (`pipes_fitting_category_screen.dart:1653-1686,1728-1818`) | Catalog loaded and group remains after current category/subcategory/filter choices | Y — each card’s group and initial product must stay paired | Y |
| PIP-CFG-BTN-01 | Icon button | No text (back arrow) | `Navigator.maybePop()` closes configurator (`pipes_fitting_category_screen.dart:2014-2029`) | Configurator open | N | Y |
| PIP-CFG-IN-01 | Search input | `Search products` | Tap navigates to `/search` with empty args; submitting navigates to `/search` with entered `initialQuery` (`pipes_fitting_category_screen.dart:2043-2080`) | Configurator open | N | Y |
| PIP-CFG-IMG-01 | Product image | No text; uses group image and image fallback | Display-only image; prefers available product image URL and falls back through `CategoryImage` (`pipes_fitting_category_screen.dart:2090-2121`) | Configurator open | N | Y |
| PIP-CFG-TXT-01 | Product title | Dynamic product code/name, class/type, size, length, and brand | Computed by `_title` (`pipes_fitting_category_screen.dart:1983-2000,2127-2131`) | Configurator open | N | Y |
| PIP-CFG-TXT-02 | Field label | `Brand` | Labels brand dropdown (`pipes_fitting_category_screen.dart:2135-2150`) | Configurator open | N | Y |
| PIP-CFG-SEL-01 | Select | `Select brand` or selected brand name; dynamic brand options | Selects brand and tries to preserve current size, otherwise picks the first product for that brand (`pipes_fitting_category_screen.dart:1855-1866,1885-1905,2140-2150`) | Configurator open; disabled if no brands | N | Y |
| PIP-CFG-TXT-03 | Field label | `Class` | Labels class/type dropdown (`pipes_fitting_category_screen.dart:2152-2166`) | Configurator open | N | Y |
| PIP-CFG-SEL-02 | Select | `Select class` or selected class name; dynamic type options | Changes group within the initial group’s same-subcategory siblings and keeps the same size if possible, otherwise uses first product (`pipes_fitting_category_screen.dart:1868-1878,1925-1937,2157-2166`) | Configurator open; disabled when there is at most one type option | N | Y |
| PIP-CFG-TXT-04 | Field label | `Size` | Labels size chips (`pipes_fitting_category_screen.dart:2168-2175`) | Configurator open | N | Y |
| PIP-CFG-EMPTY-01 | Empty text | `No sizes available` | Replaces size grid if selected group has no non-empty product sizes (`pipes_fitting_category_screen.dart:2218-2230`) | Configurator open and size options empty | N | Y |
| PIP-CFG-SEL-03 | Size choice | Dynamic size; unavailable size also shows `Out of stock` | Selects available matching size. Chips without a matching in-stock brand/size variant are disabled; selection may fall back to another brand if the current brand has no in-stock match (`pipes_fitting_category_screen.dart:1907-1923,2206-2255,2264-2334`) | Configurator open with size options | Y — size must map to its variant and in-stock status | Y |
| PIP-CFG-PRICE-01 | Price display | `Selected Product Size`; `₹`; computed price; `/ <unit>`; selected size or `—` | Display-only; price is `product.displayPrice` formatted with `toStringAsFixed(0)` and selected size is product size or em dash (`pipes_fitting_category_screen.dart:2182-2191,2395-2468`) | Configurator open | N | Y |
| PIP-CFG-BTN-02 | Button | `Add to Cart` | Calls `_addToCart`, updates shared cart and presents success snackbar (`pipes_fitting_category_screen.dart:1954-1980,2471-2497`) | Configurator open; no explicit stock-based disablement is applied to this button | N | Y |
| PIP-MSG-01 | Snackbar | `${brand} ${productName} added to cart`; action `View Cart` | Snackbar auto-dismisses after 3 seconds; `View Cart` navigates to `/cart` (`pipes_fitting_category_screen.dart:1965-1980`) | After `Add to Cart` | N | Y |

The reusable generic `/product-list` UI is not duplicated in this table: use SCR-14 for its filters, product cards, controls, and states. Dynamic catalog labels/values are data, not additional hard-coded copy.

## States and messages

- Initial load without cached pipe catalog: centered spinner. A cached catalog remains visible while refresh is active with a small top-right indicator (`pipes_fitting_category_screen.dart:560-568,675-685`).
- Catalog load failure: `Unable to load catalog`; subtitle is `catalogCtrl.error` when available, otherwise `Please check your connection and try again.`; `Retry` reruns refresh (`pipes_fitting_category_screen.dart:570-580`).
- Catalog available but filter result empty: `No products here yet` / `Try another category or adjust your filters.` (`pipes_fitting_category_screen.dart:635-644`).
- Searchable dropdown with no entries after query: `No matches found`; brand overlay with empty data and empty query additionally has `No brands in catalog` (`pipes_fitting_category_screen.dart:1000-1004,1082-1110`).
- Configurator with no sizes: `No sizes available`; unavailable chips display `Out of stock` (`pipes_fitting_category_screen.dart:2218-2230,2318-2334`).
- Cart success snackbar: `${brand} ${productName} added to cart`; `View Cart` action; three-second duration (`pipes_fitting_category_screen.dart:1965-1980`).
- No confirmation dialog, validation message, upload, or passcode popup is defined in the pipe-specific screen.

## Displayed values

- Group title: `${type.type} ${sub.subCategory} (${cls.className})` (`pipes_fitting_category_screen.dart:236-267`).
- Group card price: minimum `displayPrice` across group products; formatted zero decimal places; unit from first product, falling back to `pcs` (`pipes_fitting_category_screen.dart:68-71,1668-1669,1773-1793`).
- Discount label: highest positive non-null group `discountRate`, multiplied by 100 and rounded, rendered as `discount <n>%`; omitted when there are no positive rates (`pipes_fitting_category_screen.dart:73-84,1795-1806`).
- Card count: `group.products.length` rendered as `<count> Products` (`pipes_fitting_category_screen.dart:1746-1754`).
- Heading title/subtitle are selected-scope-derived; subtitle prioritizes selected brand and otherwise reflects type/subcategory (`pipes_fitting_category_screen.dart:322-348`).
- Configurator title uses `<productCode>_<productName>` when code is nonempty, otherwise product name, then `, ` plus available type/size/length details and a space plus brand (`pipes_fitting_category_screen.dart:1983-2000`).
- Configurator price: `displayPrice.toStringAsFixed(0)` with `₹`, followed by `/ <group.unit>`; selected size falls back to `—` (`pipes_fitting_category_screen.dart:2182-2191,2438-2468`).
- Sidebar subcategory names are unique case-insensitively in catalog traversal order (`pipes_fitting_category_screen.dart:207-214`). Pipe groups retain catalog traversal order unless a sort mode changes that order (`pipes_fitting_category_screen.dart:236-320`).

## Style with meaning

- Sidebar selection, selected filter options, and selected dropdown tiles have selected-state styling; a redesign may change the palette but must keep selected/unselected distinguishable (`pipes_fitting_category_screen.dart:1196-1242,1485-1519,1535-1600`).
- Out-of-stock size chips are disabled and use a distinct text/border treatment and the `Out of stock` label; retain the distinction from available sizes (`pipes_fitting_category_screen.dart:2243-2255,2278-2334`).
- Loading indicators replace or overlay content according to whether catalog data already exists; preserve their state distinction (`pipes_fitting_category_screen.dart:560-568,675-685`).
- Error and empty-result states replace the product grid; their copy and retry availability are behaviorally significant (`pipes_fitting_category_screen.dart:570-580,635-644`).
- Discount copy is green in the current UI; preserve its identification as a discount if palette changes (`pipes_fitting_category_screen.dart:1795-1806`).

## Keyboard and focus

- Filter dropdown text fields filter on every input change; no explicit focus/autofocus, submit action, or keyboard shortcut is defined (`pipes_fitting_category_screen.dart:1125-1170`).
- Configurator search uses `TextInputAction.search`; submit navigates with the entered query. Tapping the field also navigates to search (`pipes_fitting_category_screen.dart:2058-2080`).
- No explicit Escape handler or custom focus order is defined. Tap targets use `InkWell`; disabled size chips and dropdowns rely on Flutter’s disabled behavior.

## Responsive

- Pipe page enforces a 480 logical-pixel minimum body height and scrolls the body when the viewport is shorter (`pipes_fitting_category_screen.dart:519-532`).
- Category sidebar width is fixed at 108; products use a two-column grid (`pipes_fitting_category_screen.dart:1405-1415,649-667`).
- Dropdown overlays have fixed menu widths (sort 240, size 200, brand 220, class 200), anchor below their button, and clamp horizontally within screen margins (`pipes_fitting_category_screen.dart:366-414,421-515`).
- Configurator size grid uses four columns and computes cell width from available width (`pipes_fitting_category_screen.dart:2234-2250`).
- No width breakpoint or alternate navigation layout is defined.

## Risk notes

- Route classification is behaviorally significant; changing the ID/name/UUID checks can send categories to the wrong screen (`lib/core/routes/app_router.dart:106-123`).
- Filter overlays use a `GlobalKey` to find the button `RenderBox` and position the overlay relative to its global coordinates; preserve key-to-button association and dismiss-on-outside-tap behavior (`pipes_fitting_category_screen.dart:160-175,366-414`).
- Pipe type/subcategory/filter state controls group derivation and may clear incompatible class or brand selection; keep handlers paired with their displayed choices (`pipes_fitting_category_screen.dart:216-320,604-616`).
- `Discount` and `Ratings` are currently no-op sort cases; do not silently implement different behavior as part of a visual redesign (`pipes_fitting_category_screen.dart:306-319`).
- Product-group card’s full surface opens the configurator with that group’s first product; retain that hit target and pairing (`pipes_fitting_category_screen.dart:1653-1686`).
- Configurator brand/size/type changes update `_product` / `_group`; its Add to Cart action consumes that selected state. Keep the fields and button connected to those callbacks (`pipes_fitting_category_screen.dart:1885-1937,1954-1980`).
- No additional element-order dependency or custom DOM structure exists; moving UI is allowed if data associations, handler wiring, overlay anchoring, and card hit areas remain intact.
