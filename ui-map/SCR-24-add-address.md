# SCR-24 — Add address

- Route: `/checkout/address/new` (`AppRoutes.addAddress`)
- Source files: [add_address_screen.dart](../lib/features/checkout/presentation/screens/add_address_screen.dart) (1120 lines); [address_models.dart](../lib/features/checkout/domain/models/address_models.dart); [auth_validators.dart](../lib/features/auth/presentation/widgets/auth_validators.dart)
- Purpose: Collect a delivery address, optionally pin it on a map or use the simulated current-location action, and return a validated `DeliveryAddress`.

## Data

- Router creates `AddAddressScreen` with default `showMapPreview: true` (`lib/core/routes/app_router.dart:183-185`; `add_address_screen.dart:19-25`).
- No address-save API or GPS plugin is called. Pincode lookup uses local `PincodeDirectory` entries after a 450 ms delay (`lib/features/checkout/domain/models/address_models.dart:50-78`).
- The map uses OpenStreetMap tile URL `https://tile.openstreetmap.org/{z}/{x}/{y}.png`; dragging map updates the local pin center, and the pin stays visually centered (`add_address_screen.dart:802-897`).
- `Use my current location` simulates a location after 1100 ms using fixed coordinates and populates area/pincode/city/state; if map preview is enabled, map moves to the simulated point at zoom 16 (`add_address_screen.dart:33-36,98-125`).
- Pincode change below six characters sets status idle; at six or more it performs local directory lookup. A stale response is ignored if the input changed; a match fills city/state and a miss leaves them for manual entry (`add_address_screen.dart:76-96`).
- Save validates the form, then waits 600 ms and pops with a `DeliveryAddress` built from trimmed fields; `location` is included only when map preview is enabled (`add_address_screen.dart:127-154`).
- Cart count in header comes from shared `CartController`; no cart mutation occurs (`add_address_screen.dart:166-170`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| AAD-BTN-01 | Icon button | Tooltip `Back`; no visible text (back arrow) | Calls `Navigator.maybePop()`; route returns null if cancelled (`add_address_screen.dart:411-418`) | Always | N | Y |
| AAD-TXT-01 | Header title | `Add New Address` | Static title (`add_address_screen.dart:420-427`) | Always | N | Y |
| AAD-BTN-02 | Disabled icon button | Tooltip `Cart`; cart icon and optional `${cartCount}`/`99+` badge | `onPressed: null`; badge hidden at zero and capped at 99+ (`add_address_screen.dart:428-448`) | Always | N | Y |
| AAD-TXT-02 | Checkout step labels | `1. Cart`; `2. Address`; `3. Payment`; `4. Confirm`; `Step 2 of 4` | Static progress indicator; current step index 1 (`add_address_screen.dart:388-484`) | Always | Y — preserve checkout step order | Y |
| AAD-ACT-01 | Current-location button | `Use my current location` or `Detecting location…`; `Auto-fill your address using GPS` | Starts simulated location lookup, fills area, pincode, city, state, centers map if present, shows snackbar, and focuses house field. Disabled while locating (`add_address_screen.dart:98-125,493-566`) | Always | N | Y |
| AAD-SEP-01 | Divider text | `OR ENTER MANUALLY` | Display-only separator (`add_address_screen.dart:569-594`) | Always | N | Y |
| AAD-TXT-03 | Section heading | Rendered `CONTACT DETAILS` | Screen passes `Contact Details`; `_SectionCard` uppercases it (`add_address_screen.dart:200-203`; section widget `add_address_screen.dart:597-641`) | Always | N | Y |
| AAD-IN-01 | Text input | `Full Name`; validation messages `Full name is required`, `Enter a valid full name` | Text-capitalizes words; validates trimmed nonempty value and minimum length two (`add_address_screen.dart:204-210`; `auth_validators.dart:31-37`) | Always | N | Y |
| AAD-IN-02 | Phone input | `Mobile Number`; prefix `+91`; validation messages `Mobile number is required`, `Enter a valid 10-digit mobile number` | Phone keyboard, digits-only formatter, max 10 digits; validates Indian mobile prefix/range (`add_address_screen.dart:211-224`; `auth_validators.dart:39-46`) | Always | N | Y |
| AAD-TXT-04 | Section heading | Rendered `ADDRESS` | Screen passes `Address`; section widget uppercases it (`add_address_screen.dart:228-231,597-641`) | Always | N | Y |
| AAD-IN-03 | Pincode input | `Pincode`; validation `Pincode is required`, `Enter a valid 6-digit pincode`; helper `City & State fill in automatically`, `Delivery available · City & State filled`, or `Couldn't find this pincode — enter City & State` | Numeric keyboard, digits-only, maximum six digits; changes trigger local pincode lookup (`add_address_screen.dart:232-259`; validator `add_address_screen.dart:156-164`) | Always | N | Y |
| AAD-STATE-01 | Pincode suffix state | No text (spinner/check/info icon) | Loading, found, not-found, or idle indicator (`add_address_screen.dart:766-798`) | Trailing icon varies with pincode status | N | Y |
| AAD-IN-04 | Text input | `City`; validation `City is required` | Words capitalization; required field validation (`add_address_screen.dart:260-273`; `auth_validators.dart:48-51`) | Always | N | Y |
| AAD-IN-05 | Text input | `State`; validation `State is required` | Words capitalization; required field validation (`add_address_screen.dart:274-289`; `auth_validators.dart:48-51`) | Always | N | Y |
| AAD-IN-06 | Text input | `House / Flat / Building No.`; validation `House / Flat / Building No. is required` | Words capitalization; required field. Current-location action moves focus here (`add_address_screen.dart:290-301,122-125`; `auth_validators.dart:48-51`) | Always | N | Y |
| AAD-IN-07 | Text input | `Area / Street / Landmark`; validation `Area / Street is required` | Sentence capitalization; Done action; required validation uses shorter label `Area / Street` (`add_address_screen.dart:302-317`; `auth_validators.dart:48-51`) | Always | N | Y |
| AAD-TXT-05 | Section heading | Rendered `PIN LOCATION`; trailing `Optional` | Screen passes `Pin Location`; section widget uppercases title and displays optional trailing label (`add_address_screen.dart:319-331`; section widget `add_address_screen.dart:597-641`) | Map preview enabled (true on route) | N | Y |
| AAD-MAP-01 | Interactive map preview | `Drag the map to place the pin on your exact location`; center pin has no text | Map drag updates saved pin center; map pans beneath fixed center marker (`add_address_screen.dart:323-331,802-897`) | `showMapPreview` true | Y — keep map gesture and fixed marker relationship | Y |
| AAD-TXT-06 | Section heading | Rendered `SAVE ADDRESS AS` | Screen passes `Save Address As`; section widget uppercases title (`add_address_screen.dart:333-337,597-641`) | Always | N | Y |
| AAD-SEL-01 | Address type choice | `Home`; `Office`; `Other` | Sets `_type`; selected chip has selected semantics/state (`add_address_screen.dart:336-344,899-986`; `address_models.dart:5-13`) | Always; exactly one selected | Y — values map to `AddressType` | Y |
| AAD-IN-08 | Conditional text input | `Label (e.g. Site 2, Warehouse)` | Captures custom label for `AddressType.other`; optional, words capitalization, Done action (`add_address_screen.dart:345-355`) | Address type is Other | N | Y |
| AAD-TGL-01 | Toggle | `Make this my default address`; `Used first at every checkout` | Row tap and Switch toggle `_isDefault`; initially false (`add_address_screen.dart:356-359,990-1039`) | Always | N | Y |
| AAD-ACT-02 | Bottom action button | `Save & Deliver Here`; loading spinner while saving | Unfocuses keyboard; validates form; enables autovalidation after invalid attempt; on valid form waits 600 ms then returns new address. Disabled during save (`add_address_screen.dart:127-154,369-376,1041-1118`) | Always; disabled while saving | N | Y |
| AAD-MSG-01 | Snackbar | `Location found. Add your house/flat number.` | Shown after simulated current-location action (`add_address_screen.dart:98-125`) | Current-location action completes | N | Y |

## States and messages

- Pincode length below six: idle suffix; helper `City & State fill in automatically`.
- Pincode lookup: spinner suffix; helper remains `City & State fill in automatically`.
- Pincode found in local directory: success check suffix; helper `Delivery available · City & State filled`; city/state filled from directory.
- Pincode not found: warning/info suffix; helper `Couldn't find this pincode — enter City & State`; manual city/state fields remain editable (`add_address_screen.dart:76-96,244-259,766-798`).
- Current-location action: button copy changes to `Detecting location…` and shows spinner; after 1100 ms it sets fixed location values, shows `Location found. Add your house/flat number.`, then focuses house field (`add_address_screen.dart:98-125,493-566`).
- Invalid save displays validators’ exact error text; form switches to on-user-interaction autovalidation (`add_address_screen.dart:127-133`; `auth_validators.dart:31-51`).
- Valid save disables bottom button and shows spinner while waiting 600 ms, then pops with `DeliveryAddress` (`add_address_screen.dart:127-154,1041-1118`).
- No network save/error state, confirmation, upload, or passcode popup is defined.

## Displayed values

- Required field validators use trimmed emptiness; full name also requires two or more characters. Mobile strips whitespace/non-digits and optional `+91`, then requires ten digits beginning 6-9 (`auth_validators.dart:31-51`).
- Pincode requires exactly six digits with first digit 1-9 (`add_address_screen.dart:156-164`); lookup uses local map entries only and waits 450 ms (`address_models.dart:50-78`).
- Current-location simulation sets pin to 12.9166, 77.6101; area `Bannerghatta Road, BTM Layout`; pincode `560076`; city `Bangalore`; state `Karnataka` (`add_address_screen.dart:33-36,98-125`).
- Initial map center is 12.9716, 77.5946; map zoom 15 initially and 16 after simulated location action (`add_address_screen.dart:31-36,833-847,116-118`).
- Saved form values are trimmed. Custom label is stored only for Other; location is stored only if map preview enabled (`add_address_screen.dart:127-154`).

## Style with meaning

- Pincode found uses success color/check and success helper copy; not-found uses warning color/info icon/helper copy; loading uses spinner (`add_address_screen.dart:244-259,766-798`).
- Selected address-type chip differs from unselected, including border, background, and icon/text color (`add_address_screen.dart:919-986`).
- Current-location button uses spinner and disabled tap state while locating; save button uses spinner and disabled state while saving (`add_address_screen.dart:493-566,1041-1118`).
- Validation errors and helper state distinguish invalid data from pincode lookup state; preserve them as separate feedback.

## Keyboard and focus

- Name, city, state, house, and custom label capitalize words; area capitalizes sentences. Mobile/pincode use numeric/phone keyboards and digit/length formatters (`add_address_screen.dart:204-317`).
- Text fields default to Next; area uses Done. Save unfocuses input before validation; scrolling dismisses keyboard on drag (`add_address_screen.dart:127-130,178-190,302-317,725-765`).
- Current-location action requests focus on house field after completing (`add_address_screen.dart:122-125`).
- No autofocus or Escape handler is defined. No explicit field submission chain beyond standard `TextInputAction`.

## Responsive

- Form scrolls vertically and uses a maximum content width of 720 logical pixels (`add_address_screen.dart:28,173-190,375-385`).
- City and State share a row; map preview is fixed at 170 logical pixels high (`add_address_screen.dart:260-289,836-879`).
- Save bar is fixed at the bottom and constrained to the same 720-pixel maximum width (`add_address_screen.dart:369-376,1041-1118`).
- Map preview is conditional through `showMapPreview`; current route uses true. No breakpoint is defined.

## Risk notes

- `_formKey`, individual text controllers, and `_houseFocus` must stay associated with their fields; validation and current-location focus rely on them (`add_address_screen.dart:39-49,127-154,290-301`).
- Pincode lookup is asynchronous; stale result guard compares current text to queried value. Keep that guard and avoid applying older city/state results (`add_address_screen.dart:76-96`).
- Map marker remains fixed while map pans; `onPositionChanged` updates pin only when `hasGesture` is true (`add_address_screen.dart:836-897`).
- “Use my current location” is currently hard-coded simulated data, not actual GPS. Do not replace its behavior as a styling-only change (`add_address_screen.dart:33-36,98-125`).
- Save returns to Select Address by popping a `DeliveryAddress`; the parent screen relies on that return type and default-address flag (`add_address_screen.dart:127-154`; `select_address_screen.dart:38-59`).
