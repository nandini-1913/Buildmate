# UI Contract Map

ALWAYS FREE: colours, fonts, spacing, sizes, radius, borders, shadows, and the layout of containers.

LOCKED unless the owner approves in writing: exact text, behaviour, whether an element exists, API calls, validation, formatting of values, and anything marked order-sensitive.

> Scope note: this checkout is a Flutter app (screens are under `lib/`); it does not contain the React `web/src` described in the original task. The user approved mapping the current Flutter app instead.

## Screens

| ID | Screen | Route | Status |
|---|---|---|---|
| SCR-01 | Splash | `/` | Complete |
| SCR-02 | Login | `/login` | Complete |
| SCR-03 | Create account | `/create-account` | Complete |
| SCR-04 | Choose location | `/choose-location` | Complete |
| SCR-05 | Choose profession | `/choose-profession` | Complete |
| SCR-06 | OTP verification | `/otp-verification` | Complete |
| SCR-07 | Forgot password | `/forgot-password` | Complete |
| SCR-08 | Reset password | `/reset-password` | Complete |
| SCR-09 | Password updated | `/password-updated` | Complete |
| SCR-10 | Main shell and tabs | `/main`, `/home-placeholder` | Complete |
| SCR-11 | Search | `/search` | Complete |
| SCR-12 | Categories | `/categories` | Complete |
| SCR-13 | Category browse / pipes category | `/category-browse` | Complete |
| SCR-14 | Product list | `/product-list` | Complete |
| SCR-15 | Product detail | `/product-detail` | Complete |
| SCR-16 | UPVC pipe variants | `/upvc-pipe-variants` | Complete |
| SCR-17 | Find dealer placeholder | `/dealers` | Complete |
| SCR-18 | Brands | `/brands` | Complete |
| SCR-19 | Brand products | `/brand-products` | Complete |
| SCR-20 | Offers | `/offers` | Complete |
| SCR-21 | Offer detail | `/offer-detail` | Complete |
| SCR-22 | Cart | `/cart` | Complete |
| SCR-23 | Select address | `/checkout/address` | Complete |
| SCR-24 | Add address | `/checkout/address/new` | Complete |
| SCR-25 | Payment | `/checkout/payment` | Complete |
| SCR-26 | Order confirmation | `/checkout/confirmation` | Complete |
| SCR-27 | Quotation review | `/quotation`, `/quotation-review` | Complete |
| SCR-28 | Wishlist placeholder | `/wishlist` | Complete |
| SCR-29 | Profile | `/profile` | Complete |
| SCR-30 | Notifications placeholder | `/notifications` | Complete |
| SCR-31 | Material calculator | `/material-calculator` | Complete |
| SCR-32 | Unit converter placeholder | `/unit-converter` | Complete |
| SCR-33 | Quantity estimator placeholder | `/quantity-estimator` | Complete |
| SCR-34 | My rewards | `/my-rewards` | Complete |
| SCR-35 | Admin quotations | `/admin-quotations` | Pending |
| SCR-36 | Admin quotation detail | `/admin-quotation-detail` | Pending |
| SCR-37 | AI assistant placeholder | `/ai-assistant` | Pending |

## Cross-screen contracts

| File | Status |
|---|---|
| [_global.md](./_global.md) | Pending |
| [_shared.md](./_shared.md) | Pending |
