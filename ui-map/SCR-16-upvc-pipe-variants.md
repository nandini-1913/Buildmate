# SCR-16 — UPVC pipe variants

- Route: `/upvc-pipe-variants` (`AppRoutes.upvcPipeVariants`); route arguments: optional subcategory ID, product ID, title, hero image asset, and category IDs
- Source files: [upvc_pipe_variant_list_screen.dart](../lib/features/catalog/presentation/screens/upvc_pipe_variant_list_screen.dart) (1014 lines); [pipes_filter_panel.dart](../lib/features/catalog/presentation/widgets/pipes_filter_panel.dart); [pipe_schedule_util.dart](../lib/features/catalog/data/pipe_schedule_util.dart); [upvc_pipe_matrix_data.dart](../lib/features/catalog/data/mock/upvc_pipe_matrix_data.dart)
- Purpose: Configure a pipe variant by size/type/brand, inspect catalog images, and add the resolved in-stock variant to cart.

## Data

- Screen reads `CatalogController.pipeVariants`. When `categoryIds` is present, it selects variants with matching category IDs; otherwise it uses `pipeVariantsForSubCategory(subCategoryId)` (`upvc_pipe_variant_list_screen.dart:57-72`).
- This screen does not initiate a catalog fetch. It consumes catalog state prepared by shared app/controller flows; no filter, selection, carousel, search, or cart action on this screen issues an API call (`upvc_pipe_variant_list_screen.dart:32-54,498-617`).
- Route-supplied `productId` scopes initial tapped-product matching. `title` is fallback heading, `heroImageAsset` is used only if variant images are unavailable, and `categoryIds` controls the catalog subset (`upvc_pipe_variant_list_screen.dart:24-29,73-78,438-463,489-495`).
- Initial selection is scheduled after frame and picks the cheapest in-stock tapped-product variant; if there is no tapped match, it tries a hard-coded default matching brand `Astral`, type `Sch 40`, and size `15 MM (1/2")`, then cheapest variant in the catalog subset (`upvc_pipe_variant_list_screen.dart:120-157,328-342`).
- Brand, size, type, and sort selection filter/sort in-memory variants. Brand and type/size option lists derive from the current catalog subset and selected brand/type/size; sort applies discounts, price, reversed order, or rating (`upvc_pipe_variant_list_screen.dart:80-119,164-237,240-280`).
- Add-to-cart uses shared `CartController.addVariant(variant)` and shows `${variant.displayName} added to cart` floating snackbar (`upvc_pipe_variant_list_screen.dart:458-480`).
- Search header tap navigates to `/search` with empty args; submit navigates to `/search` with `initialQuery` (`upvc_pipe_variant_list_screen.dart:628-713`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| UPV-BTN-01 | Icon button | No visible text (back arrow) | Calls `Navigator.maybePop()` (`upvc_pipe_variant_list_screen.dart:628-665,737-749`) | Screen open | N | Y |
| UPV-IN-01 | Search input | `Search products` | Tap navigates to `/search`; submit navigates with entered query (`upvc_pipe_variant_list_screen.dart:681-713`) | Screen open | N | Y |
| UPV-IMG-01 | Swipeable image carousel | No text | `PageView` displays distinct variant image URLs/assets or a fallback image; swipe changes `_carouselIndex` (`upvc_pipe_variant_list_screen.dart:438-463,520-529,763-832`) | Screen open; always at least one slide is created | Y — image and page position must stay paired | Y |
| UPV-IMG-02 | Page indicator | No text (active/inactive dots) | Display-only current carousel page indicator; shown for more than one slide (`upvc_pipe_variant_list_screen.dart:802-827`) | More than one carousel slide | N | Y |
| UPV-TXT-01 | Product title | Dynamic selected variant name, `widget.title`, or `Pipe configurator` | Heading uses `variant.productName ?? widget.title ?? 'Pipe configurator'` (`upvc_pipe_variant_list_screen.dart:489-496,532-539`) | Screen open | N | Y |
| UPV-SEL-01 | Select | `Select size` or selected size; dynamic options | Updates size; attempts to synchronize brand/type to a matching variant. Disabled if no size options (`upvc_pipe_variant_list_screen.dart:207-218,232-238,535-543,958-1014`) | Screen open; disabled when size options empty | Y — option value must remain paired with size handler | Y |
| UPV-SEL-02 | Select | `Select type` or selected type; dynamic options | Updates type; attempts to synchronize brand/size to a matching variant. Disabled if no type options (`upvc_pipe_variant_list_screen.dart:220-230,240-257,544-551,958-1014`) | Screen open; disabled when type options empty | Y — option value must remain paired with normalized pipe type | Y |
| UPV-CARD-01 | Add-to-cart card | `Selected Product Size`; `₹`; rounded price or `—`; `/ <unit>`; selected size or `Out of stock`; button `Add to Cart` | Displays currently resolved variant. Button adds variant and shows success snackbar; disabled if variant absent or not in stock (`upvc_pipe_variant_list_screen.dart:489-497,553-557,858-952`) | Always shown; button active only when variant exists and is in stock | N | Y |
| UPV-STATE-01 | Loading indicator | No text | Linear progress indicator (`upvc_pipe_variant_list_screen.dart:570-574`) | Catalog is loading and selected catalog subset is empty | N | Y |
| UPV-STATE-02 | Empty catalog message | `No products available.` | Display-only message (`upvc_pipe_variant_list_screen.dart:575-590`) | Catalog is not loading and subset is empty | N | Y |
| UPV-STATE-03 | Filter backdrop | No text | Tap closes active filter panel (`upvc_pipe_variant_list_screen.dart:592-601`) | A filter tab is open | N | Y |
| UPV-FLT-01 | Filter tab | `Sort By` | Opens sort panel; selected sort changes local variant order (`upvc_pipe_variant_list_screen.dart:608-616`; `pipes_filter_panel.dart:507-535`) | Bottom filter chrome always shown | Y — preserve tab-to-panel mapping | Y |
| UPV-FLT-02 | Filter tab | `Size` | Opens size panel. Choosing a size applies it; tapping selected size again clears size (`upvc_pipe_variant_list_screen.dart:608-616,390-405`; `pipes_filter_panel.dart:337-380,536-544`) | Bottom filter chrome always shown | Y — keep size labels paired with value | Y |
| UPV-FLT-03 | Filter tab | `Brand` | Opens brand panel. Choosing selected brand again clears brand; brand change synchronizes resolved variant when matches exist (`upvc_pipe_variant_list_screen.dart:608-616,406-431`; `pipes_filter_panel.dart:383-426,545-555`) | Default `showBrandTab` is true | Y — keep brand labels paired with brand values | Y |
| UPV-PANEL-01 | Filter panel heading | `Sort By`, `Size`, or `Brands` | Heading corresponds to active tab (`pipes_filter_panel.dart:233-303`) | Filter panel open | Y — must match active panel | Y |
| UPV-PANEL-ACT-01 | Icon button | No visible text (close icon) | Closes the filter panel (`pipes_filter_panel.dart:244-265`; parent callback `upvc_pipe_variant_list_screen.dart:608-616`) | Filter panel open | N | Y |
| UPV-PANEL-02 | Sort option | `All`; `Discount`; `Price (lowest first)`; `What’s New`; `Price (highest first)`; `Ratings` | Sets sort enum and updates resolved variant (`pipes_filter_panel.dart:307-335`; screen sorting `upvc_pipe_variant_list_screen.dart:80-119,608-616`) | Sort panel open | Y — option ordering and enum mapping are meaningful | Y |
| UPV-PANEL-03 | Size option | `15 mm`, `20 mm`, `25 mm`, `32 mm`, `40 mm`, `50 mm`, `65 mm`, `80 mm`, `100 mm`, `150 mm`, `200 mm`, `250 mm`, `300 mm` | Sets selected size; tapping the current size again clears it (`lib/features/catalog/presentation/widgets/pipes_filter_panel.dart:16-37,337-380`; screen handler `upvc_pipe_variant_list_screen.dart:390-405`) | Size panel open | Y — retain size labels, two-column membership/order and toggle behavior | Y |
| UPV-PANEL-04 | Brand option | Dynamic distinct sorted brand names; empty state `No brands in catalog` | Selects/toggles brand filter; options derive from all variants in current screen subset (`pipes_filter_panel.dart:37-72,383-426`; screen `upvc_pipe_variant_list_screen.dart:608-616`) | Brand panel open | Y — each visible brand maps to matching variant brand | Y |
| UPV-MSG-01 | Snackbar | `${variant.displayName} added to cart` | Floating snackbar with check icon after cart controller update (`upvc_pipe_variant_list_screen.dart:458-480`) | Active Add to Cart action invoked | N | Y |

## States and messages

- With empty variant subset and catalog loading, the page content shows a linear progress indicator below the configurator controls; when not loading it shows `No products available.` (`upvc_pipe_variant_list_screen.dart:570-590`).
- With catalog results, the currently resolved variant drives title, dropdown selections, selected size, price, unit, and Add to Cart enabled state (`upvc_pipe_variant_list_screen.dart:489-557`).
- The filter backdrop and panel appear when `_openFilter != null`; close icon and backdrop tap close the panel (`upvc_pipe_variant_list_screen.dart:592-616`).
- Empty brand list shows `No brands in catalog` (`lib/features/catalog/presentation/widgets/pipes_filter_panel.dart:396-408`).
- Out-of-stock current variant displays `Out of stock` and disables Add to Cart (`upvc_pipe_variant_list_screen.dart:905-927`).
- Adding an enabled variant shows `${variant.displayName} added to cart` floating snackbar (`upvc_pipe_variant_list_screen.dart:458-480`).
- No confirmation, validation, upload, or passcode popup is defined.

## Displayed values

- Title is selected variant product name, then route title, then `Pipe configurator` (`upvc_pipe_variant_list_screen.dart:489-496`).
- Product image slides comprise distinct non-empty image URLs/assets in source variant order; if no slides exist, use supplied hero asset, otherwise selected/default pipe image fallback (`upvc_pipe_variant_list_screen.dart:438-463`).
- Size options are unique non-empty `Size` specifications sorted with `UpvcPipeMatrixData.compareSizeLabels`; type labels normalize `pipeType` or `Type` spec via `PipeScheduleUtil.normalizePipeSchedule` and sort alphabetically (`upvc_pipe_variant_list_screen.dart:176-203,209-230`).
- Brand options are unique brand IDs sorted by resolved brand display name; brand labels use catalog brand name or brand ID fallback (`upvc_pipe_variant_list_screen.dart:205-208`).
- Initial selection prefers cheapest in-stock tapped-product variant; fallback is Astral / Sch 40 / `15 MM (1/2")`; last fallback is cheapest in-stock subset variant, or cheapest variant if none are in stock (`upvc_pipe_variant_list_screen.dart:120-157,328-342`).
- Displayed price is `sellingPrice ?? price`; price card formats non-null price using `toStringAsFixed(0)`; unit is selected variant unit or `piece`; selected size is filter value or variant `Size` (`upvc_pipe_variant_list_screen.dart:489-497,858-911`).
- Sort semantics: All preserves order; Discount descending by effective discount; low/high price uses selling price or price; What’s New reverses; Ratings sorts descending (`upvc_pipe_variant_list_screen.dart:80-119`).
- Selected size with no current variant displays `—`; out-of-stock card label replaces selected size (`upvc_pipe_variant_list_screen.dart:905-916`).

## Style with meaning

- Selected size/brand/type are reflected in controls; selected filter options use an indicator and selected-state treatment (`upvc_pipe_variant_list_screen.dart:164-203,390-431`; `pipes_filter_panel.dart:432-490`).
- Carousel page indicator distinguishes current page from inactive pages (`upvc_pipe_variant_list_screen.dart:802-827`).
- Out-of-stock state uses `Out of stock`, error color, and disabled action styling; retain its distinction from enabled/in-stock state (`upvc_pipe_variant_list_screen.dart:905-927`).
- Selected bottom filter tab and selected option have distinct styling; preserve current selection state (`pipes_filter_panel.dart:432-490,507-560`).
- Filter-panel backdrop indicates an open overlay and dismisses it; keep this state and dismissal behavior (`upvc_pipe_variant_list_screen.dart:592-601`).

## Keyboard and focus

- Search input uses `TextInputAction.search`; tapping field routes to search and submitting sends its query as `initialQuery` (`upvc_pipe_variant_list_screen.dart:681-713`).
- No autofocus, explicit Escape handler, custom focus order, or other keyboard shortcuts are defined. Dropdowns and filter options use native Flutter interaction.
- Carousel supports horizontal page gestures; filter options and controls use tap feedback.

## Responsive

- Main content scrolls vertically; image viewport has fixed height 220 logical pixels (`upvc_pipe_variant_list_screen.dart:510-537,764-800`).
- Bottom filter panel maximum height is 42% of screen height and its contents scroll (`lib/features/catalog/presentation/widgets/pipes_filter_panel.dart:206-225,265-290`).
- Size filter is divided into two columns; available width determines each column width (`pipes_filter_panel.dart:342-380`).
- No breakpoint or alternate layout is defined.

## Risk notes

- Initial filter defaults are intentionally tied to route args and catalog fingerprint; a catalog change resets selections and can trigger default selection (`upvc_pipe_variant_list_screen.dart:120-158`).
- Carousel uses `PageController` and updates current-page indicator; preserve pairing and controller ownership/disposal (`upvc_pipe_variant_list_screen.dart:49-55,763-832`).
- Size/type/brand dropdowns and bottom filter panel all update the same filter state and determine `_resolvedVariant`; keep displayed control values and callbacks connected (`upvc_pipe_variant_list_screen.dart:232-405,489-557`).
- Sort options are order-sensitive and change both available pool order and selected variant resolution. Unlike SCR-13’s pipe category groups, all six sort cases are implemented here (`upvc_pipe_variant_list_screen.dart:80-119`).
- Bottom filter panel overlays the main body with a dismissing backdrop; retain the overlay hit-testing and close behavior (`upvc_pipe_variant_list_screen.dart:592-616`).
- Add-to-cart card consumes resolved variant and is stock-gated; preserve selected variant, displayed price/size, enabled state, and cart callback as a single association (`upvc_pipe_variant_list_screen.dart:489-497,858-952`).
