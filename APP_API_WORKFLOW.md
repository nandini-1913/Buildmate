# BuildMate Customer App — API Workflow and Module Status

## Scope and definition of “complete”

This report describes the Flutter client code in `lib/`.

For this report, **server-backed / complete** means the module's displayed
business data is fetched from the BuildMate API (or derived from a catalog
response fetched from it). Merely having a screen, route, model, button, local
calculation, or Firebase integration does not count as server-backed.

## Executive summary

- The app currently has one REST data path: the shared catalog client and
  repository. It issues `GET` requests and expects the API envelope
  `{ "success": true, "data": ... }`.
- The supported live catalog data is currently categories, catalog rows for
  **Pipes & Fitting** and **Electricals**, and optional category/type images.
- Home category names are a hybrid of API categories and 15 locally seeded
  category definitions. Unmatched API categories are appended, so the actual
  count can be higher than 15.
- Of those 15 seeded category modules, **2 have live product catalog support**:
  Pipes & Fitting and Electricals. The other 13 do not have a corresponding
  product feed wired into the current catalog mapper/controller.
- Home featured products, popular products, brands, offers, and search reuse
  catalog data already loaded from the server; these are not separate API
  endpoints.
- Checkout, cart, wishlist, quotations, rewards, profile/KYC, and order history
  currently use local, in-memory, or device-persisted state, not app REST APIs.
- Firebase Phone OTP is separate from the BuildMate REST API. The current API
  client’s authorization header is a literal masked string (`******`) rather
  than the retrieved Firebase token; authenticated REST calls therefore need
  this checked before they can be considered end-to-end authenticated.

## API workflow

### 1. App startup

1. `main()` creates the `SessionController`.
2. Firebase initialization is attempted. If successful, the phone-auth
   service attaches a Firebase ID-token provider to `ApiClient`.
3. The saved session is restored and then synchronized from the current Firebase
   user when available.
4. The app registers a `CatalogController` with the provider tree. Its
   creation starts the initial catalog sync and periodic refresh.
5. The app opens the splash route; after sign-in/guest flow, the shell displays
   the Home dashboard.

Firebase initialization is allowed to fail without blocking startup. A guest
session does not itself establish a Firebase user/token.

### 2. Home dashboard load

When `HomeDashboardScreen` is first shown, it schedules:

1. A device-location lookup if there is no current location fix.
2. `CatalogController.refreshHomeCatalog()`.

The catalog controller loads categories and then catalog rows. It maps those
responses into the app's catalog models and notifies listeners. Home then builds
its category grid and product/brand/offer sections from this controller state.

### 3. REST request and response handling

`ApiClient.getJson()` builds requests as:

```text
{API_BASE_URL}/api{path}
```

Configuration:

- Default base URL: `https://dash.buildmate24x7.com`
- Override: compile/run with `--dart-define=API_BASE_URL=<base-url>`
- API prefix: `/api`
- Request timeout: 15 seconds by default

The client:

1. Sends an HTTP GET, with an authorization header only when an auth-token
   provider returns a non-empty token.
2. Retries once after HTTP 401, requesting a forced token refresh.
3. Rejects non-2xx responses, invalid JSON envelopes, and envelopes where
   `success` is not `true`.
4. Returns the full decoded envelope to the repository.

The expected response is a JSON object with `success: true` and a payload in
`data` (the repository also accepts `items` or the envelope itself as a
fallback payload location).

### 4. Endpoints used by the client

| Request | Purpose | Consumer / handling |
|---|---|---|
| `GET /api/categories?active_only=true` | Loads active category records | `CatalogRepository.fetchCategories`; maps `id`, `name`, `productCount`, `imageUrl` into `Category` |
| `GET /api/catalog` | Preferred unfiltered catalog request | `CatalogRepository.fetchCatalogSkus`; parses raw catalog rows |
| `GET /api/catalog?category=<name>` | Fallback when the unfiltered catalog is empty or fails | Attempts known category names, deduplicates the merged rows by SKU id |
| `GET /api/catalog/tree?active_only=true` | Loads pipe type images from the catalog tree | Optional image enrichment; failures are swallowed and the app tries the subcategory image path |
| `GET /api/subcategories?category_id=<id>` | Fallback image source for pipe types | Maps subcategory images into UPVC/CPVC/PVC type image URLs |

There are no `POST`, `PUT`, or `DELETE` calls in the app's shared REST client.
The current screens do not submit cart, checkout, address, order, quotation,
reward, profile, or KYC changes to a BuildMate REST endpoint.

### 5. Catalog fallback and mapping

`CatalogRepository.fetchCatalogSkus()` first requests the complete catalog.
When the result is empty or the request throws, it tries category-specific
queries built from the returned API categories and known pipes/electrical
category name variants. Successful results are merged by catalog row id.

`CatalogController` filters rows to active products and currently recognizes
only categories whose names match pipes or electricals. Those rows are mapped
to variants and grouped into the Pipes & Fitting and Electricals catalog trees.
The category ids are taken from matching API category records.

If a category/tree image request fails, the image is treated as optional; the
product catalog can still be used. If catalog requests fail, the controller
stores an error and the UI may display an empty state. Static category seeds
can still make the Home grid appear populated, but they do not mean that their
product data loaded.

### 6. Refresh behavior

- The dashboard pull-to-refresh calls `refreshHomeCatalog()`.
- `CatalogController` also polls catalog data every 3 seconds
  (`ApiConfig.catalogPollInterval`) while the controller is alive.
- Polling refreshes categories and catalog data, retaining the last good
  categories if category loading fails during that refresh.
- Catalog tree/subcategory image lookups occur as catalog rows are applied.
- Catalog requests are shared by Home, category browsing, product lists, search,
  brands, and offers through `CatalogController`; those screens generally
  filter the in-memory latest catalog rather than making their own requests.

## Dashboard modules

### Category grid: 15 seeded modules

`HomeDashboardCategories.forDashboard()` starts with the 15 definitions below.
For each seed it uses a matching API category if present; otherwise it creates
a local fallback category. Any API categories not matched to a seed are appended.
Consequently, **15 is the seeded baseline, not a guaranteed runtime total**.

| # | Dashboard category module | Server product data status | Notes |
|---:|---|---|---|
| 1 | Pipes & Fitting | **Complete — live catalog** | Active rows are loaded from `/api/catalog`, mapped to variants, and displayed in the live pipe/fitting catalog. |
| 2 | Electricals | **Complete — live catalog** | Active electrical rows are loaded from `/api/catalog` and displayed through the electrical catalog screen. |
| 3 | Valves & Controls | **Not complete** | The category tile can be shown, but the current controller does not map valve products into a live module catalog. |
| 4 | Sanitarywares | **Not complete** | No live sanitaryware product mapping/feed is wired into the app catalog state. |
| 5 | Cement & Plaster | **Not complete** | No live product feed is wired for this category. |
| 6 | Tiling & Grouts | **Not complete** | No live product feed is wired for this category. |
| 7 | Paints & Putty | **Not complete** | No live product feed is wired for this category. |
| 8 | Plywood & MDF | **Not complete** | No live product feed is wired for this category. |
| 9 | Fevicol & Adhesives | **Not complete** | No live product feed is wired for this category. |
| 10 | Furniture Fittings | **Not complete** | No live product feed is wired for this category. |
| 11 | Locks & Handles | **Not complete** | No live product feed is wired for this category. |
| 12 | Hardware & Tools | **Not complete** | No live product feed is wired for this category. |
| 13 | Waterproofing & Repair | **Not complete** | No live product feed is wired for this category. |
| 14 | Safety Gear | **Not complete** | No live product feed is wired for this category. |
| 15 | Construction Materials | **Not complete** | No live product feed is wired for this category. |

The generic category route opens a `ProductListScreen`, but that screen reads
from the catalog variants already held by `CatalogController`. The current
controller only creates variants for pipes and electricals, so the generic
route does not by itself complete the other category modules.

### Other Home dashboard sections

| Dashboard section | Status | Data source |
|---|---|---|
| Location bar | **Not BuildMate API-backed** | Device location/geocoding and locally held location state |
| Search | **Server-fed, client-side search** | Searches the loaded catalog variants and loaded categories; no search endpoint is called |
| Featured banner carousel | **Local/demo content** | `HomeMockData.banners` |
| Featured products | **Server-fed** | Derived from loaded catalog variants, sorted by discount then price |
| Popular brands | **Server-fed** | Brand list is derived from loaded catalog variants |
| Popular products | **Server-fed** | Derived from loaded catalog variants, ordered by stock and name |
| Recently viewed | **Local state** | `RecentlyViewedController`; no server history request |
| Current offers | **Server-fed** | Derived from catalog variants with a positive discount; no offers endpoint |
| Construction Tools / quick actions | **Not part of the rendered Home dashboard content** | Demo definitions exist in `HomeMockData`, but the current Home screen does not render the quick-action/construction-tools sections |

“Server-fed” in this table means the data originates from `/api/catalog` or
`/api/categories`; it does not imply a dedicated backend endpoint or that all
product categories are supported.

## Other app modules and persistence status

| App area | Current data/persistence | BuildMate REST API status |
|---|---|---|
| Authentication | Firebase Phone OTP; user session also saved locally | Firebase is used, not a BuildMate auth endpoint |
| Cart and coupons | In-memory `CartController` | No server cart or coupon request |
| Address selection and checkout | UI state and sample/local address data; payment/order flow constructs local models | No server address, payment, or order request |
| Order history | JSON in device `SharedPreferences` | Local persistence; no remote order-history request |
| Quotations | In-memory controller, including seeded demo quotations | No remote quotation create/read/update request |
| Rewards | In-memory reward repository with demo seed/ledger logic | No remote reward balance/ledger request |
| Profile and KYC | `InMemoryProfileRepository` | No remote profile/KYC request |
| Wishlist | In-memory list | No remote wishlist request |
| Find Dealer, notifications, AI assistant, and other placeholder routes | Placeholder/UI route behavior | No server data feed identified in the client |

## Completion assessment

### Complete under the requested “fetching data from server” criterion

1. **Pipes & Fitting catalog** — live API catalog rows are loaded and mapped to
   products/variants.
2. **Electricals catalog** — live API catalog rows are filtered and mapped into
   the electrical catalog screen.
3. **Category metadata** — `/api/categories` is called, but the dashboard
   category grid merges this data with local seeds; it is therefore a
   **hybrid**, not a wholly API-defined module list.
4. **Home product/brand/offer/search sections** — they consume loaded server
   catalog data, but offers, brands, and search are derived/client-side rather
   than fetched from dedicated endpoints.

### Not complete under that criterion

- The other 13 seeded category product modules.
- Server-backed cart, checkout, payment, address, order history, 
  rewards, profile/KYC, and wishlist.
- Server-backed banners, recently viewed products, and location.

## Important implementation caveats

1. **Authorization header value:** `ApiClient._authHeaders()` obtains a Firebase
   token but currently returns `Authorization: ******`, a literal value rather
   than the token. The 401 refresh retry repeats that header construction. If
   the API requires Firebase bearer authentication, REST authentication is not
   currently wired correctly.
2. **Only GET is implemented:** the shared REST client has no write methods.
   Any feature requiring server-side mutations is not complete even if its
   screen flow is present.
3. **Category tiles can overstate readiness:** seeded fallback tiles are
   rendered even when the API has not provided the category, while only Pipes
   & Fitting and Electricals have product rows mapped by the controller.
4. **Fallback errors:** category/catalog failures are handled by controller
   state and logged in debug paths. The optional catalog-tree image lookup
   falls back to subcategory images or no image; image availability is not a
   catalog-completion signal.
5. **Navigation shell:** the shell contains five tab bodies (Home, Categories,
   Wishlist, Quotations, Profile), but the `bottomNavigationBar` widget is
   currently commented out in `MainShell`.

## Main code references

- API configuration/client: [`lib/core/network/api_config.dart`](./lib/core/network/api_config.dart), [`lib/core/network/api_client.dart`](./lib/core/network/api_client.dart)
- App setup and providers: [`lib/main.dart`](./lib/main.dart)
- Firebase bootstrap and phone auth: [`lib/core/firebase/firebase_bootstrap.dart`](./lib/core/firebase/firebase_bootstrap.dart), [`lib/services/auth_service.dart`](./lib/services/auth_service.dart)
- Catalog HTTP methods: [`lib/features/catalog/data/repositories/catalog_repository.dart`](./lib/features/catalog/data/repositories/catalog_repository.dart)
- Catalog mapping: [`lib/features/catalog/data/mappers/catalog_api_mapper.dart`](./lib/features/catalog/data/mappers/catalog_api_mapper.dart)
- Catalog loading, filtering, and polling: [`lib/core/state/catalog_controller.dart`](./lib/core/state/catalog_controller.dart)
- Home dashboard: [`lib/features/home/presentation/screens/home_dashboard_screen.dart`](./lib/features/home/presentation/screens/home_dashboard_screen.dart)
- Seeded/dynamic dashboard categories: [`lib/features/home/presentation/widgets/home_dashboard_categories.dart`](./lib/features/home/presentation/widgets/home_dashboard_categories.dart)
- Local demo Home data: [`lib/features/home/data/mock/home_mock_data.dart`](./lib/features/home/data/mock/home_mock_data.dart)
- App route dispatch: [`lib/core/routes/app_router.dart`](./lib/core/routes/app_router.dart)
