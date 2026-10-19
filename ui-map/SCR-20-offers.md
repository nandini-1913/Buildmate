# SCR-20 — Offers

- Route: `/offers` (`AppRoutes.offers`)
- Source files: [offers_screen.dart](../lib/features/catalog/presentation/screens/offers_screen.dart) (181 lines; offers list at lines 11-91); [catalog_controller.dart](../lib/core/state/catalog_controller.dart); [catalog_models.dart](../lib/features/catalog/domain/models/catalog_models.dart)
- Purpose: List discounted catalog variants as offer cards and open the selected offer’s detail route.

## Data

- Screen reads `CatalogController.catalogOffers`; it does not initiate a fetch (`offers_screen.dart:11-19`).
- Controller derives offers from pipe variants with `discountRate > 0`, sorts by discount descending, and maps each variant to an offer (`lib/core/state/catalog_controller.dart:317-336`).
- Each derived offer uses variant ID as offer ID, product name as title, `${brandName} · ${displayName}` as description, rounded `discountRate * 100` plus `% OFF` as discount label, and a singleton product ID list containing variant ID (`catalog_controller.dart:326-335`).
- Tapping a card pushes `/offer-detail` with its offer ID (`offers_screen.dart:39-47`).
- No screen-specific API call or action mutation is defined.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| OFF-TXT-01 | App-bar title | `Current Offers` | Static title (`offers_screen.dart:19-23`) | Always | N | Y |
| OFF-STATE-01 | Loading indicator | No text | Circular progress indicator (`offers_screen.dart:24-26`) | `catalog.isLoading && offers.isEmpty` | N | Y |
| OFF-STATE-02 | Empty state | `No discounted products on the server right now` | Replaces offer list (`offers_screen.dart:26-30`) | No offers and not in loading branch | N | Y |
| OFF-CARD-01 | Offer card | Dynamic `offer.discountText`, `offer.title`, `offer.description` | Tapping card navigates to `/offer-detail` with `OfferDetailArgs(offerId: offer.id)` (`offers_screen.dart:30-90`) | One card per positive-discount variant | Y — preserve card-to-offer ID pairing; current order is descending discount rate (`catalog_controller.dart:318-323`) | Y |

## States and messages

- Loading with no offers: centered circular progress indicator (`offers_screen.dart:24-26`).
- Empty after loading: `No discounted products on the server right now` (`offers_screen.dart:26-30`).
- Loaded state: offer list; no success, error, validation, confirmation, upload, or passcode message is defined.

## Displayed values

- Offer count/order and content derive from `catalogOffers` (positive discount variants sorted descending) (`lib/core/state/catalog_controller.dart:317-335`).
- Discount percentage is `((discountRate ?? 0) * 100).round()` rendered as `<integer>% OFF` (`catalog_controller.dart:326-332`).
- Card title is product name; description combines brand and variant display name with ` · ` (`catalog_controller.dart:327-331`).
- `validUntil` is set to empty string by controller and is not displayed by this screen (`catalog_controller.dart:332-335`; `offers_screen.dart:30-90`).

## Style with meaning

- Discount label uses secondary-container/secondary styling, distinguishing discount from title and description (`offers_screen.dart:53-69`). Preserve its discount meaning if palette changes.
- Loading and empty state replace the list. No selected, availability, or other business state is represented.

## Keyboard and focus

- No text input, keyboard shortcut, custom focus order, autofocus, or explicit Escape handler.
- Offer cards use Material `InkWell` feedback.

## Responsive

- Offers use a vertically scrolling separated list with fixed spacing; no breakpoint is defined (`offers_screen.dart:30-36`).

## Risk notes

- Each whole-card tap must retain the matching offer ID; the offer detail screen resolves by that ID (`offers_screen.dart:39-47`; `catalog_controller.dart:338-343`).
- Card order is generated from descending discount rate, not an explicit user sort control (`catalog_controller.dart:318-323`).
