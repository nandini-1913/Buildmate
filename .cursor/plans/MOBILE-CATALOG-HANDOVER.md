# Mobile catalog API — handover for frontend

**Audience:** Mobile / partner app developers building category → sub-category → type → product tiles → product detail.

**Backend:** `backend_refactor/` on VPS  
**Base URL:** `https://<your-host>/api` (same as partner app; see `docs/PARTNER-API.md` for auth envelope)

**Response envelope (every route):**

```json
{ "success": true, "data": <payload>, "error": null }
```

Use `data` only when `success` is true. On failure, `error` is a human-readable string.

**Auth:** Catalog read routes below are **public** (no Bearer token). Partner login is only for RFQ/account (`/auth/partner/*`).

---

## 1. App navigation (our plan)

| Step | Screen | What user sees | Data source |
|------|--------|----------------|-------------|
| 1 | Home | Category tiles (name + photo) | `GET /categories` |
| 2 | Sub-categories | UPVC / CPVC / PVC tiles (name + photo) | `GET /subcategories` |
| 3 | Product listing | Left sidebar: **Sub-Category** (material) then **Type** (Pipe, Fitting, …); right: **product tiles** | `GET /catalog` + **client-side** grouping |
| 4 | Product detail | One image, name, **Size / Brand / Class** as buttons; price changes per SKU | Same SKUs from step 3, filtered in app |

**Important:** Dashboard only **uploads the master sheet** and **serves JSON**. The app **groups tiles** and **builds filters** — there is no server endpoint that returns “20 tiles with variant count”.

---

## 2. Master sheet → API fields

Header row (what operations upload):

```text
Category, Sub-Category, Type, class, Brand, product, Product Name, Size (cm), Length, Product Code, HSN Code, GST, UoM, MRP (Rs) per nos, discount, Selling Price, Pack Size, MRP Pkg, ROL, Display sequence, image_url
```

| Sheet column | JSON field on each SKU | App usage |
|--------------|------------------------|-----------|
| Category | `category` | Home + filters |
| Sub-Category | `subcategory` | Sidebar (UPVC, CPVC, PVC) |
| Type | `type` | Sidebar (Pipe, Fitting, Valves, …) |
| class | `productClass` | Detail + filters (SDR 11, Sch 40, …) |
| Brand | `brand` | **Not** in tile title; use as filter/button |
| **product** | **`productGroup`** | **Tile grouping key** — same string on all variants = one tile |
| Product Name | `productName`, `name` | Tile title (generic name, no brand) |
| Size (cm) | `sizeCm`, `sizeMm`, `size`, `sizeInch` | Size buttons on detail |
| Length | `length` | Variant attribute |
| Product Code | `productCode`, `qrCode` | Cart, scan |
| Display sequence | `displaySequence` | Sort order of tiles (see §5) |
| image_url | `imageUrl` | Tile / detail image |
| MRP / discount / Selling Price | `mrp`, `discount`, `sellingPrice`, `standardRate` | Prices |

**Tile grouping rule**

- Group rows where `productGroup` is the same non-empty string (this value comes from sheet column **`product`**).
- Badge “N products” = count of SKUs in that group.
- Tile title: use `productName` (or `name`) from any row in the group — they should match within a group.
- Do **not** use `GET /product-groups` for tiles; that is an admin-only feature (links product IDs in the dashboard).

**Brand on listing**

- Product names in the sheet intentionally **omit** brand. Brand is only `brand` on each SKU → filter dropdown or buttons.

---

## 3. Routes to implement (required)

### 3.1 Categories (home)

```http
GET /api/categories?active_only=true
```

**`data`:** array of objects

| Field | Type | Notes |
|-------|------|--------|
| `id` | string | Use for subcategories query |
| `name` | string | Match `catalog.category` |
| `imageUrl` | string \| null | Tile image |
| `productCount` | number | Optional badge |
| `isActive` | boolean | Hide inactive |

---

### 3.2 Sub-categories (after category tap)

```http
GET /api/subcategories?category_id={categoryId}
```

Omit `category_id` to list all subcategories (usually pass `category_id`).

**`data`:** array of objects

| Field | Type | Notes |
|-------|------|--------|
| `id` | string | |
| `name` | string | Match `catalog.subcategory` |
| `categoryId` | string | Parent category |
| `category` | string | Parent category name |
| `productCount` | number | SKUs under this subcategory |

**Gap (backend):** `imageUrl` on subcategories is **not** returned yet. Use placeholder until dashboard adds it.

---

### 3.3 Catalog (SKUs — listing, filters, detail)

```http
GET /api/catalog
```

**Query parameters (all optional, combine as needed):**

| Query | Maps to SKU field |
|-------|-------------------|
| `category` | `category` |
| `subcategory` | `subcategory` |
| `type` | `type` |
| `brand` | `brand` |
| `product_class` | `productClass` |
| `product_group` | `productGroup` (sheet **`product`**) |
| `size_mm` | `sizeMm` |
| `search` | name, product code, brand, aliases |
| `group_id` | `productGroupIds` — admin only; ignore for mobile tiles |

**Example — fittings under UPVC:**

```http
GET /api/catalog?category=Pipes%20%26%20Fittings&subcategory=UPVC&type=Fitting
```

**`data`:** array of SKU objects. Fields the app needs most:

| Field | Notes |
|-------|--------|
| `id` | Unique SKU |
| `name`, `productName` | Display name |
| `category`, `subcategory`, `type`, `productClass` | Hierarchy + filters |
| `brand` | Filter / buttons |
| `productGroup` | **Tile group key** |
| `displaySequence` | Sort (integer; 0 if missing) |
| `sizeMm`, `size`, `sizeInch`, `sizeCm`, `length` | Variants |
| `productCode`, `qrCode` | Cart / QR |
| `imageUrl` | Image |
| `mrp`, `discount`, `sellingPrice`, `standardRate` | Pricing |
| `unit` | e.g. pcs |
| `hsnCode`, `gstRate` | Billing if needed |
| `isActive` | Skip if false |

**There is no `GET /api/catalog/{id}`** — pick a SKU from the list by `id` or `productCode`, or refetch with `product_group=`.

**List sort today:** server sorts by `name`. After backend update, sort may use `displaySequence` — until then, **sort tiles on the client** (§5).

---

### 3.4 Sidebar counts and type list (client-side)

No dedicated API. After fetching catalog for the current category (and optional subcategory):

1. **Types** under selection: `distinct(type)` from rows.
2. **Counts** per type: count rows per `type`.
3. **Top filters** (Size, Brand, Class): distinct values from the current result set, or add query params on refetch.

---

### 3.5 Product detail (variants)

No extra route. Use SKUs that share the same `productGroup` (or the filtered list from the listing).

- **Size buttons:** unique values from `sizeMm` / `size` / `sizeInch` (app chooses display format).
- **Brand buttons:** unique `brand`.
- **Class buttons:** unique `productClass`.
- Selecting a combination should resolve to **one** SKU (`id`, `productCode`) for cart/RFQ.

Refetch variant if needed:

```http
GET /api/catalog?category=...&subcategory=...&type=...&product_group=COUPLER
```

---

## 4. Optional routes

### 4.1 Catalog tree (shortcut — not enough alone)

```http
GET /api/catalog/tree?active_only=true
```

Returns `data.categories[]`, each with nested `types[]` and `productCount`.

This is **category → type** only. It does **not** replace subcategories or sheet **Type** vs **Sub-Category** sidebar. Prefer §3.1–3.3 for our hierarchy.

### 4.2 Brands (global list)

```http
GET /api/brands
```

`data[]`: `id`, `name`, `logoUrl`, `isActive`. Optional; filters can use `brand` on each catalog row.

### 4.3 Image proxy

```http
GET /api/media/proxy?url={url-encoded-image-url}
```

Use if direct `imageUrl` fails (CORS/SSL).

### 4.4 Health check

```http
GET /api/
```

---

## 5. Display sequence (sorting tiles)

- **Purpose:** Control which **product group** appears first on the listing (e.g. all COUPLER variants before ELBOW).
- **Recommended sheet rule:** Same **Display sequence** on every row that shares the same **`product`** (`productGroup` in API).
- **App sort:** For each tile group, use `min(displaySequence)` among SKUs in the group, then alphabetical on title.
- **Variant count:** Use **number of SKUs** with the same `productGroup`, not how many times the sequence number repeats.

---

## 6. Route status summary

| Route | Status | Mobile use |
|-------|--------|------------|
| `GET /categories` | ✅ Ready | Home |
| `GET /subcategories` | ✅ Ready (no subcat image yet) | Sub-category screen |
| `GET /catalog` | ✅ Ready | Listing + detail SKUs |
| `GET /brands` | ✅ Ready | Optional |
| `GET /media/proxy` | ✅ Ready | Images |
| `GET /catalog/tree` | ✅ Ready | Optional; not full hierarchy |
| `GET /catalog/{id}` | ❌ Not implemented | Use list + filters |
| `GET /catalog/groups` or `/facets` | ❌ Not implemented | Group/filter in app |
| Sheet `product` → API | ⚠️ Stored as `productGroup` | Use `productGroup` in JSON |
| `Display sequence` on import | 🔜 Planned | Client sort with `displaySequence` when present |
| Subcategory `imageUrl` | 🔜 Planned | Placeholder until then |

---

## 7. End-to-end example

1. `GET /api/categories?active_only=true` → user picks category **"Plumbing Pipes & Fittings"** → save `id` and `name`.
2. `GET /api/subcategories?category_id={id}` → user picks **UPVC**.
3. `GET /api/catalog?category=Plumbing%20Pipes%20%26%20Fittings&subcategory=UPVC` → build sidebar **types** (Pipe, Fitting, …).
4. User selects **Fitting** → filter rows where `type === "Fitting"`.
5. Group by `productGroup` → e.g. one tile for **COUPLER**, badge = row count, title = `productName`.
6. User opens tile → show buttons for sizes/brands/class from those rows; on select, show that SKU’s price and `productCode`.

---

## 8. Smoke tests (curl)

Replace host and names with production values.

```bash
curl -s "https://YOUR_HOST/api/"
curl -s "https://YOUR_HOST/api/categories?active_only=true"
curl -s "https://YOUR_HOST/api/subcategories?category_id=CATEGORY_UUID"
curl -s "https://YOUR_HOST/api/catalog?category=CATEGORY_NAME&subcategory=UPVC&type=Fitting"
```

---

## 9. Related docs

- Partner auth, RFQ, rewards: `docs/PARTNER-API.md`
- Sheet column meanings (admin): `demo-notes/SHEET-FORMAT.md` (being updated for `product` + Display sequence)

**Questions:** Dashboard/backend team — not UI layout. App team owns grouping, sidebar, and tile UX.
