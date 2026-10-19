# SCR-10 — Main shell and Home tab

- Route: `/main` and `/home-placeholder` (both create `MainShell`)
- Sources: [main_shell.dart](../lib/features/shell/presentation/main_shell.dart) — 347 lines; [home_dashboard_screen.dart](../lib/features/home/presentation/screens/home_dashboard_screen.dart) — 304 lines; [app_bottom_navigation.dart](../lib/shared/widgets/navigation/app_bottom_navigation.dart) — 47 lines (currently not mounted)
- Purpose: Host nested feature routes and five retained tab bodies; initial visible body is Home.

## Data

- Shell opens with `initialIndex = 0`; root navigation creates `_ShellTabs` for `/`, `/main`, and `/home-placeholder` (`main_shell.dart:27-28,89-102`; routes in `lib/core/routes/app_router.dart:90-92`).
- Home first frame: request location if no fix and not already loading; call `CatalogController.refreshHomeCatalog(showLoading: homeCategories.isEmpty && pipeVariants.isEmpty)` (`home_dashboard_screen.dart:34-45`).
- Refresh/pull-down calls the same catalog refresh (`home_dashboard_screen.dart:103-109`). It fetches categories and pipe catalog concurrently: `GET /api/categories?active_only=true`, then pipe catalog `GET /api/catalog?category=<CatalogApiMapper.pipesCategoryQuery>`; filtered catalog failure falls back to `GET /api/catalog` (`catalog_repository.dart:15-24,34-61`; prefix in `lib/core/network/api_config.dart:13-20`). Catalog poll interval is 3 seconds (`api_config.dart:23`; controller `catalog_controller.dart:358-408`).
- `HomeAppBar` calls `RewardController.refreshForUser(user.id)` after first frame; controller derives balance/ledger from its configured in-memory reward repository, not an app API (`home_app_bar.dart:39-49`; `lib/core/state/reward_controller.dart:10-19,41-45`).
- Recently viewed data comes from `RecentlyViewedController.items`; cart, reward, profile and location values come from shared controllers (`home_dashboard_screen.dart:63-70,105-116`; `main_shell.dart:224-231`).
- Home section/card actions: category → `/category-browse` with category id/name; search → `/search` with query; voice and scan icons → `/search` with no query; featured/popular/recent product → `/product-detail` with product/variant ids; brand → `/brand-products`; offers → `/offer-detail`; section View All → corresponding product list/brands/offers routes (`home_dashboard_screen.dart:48-61,139-278`).
- HomeAppBar shortcuts open `/my-rewards`, `/notifications`, `/profile`, `/cart`; shell AI FAB opens `/ai-assistant` (`home_dashboard_screen.dart:109-118`; `main_shell.dart:128-137`).
- The shell reward message listener shows `RewardController.lastCustomerRewardMessage` as a floating success snackbar, then clears it (`main_shell.dart:71-85`; message set in `lib/core/state/reward_controller.dart:50-59`).
- No API method/path is called for cart, recently viewed, rewards, notification count, or quotation list in these widgets; those use in-memory/provider state.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| SHL-TAB-01 | Home tab body | Home app-bar branding and dashboard content (below); tab body index 0 | `HomeDashboardScreen` (`main_shell.dart:149-166`) | Initial `initialIndex = 0` | Y — tab index selects `IndexedStack` child | Y |
| SHL-TAB-02 | Categories tab body | `Categories` content is defined in `CategoriesTabBody` | `IndexedStack` child index 1 (`main_shell.dart:149-166`) | Only if selected `initialIndex` is 1; no rendered tab selector currently | Y — tab index selects child | Y |
| SHL-TAB-03 | Wishlist tab body | Header `Wishlist`; `WishlistScreenBody` content | `_TabScaffold` + `WishlistScreenBody` (`main_shell.dart:149-167`) | Only if selected index is 2; no rendered tab selector currently | Y — tab index selects child | Y |
| SHL-TAB-04 | Quotation tab body | Header `Quotation`; details below | `_QuotationTab` (`main_shell.dart:149-167,219-316`) | Only if selected index is 3; no rendered tab selector currently | Y — tab index selects child | Y |
| SHL-TAB-05 | Profile tab body | `ProfileTabBody` content | `IndexedStack` child index 4 (`main_shell.dart:149-167`) | Only if selected index is 4; no rendered tab selector currently | Y — tab index selects child | Y |
| SHL-NAV-01 | Bottom navigation | Not displayed by the current `MainShell` | `AppBottomNavigation` and `_onTabTap` are commented out of `Scaffold.bottomNavigationBar` (`main_shell.dart:140-147`); reusable tab order in component is Home, Categories, Wishlist, Quotation, Profile (`app_bottom_navigation.dart:7-26`) | Not shown in current shell | Y — declared order maps indexes to tab bodies | ASK |
| SHL-BTN-01 | Floating action button | Tooltip `AI Assistant`; no visible text (sparkles icon) | Pushes `/ai-assistant` in nested navigator (`main_shell.dart:128-137`) | Only on tab index 0 and when no route is pushed over root tab (`main_shell.dart:128`) | N | Y |
| SHL-MSG-01 | Success snackbar | `🎉 You earned ${formattedPoints} reward points!` | Shell displays pending customer reward message then clears controller value (`main_shell.dart:71-85`; `reward_controller.dart:50-59`) | When reward controller has a non-null customer reward message | N | Y |
| HOM-BRAND-01 | Brand image and name | `Buildmate 24x7`; asset `assets/images/branding/app logo.png` (asset contents unknown) | Static logo plus `AppConstants.appName` (`home_app_bar.dart:63-81`; `app_constants.dart:3`) | Home visible | N | Y |
| HOM-BTN-01 | Icon button | Tooltip `My Rewards`; badge `$rewardPoints` or `999+` | Opens `/my-rewards`; refreshes reward data after first frame (`home_app_bar.dart:39-49,85-105`; caller `home_dashboard_screen.dart:109-113`) | Home visible; badge label only if reward points > 0 | N | Y |
| HOM-BTN-02 | Icon button | Tooltip `Cart`; badge `$cartCount` or `99+` | Opens `/cart` (`home_app_bar.dart:51,106-122`; caller `home_dashboard_screen.dart:115-118`) | Home visible; badge only if cart count > 0 | N | Y |
| HOM-BTN-03 | Icon button | Tooltip `Notifications`; badge `3` by default | Opens `/notifications`; `notificationCount` default is 3, capped at `99+` (`home_app_bar.dart:14,123-143`; caller `home_dashboard_screen.dart:114-116`) | Home visible; badge only if count > 0 | N | Y |
| HOM-BTN-04 | Profile avatar | Dynamic user initials; no other visible label | Tap opens `/profile` (`home_app_bar.dart:145-160`; caller `home_dashboard_screen.dart:116`) | Home visible | N | Y |
| HOM-LOC-01 | Location bar | Dynamic `Home` or `Location`, then `LocationController.fullAddress` | If no fix, an existing error and not loading → retry GPS then return; otherwise open `/choose-location` in `isLocationUpdate` mode with user phone/name (`home_dashboard_screen.dart:130-161`; `home_location_bar.dart:28-89`) | Home visible | Y — displayed address/label and tap branch reflect location state | Y |
| HOM-IN-01 | Search input | Placeholder `Search products, brands or categories` | Search icon or keyboard action opens `/search` with trimmed query (`home_search_bar.dart:39-46,61-91`; caller `home_dashboard_screen.dart:163-174`) | Home visible | Y — sends current query | Y |
| HOM-BTN-07 | Search icon button | No visible text/tooltip; search icon | Calls `_submit()` with current input and opens `/search` with trimmed query (`home_search_bar.dart:61-69`; caller `home_dashboard_screen.dart:163-171`) | Home visible | Y — sends current query | Y |
| HOM-BTN-05 | Voice icon button | No visible text/tooltip; microphone icon | Opens `/search` without a query; does not start voice capture (`home_search_bar.dart:92-101`; caller `home_dashboard_screen.dart:173-174`) | Home visible | N | Y |
| HOM-BTN-06 | Scan icon button | No visible text/tooltip; scanner icon | Opens `/search` without a query; does not start scanning (`home_search_bar.dart:102-112`; caller `home_dashboard_screen.dart:173-174`) | Home visible | N | Y |
| HOM-STATE-01 | Category loading/empty state | Spinner; or `No categories from server yet.` | Shown while loading with no transformed categories; otherwise category grid (`home_dashboard_screen.dart:180-203`) | Depending on catalog state; seeded categories normally populate grid | N | Y |
| HOM-CAT-01 | Category tile | Seed/default names in order: `Pipes & Fitting`; `Electricals`; `Valves & Controls`; `Sanitarywares`; `Cement & Plaster`; `Tiling & Grouts`; `Paints & Putty`; `Plywood & MDF`; `Fevicol & Adhesives`; `Furniture Fittings`; `Locks & Handles`; `Hardware & Tools`; `Waterproofing & Repair`; `Safety Gear`; `Construction Materials` (API names may replace matched seed names) | Image block tap opens `/category-browse` with the category id/name; name is formatted by `formatHomeCategoryLabel` (`home_dashboard_screen.dart:199-212`; `home_dashboard_categories.dart:25-81,143-246`; grid `home_category_card.dart:12-110`) | When transformed category list non-empty | Y — tap sends associated category id/name | Y |
| HOM-SEC-01 | Section heading | `Featured Products` | Static heading; `View All` opens `/product-list` with title `Featured Products` (`featured_products_section.dart:32-40`; caller `home_dashboard_screen.dart:213-223`; header `home_section_header.dart:20-51`) | Always; View All shown because callback provided | N | Y |
| HOM-PROD-01 | Featured product card | Dynamic brand name, product name, `${priceLabel} / ${unit}`, `In Stock` or `Out of Stock` chip; button `Add` | Card tap opens product detail; Add adds in-stock variant to cart and shows `${displayName} added to cart` snackbar (`featured_products_section.dart:69-73,89-96,118-190`; `catalog_widgets.dart:34-47`) | Up to 12 API-ranked featured variants; Add disabled when out of stock | N | Y |
| HOM-STATE-02 | Featured section loading/empty | Spinner; or `No featured products from server yet.` | Loading while home catalog loading and no variants; empty copy after loading when none (`featured_products_section.dart:44-59`) | Featured list empty | N | Y |
| HOM-SEC-02 | Section heading | `Popular Brands`; button `View All` | View All opens `/brands` (`popular_brands_section.dart:24-34`; caller `home_dashboard_screen.dart:225-236`; `home_section_header.dart:20-51`) | Always; View All shown | N | Y |
| HOM-BRAND-02 | Brand card | Dynamic brand name; `${productCount} products`; brand logo/abbreviation | Card tap opens `/brand-products` with brand id (`popular_brands_section.dart:37-52,54-109`; caller `home_dashboard_screen.dart:230-236`) | Up to 8 alphabetically sorted brands derived from catalog variants; empty list renders no cards | N | Y |
| HOM-SEC-03 | Section heading | `Popular Products`; button `View All` | View All opens `/product-list` with title `Popular Products` (`popular_products_section.dart:30-47`; caller `home_dashboard_screen.dart:238-253`) | Always; View All shown | N | Y |
| HOM-PROD-02 | Popular product card | Dynamic brand, product, spec summary or pipe type, `${priceLabel} / ${unit}`, `In Stock` or `Out of Stock` chip; button `Add to cart` | Card tap opens product detail; Add to cart adds in-stock variant and shows `${displayName} added to cart` snackbar (`popular_products_section.dart:50-78,95-171`; `catalog_widgets.dart:34-47`) | Up to 6 popular variants; Add to cart disabled when out of stock | N | Y |
| HOM-STATE-03 | Popular products loading/empty | Spinner; or `No popular products from server yet.` | Shown when list empty according to loading state (`popular_products_section.dart:36-50`) | Popular list empty | N | Y |
| HOM-SEC-04 | Section heading | `Recently Viewed`; `View All` when items exist | View All opens `/product-list` with title `Recently Viewed`; each card opens product detail (`recently_viewed_section.dart:28-53`; caller `home_dashboard_screen.dart:254-272`) | Always; View All hidden when list empty | N | Y |
| HOM-PROD-03 | Recently viewed card | Dynamic product name, brand name, price label | Tap opens product detail (`recently_viewed_section.dart:66-69,77-142`; caller `home_dashboard_screen.dart:268-273`) | One card per recently viewed product | N | Y |
| HOM-STATE-04 | Recently viewed empty state | `No recently viewed products yet. Browse the catalogue to see them here.` | Static empty message (`recently_viewed_section.dart:38-56`) | When recent list empty | N | Y |
| HOM-SEC-05 | Section heading | `Current Offers`; button `View All` | View All opens `/offers` (`current_offers_section.dart:24-35`; caller `home_dashboard_screen.dart:274-285`) | Always; View All shown | N | Y |
| HOM-OFFER-01 | Current offer card | Dynamic discount label, title, subtitle, ends-on value; CTA `Explore` | Explore opens `/offer-detail` with offer id (`current_offers_section.dart:37-48,50-138`; caller maps CTA/id at `home_dashboard_screen.dart:90-103,278-285`) | Up to 6 discounted catalog offers; no dedicated empty message | N | Y |
| QOT-TXT-01 | Quotation tab cart summary | `Cart ready · ${cart.totalQuantity} items · ₹${cart.estimatedTotal.toStringAsFixed(0)}` | Dynamic cart total/quantity (`main_shell.dart:224-242`) | Quotation body when cart not empty | N | Y |
| QOT-BTN-01 | Button | `Generate Quotation` | Opens `/quotation-review` (`main_shell.dart:243-248`) | Cart not empty | N | Y |
| QOT-BTN-02 | Button | `Review Cart` | Opens `/cart` (`main_shell.dart:250-255`) | Cart not empty | N | Y |
| QOT-TXT-02 | Empty cart instruction | `Add materials to cart to create a new quotation.` | Static text (`main_shell.dart:257-263`) | Cart empty | N | Y |
| QOT-BTN-03 | Button | `Open Cart` | Opens `/cart` (`main_shell.dart:263-268`) | Cart empty | N | Y |
| QOT-TXT-03 | Section heading | `My quotations` | Static heading (`main_shell.dart:270`) | Quotation tab body | N | Y |
| QOT-TXT-04 | Information text | `Pending quotations do not earn reward points.` | Static text (`main_shell.dart:272-277`) | Quotation tab body | N | Y |
| QOT-STATE-01 | Empty state | `No quotations yet.` | Shown when current requester has no quotations (`main_shell.dart:279-285`) | Quotation list empty | N | Y |
| QOT-ROW-01 | Quotation summary | Dynamic `q.quotationLabel`; `₹${q.grandTotal.toStringAsFixed(0)} · ${q.status.toUpperCase()}`; conditional `Sold — rewards credited when admin confirmed sale` | Read-only card for each quotation filtered by requester id; no tap handler (`main_shell.dart:224-231,287-309`) | One per quotation; sold text only if `q.isSold` | N | Y |

## States and messages

- Main shell root is a nested `Navigator`; feature routes push above the active tab. Auth routes `/`, `/login`, `/create-account` are escalated to the root navigator and clear root stack (`main_shell.dart:88-126`).
- `_hasPushedRoute` tracks nested stack depth; AI FAB is hidden while a feature route is pushed (`main_shell.dart:34-42,128-137,319-347`).
- `AppBottomNavigation` is not currently rendered; `bottomNavigationBar` and its onTap wiring are commented out (`main_shell.dart:140-147`). Its defined order is Home, Categories, Wishlist, Quotation, Profile (`app_bottom_navigation.dart:7-26`).
- Home loading: catalog refresh indicator; featured/popular product spinners; category spinner when loading and categories empty (`home_dashboard_screen.dart:34-45,103-109,180-203`; section sources above).
- Catalog failure is stored in `CatalogController.error` but Home does not display it directly; it renders current/seeded categories and product empty states instead (`catalog_controller.dart:358-391`; `home_dashboard_screen.dart:180-203`). `HomeDashboardCategories.forDashboard` adds the fixed seed list, so `No categories from server yet.` is only rendered if the transformed category list is empty (`home_dashboard_categories.dart:51-65,140-246`).
- The Home location bar displays inline `Detecting current location…` while unresolved, or these exact `LocationController` errors when no fix exists: `Turn on location services to continue`; `Location permission denied — tap to retry`; `Location permission blocked — enable it in Settings`; `Unable to get current location — try again` (`location_controller.dart:27-31,41-64,79-93`; rendered by `home_location_bar.dart:65-80`).
- Product add success snackbar exact template: `${variant.displayName} added to cart` (`featured_products_section.dart:89-96`; `popular_products_section.dart:70-78`).
- Reward success snackbar template: `🎉 You earned ${formattedPoints} reward points!` (`reward_controller.dart:50-59`; shell display `main_shell.dart:71-85`).
- Quotation body has cart-empty/cart-present branches and quotations-empty/list branches (`main_shell.dart:232-316`).

## Displayed values

- App name is `AppConstants.appName` (`Buildmate 24x7`) (`home_app_bar.dart:74-82`; `lib/core/constants/app_constants.dart:3`).
- Avatar initials: from trimmed name; first and last initials for multiword name, first two characters for one word, `?` when empty (`catalog_models.dart:25-39`; `home_app_bar.dart:145-160`).
- Reward badge: current reward balance, capped as `999+`; shown only if > 0 (`home_app_bar.dart:46-47,91-103`).
- Cart badge: cart total quantity, capped as `99+`; shown only if > 0 (`home_app_bar.dart:51,106-121`).
- Notification badge: default count 3, capped as `99+`; shown only if > 0 (`home_app_bar.dart:14,123-143`).
- Location label is `Home` when `hasFix`, else `Location`; address is `LocationController.fullAddress` (`home_dashboard_screen.dart:130-138`; `location_controller.dart:27-31`). On first unfixed load it can show `Detecting current location…`; if failed it shows the controller error inline.
- Home category order is priority seeds then unmatched API categories; labels title-case each word while leaving `&` unchanged (`home_dashboard_categories.dart:25-81,143-246`; `home_category_card.dart:48-58`).
- Featured variants sort by descending discount rate then ascending price; controller returns max 12 (`catalog_controller.dart:49-61`). Popular variants sort in-stock first then product name; controller returns max 12, home section displays first 6 (`catalog_controller.dart:63-75`; `popular_products_section.dart:27-28`).
- Brand card list sorts by brand name and counts variants per brand; Home shows first 8 (`catalog_controller.dart:477-504`; `home_dashboard_screen.dart:75-84`).
- Home offers include discounted variants, sorted by discount descending; discount text is rounded percentage + `% OFF`, title product name, subtitle brand + ` · ` + display name, `endsOn` empty; Home takes 6 (`catalog_controller.dart:318-337`; `home_dashboard_screen.dart:86-103`).
- Featured/popular product values use variant brand/product/specification/price label/unit/stock; price label is `formatInr(price)` → whole rupees with Western thousands separators and `₹` prefix; display name is `$brandName $productName` (`catalog_models.dart:233-256,445-455`; `featured_products_section.dart:89-96,143-184`; `popular_products_section.dart:115-167`).
- `In Stock`/`Out of Stock` chip uses `variant.inStock` (`stockStatus != outOfStock`), so a `limited` stock enum still renders `In Stock` in these Home cards (`catalog_models.dart:233-235`; `catalog_widgets.dart:22-47`).
- `cart.totalQuantity` sums item quantities; `estimatedTotal` is `subtotal`, which sums each `variant.price * quantity`; Home Quotation formats estimated total with `toStringAsFixed(0)` (`cart_controller.dart:39-43`; `catalog_models.dart:286-300`; `main_shell.dart:238-239`).
- Quotation cart total uses total quantity and estimated total formatted with zero decimal places; quotation grand total also zero decimals and status uppercase (`main_shell.dart:238-239,299-300`).
- Reward snackbar point count uses comma-separated thousands (`reward_controller.dart:54-64`).

## Style with meaning

- Stock chip communicates availability with `In Stock`/`Out of Stock` and success/error color; Add buttons disabled when `variant.inStock` is false (`catalog_widgets.dart:32-47`; `featured_products_section.dart:168-185`; `popular_products_section.dart:155-169`).
- Location bar uses spinner while loading without a fix; actual address/label depends on GPS fix (`home_location_bar.dart:43-58`; `home_dashboard_screen.dart:130-138`).
- Badge visibility/counts represent rewards, cart quantity, and notification count (`home_app_bar.dart:85-143`).
- Selected quotation status `Sold` message and success snackbar communicate business state (`main_shell.dart:299-309,71-85`).
- Palette may change, but stock, loading, badge presence, and sold/success distinctions must remain.

## Keyboard and focus

- Home search uses `TextInputAction.search`; submit dispatches search (`home_search_bar.dart:73-91`).
- No autofocus, Enter action on non-search controls, Escape behavior, or custom focus traversal order is defined.
- Home scroll view is always scrollable and refreshable; tab/product horizontal lists have horizontal scrolling (`home_dashboard_screen.dart:103-109`; section widget implementations).
- Buttons and cards use Flutter Material/InkWell feedback; no custom hover behavior.

## Responsive

- Home uses vertical `SingleChildScrollView` with pull-to-refresh; category grid fixed at four columns; product/brand/offer/recent sections horizontally scroll (`home_dashboard_screen.dart:103-109`; `home_category_card.dart:22-34`; section sources).
- No explicit breakpoint or alternative layout is defined.
- Main shell reserves floating action button at `endFloat`; no bottom navigation height is currently rendered (`main_shell.dart:128-147`).

## Risk notes

- Tab body order is Home, Categories, Wishlist, Quotation, Profile; `_tabIndex` indexes this `IndexedStack`. `_onTabTap` clears nested pushed routes then switches index, but its only UI binding (bottom nav) is commented out (`main_shell.dart:34-64,149-167,140-147`).
- Nested Navigator/FAB visibility depend on route depth observer; preserve that wiring (`main_shell.dart:33-42,88-137,319-347`).
- Home actions carry route arguments (category/product/brand/offer/search ids/query); moving a button must preserve its associated argument source (`home_dashboard_screen.dart:48-61,139-285`).
- Featured/popular product cards contain both card tap and nested Add action; retain distinct navigation and cart callbacks (`featured_products_section.dart:118-190`; `popular_products_section.dart:95-171`).
- Home categories are seeded and merged with API categories; retain seed/API matching, formatter and card callback identity (`home_dashboard_categories.dart:25-81,143-246`; `home_dashboard_screen.dart:199-212`).
- The `AppBottomNavigation` widget exists with visible labels but is not active in the current shell; enabling it would add UI/behavior not currently visible (`main_shell.dart:140-147`; `app_bottom_navigation.dart:19-43`).
