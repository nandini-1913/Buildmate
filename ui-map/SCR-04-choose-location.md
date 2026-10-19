# SCR-04 — Choose location

- Route: `/choose-location` (`AppRoutes.chooseLocation`)
- Source: [choose_location_screen.dart](../lib/features/auth/presentation/screens/choose_location_screen.dart) — 715 lines; [location_controller.dart](../lib/core/state/location_controller.dart) — location state and geocoding
- Purpose: Select a delivery/site location using current GPS, map movement, or a searched address; continue signup or return from a location update.

## Data

- Screen open: `initState` checks the shared `LocationController.hasFix`; when true it centers the map at `currentCenter`, otherwise `_useCurrentLocation()` calls `fetchCurrentLocation()` (`choose_location_screen.dart:49-63`).
- GPS uses `Geolocator.isLocationServiceEnabled`, `checkPermission`/`requestPermission`, `getCurrentPosition` with high accuracy and a 20-second limit, then `getLastKnownPosition` on failure (`location_controller.dart:34-99`). Opening location settings/app settings is also possible (`location_controller.dart:41-64`).
- Map requests tiles from `https://tile.openstreetmap.org/{z}/{x}/{y}.png` (`choose_location_screen.dart:208-209`).
- Reverse geocoding uses `placemarkFromCoordinates(latitude, longitude)` after successful GPS or a map move (`location_controller.dart:103-112`; `choose_location_screen.dart:115-119`).
- Search calls `locationFromAddress(trimmedQuery)`; the first match is applied to the shared location controller and the map is moved to it (`choose_location_screen.dart:121-149`; `location_controller.dart:167-187`). These are plugin/provider calls; no app API method/path is defined here.
- Search control action sends its current query to `_searchPlace`; no request is sent for an empty trimmed query (`choose_location_screen.dart:398-398`; `choose_location_screen.dart:121-126`).
- `Confirm & continue`: in location-update mode, pop to the previous route; otherwise navigate to `/choose-profession` and pass the existing `SignupFlowArgs` (`choose_location_screen.dart:162-171`). The selected coordinates/address remain in shared `LocationController`; no location payload is sent in the route arguments.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| LOC-MAP-01 | Interactive map | No visible text | `FlutterMap` loads OpenStreetMap tiles; supports all map gestures except rotate; `MapEventMoveEnd` → reverse-geocode new center (`choose_location_screen.dart:189-212`) | Always | Y — map center determines the selected location | Y |
| LOC-BTN-01 | Back icon button | No visible text (arrow-back icon) | `Navigator.maybePop()` (`choose_location_screen.dart:218-229`) | Always | N | Y |
| LOC-VIS-01 | Map pin | No visible text (home icon) | Fixed center overlay; map pans beneath it; decorative (`choose_location_screen.dart:233-268,466-518`) | Always | Y — identifies the map center used as the pinned point | Y |
| LOC-BTN-02 | Current-location icon button | No visible text (my-location icon); no tooltip/semantic label is defined | `_useCurrentLocation()` → GPS lookup; icon is replaced by spinner during lookup (`choose_location_screen.dart:269-276,521-560`) | Always; repeated tap ignored while `_locating` | N | Y |
| LOC-TXT-01 | Heading | `Pin your location` | Static screen heading (`choose_location_screen.dart:312-317`) | Always | N | Y |
| LOC-TXT-02 | Instruction | `Drag the map or search to place the pin exactly where you'd like deliveries and site visits.` | Static instructions (`choose_location_screen.dart:319-327`) | Always | N | Y |
| LOC-IN-01 | Search input | Placeholder `Search area, street or landmark` | Search keyboard submission or tapping search icon → `_searchPlace(query)` (`choose_location_screen.dart:380-460`) | Always | Y — query is used to set the location before confirmation | Y |
| LOC-BTN-03 | Search icon button | No visible text (search icon); no tooltip/semantic label is defined | Calls `_submit()` with current search field text (`choose_location_screen.dart:415-421`) | Always | Y — uses current input value | Y |
| LOC-BTN-04 | Clear icon button | No visible text (close icon); no tooltip/semantic label is defined | Clears search input and rebuilds (`choose_location_screen.dart:449-455`) | Only when search input is non-empty | N | Y |
| LOC-CARD-01 | Located state / address | `Current location`; dynamic address line 1 and line 2; check-circle icon | Displays the shared controller address after `_located` becomes true (`choose_location_screen.dart:563-635`; values from `location_controller.dart:20-23,103-155`) | When `_located` is true | Y — address must correspond to current map center | Y |
| LOC-CARD-02 | Current-location action | `Use my current location` / `Finding your location…`; `Or drag the pin to fine-tune it manually` | Row tap calls `_useCurrentLocation`; label and icon change while locating (`choose_location_screen.dart:636-695`) | When `_located` is false | Y — successful lookup sets the value that confirmation uses | Y |
| LOC-BTN-05 | Retry snackbar action | `Retry` | Calls `_useCurrentLocation()` (`choose_location_screen.dart:102-110`) | Only on current-location lookup failure | N | Y |
| LOC-BTN-06 | Confirm button | `Confirm & continue` | `_continue()` → pop if `isLocationUpdate`, else navigate to choose-profession with signup args (`choose_location_screen.dart:162-171,706-711`) | Always shown; enabled only when `_located` is true (`choose_location_screen.dart:706-711`; `login_flow_widgets.dart:26-89`) | Y — depends on a successful pin selection | Y |
| LOC-STATE-01 | Loading indicators | No visible text | Pin bounces and current-location controls show spinners while `_locating`; map request pending state itself has no dedicated message (`choose_location_screen.dart:233-257,269-276,636-695`) | During GPS or place search | N | Y |

## States and messages

- Initial: `_located` and `_locating` are false; after first frame the existing fix is reused or current-location lookup begins (`choose_location_screen.dart:40-70`). The map starts at `LocationController.currentCenter` and zoom 15 (`choose_location_screen.dart:189-197`).
- Locating: `_locating` true; pin animates; location action text is `Finding your location…`; confirm remains disabled until `_located` is true (`choose_location_screen.dart:72-98,233-257,636-695`).
- Current-location failure: floating snackbar shows controller error or fallback `Unable to get current location`, with `Retry` action (`choose_location_screen.dart:100-111`). Controller messages:
  - `Turn on location services to continue` — device location stays off after opening settings (`location_controller.dart:41-48`).
  - `Location permission denied — tap to retry` — permission remains denied (`location_controller.dart:51-58`).
  - `Location permission blocked — enable it in Settings` — permission permanently denied; app settings opened (`location_controller.dart:60-64`).
  - `Unable to get current location — try again` — no position or fetch exception (`location_controller.dart:79-93`).
- Search failure: floating snackbar shows controller error or `No places found for “$q”` (`choose_location_screen.dart:150-158`). Controller exact messages are `No places found for “$q”` when no match and `Unable to find that place — try a nearby landmark` on geocoding exception (`location_controller.dart:167-185`).
- Empty search query: no request and no message (`choose_location_screen.dart:121-126`).
- Successful location/search/map reverse-geocode: `_located` becomes true and address card replaces the unlocated prompt; no success toast/message (`choose_location_screen.dart:90-98,115-119,138-148`).
- Controller defaults `Detecting current location…` and `Please wait` (`location_controller.dart:14-15`); this screen does not render those values while `_located` is false because it displays the unlocated prompt instead (`choose_location_screen.dart:636-695`).
- Other validation, confirmation, or success dialogs: none defined.

## Displayed values

- Map center: `LocationController.currentCenter`; initial default is latitude `28.5710`, longitude `77.3260`; initial zoom 15; GPS/search results move to zoom 16 (`location_controller.dart:12-13`; `choose_location_screen.dart:189-197,89-92,139-142`).
- Address line 1: first non-empty unique street/name string, plus sublocality/locality if different, comma-separated; fallback `Pinned location` if no line 1 parts (`location_controller.dart:116-134`).
- Address line 2: locality/city where different from locality, administrative area, and postcode when present, comma-separated; fallback `GPS current location` (`location_controller.dart:136-152`).
- If reverse geocoding yields no placemarks or throws, line 1 is `Lat ${latitude.toStringAsFixed(5)}, Lng ${longitude.toStringAsFixed(5)}` and line 2 is `GPS current location` (`location_controller.dart:143-152`).
- Current-location error fallback in screen: `Unable to get current location`; search fallback interpolates query as `No places found for “$q”` (`choose_location_screen.dart:100-101,153-155`).

## Style with meaning

- `_located` distinguishes verified location (address and check icon) from unlocated prompt; confirm is enabled only in located state (`choose_location_screen.dart:563-711`).
- `_locating` uses spinner, animated pin bounce, and changed prompt text (`choose_location_screen.dart:72-98,233-257,636-695`).
- Error information is conveyed by snackbar; keep errors distinguishable from ordinary address text (`choose_location_screen.dart:100-111,150-158`).
- Palette/shadows may change, but located/unlocated/loading/error must remain distinguishable.

## Keyboard and focus

- Search field uses `TextInputAction.search`; both keyboard submission and tapping the search icon submit the current input (`choose_location_screen.dart:398-398,415-460`).
- No autofocus or explicit Escape handler is defined. Clear icon is conditional on non-empty text (`choose_location_screen.dart:449-455`).
- Map gestures are enabled except rotate (`choose_location_screen.dart:194-198`); no custom keyboard focus order or hover behavior is defined.

## Responsive

- Map and lower panel divide available height using `Expanded`; bottom panel max height is 52% of screen height and internally scrolls (`choose_location_screen.dart:185-188,280-345`).
- Map/back button and location control use `SafeArea`/positioned placement; panel uses bottom safe area (`choose_location_screen.dart:217-231,269-276,333-345`).
- No explicit breakpoint or alternate layout is defined.

## Risk notes

- Keep the map behind a fixed centered pin; `MapEventMoveEnd` determines the selected center (`choose_location_screen.dart:189-212,233-268`).
- Preserve the relationship between `_located`, current-location/search/map results, address card state, and confirm enabled state (`choose_location_screen.dart:72-171,563-711`).
- Keep the location-update route branch (pop) distinct from signup (choose profession with the same `SignupFlowArgs`) (`choose_location_screen.dart:162-171`).
- Map uses `MapController`, address search and location controls use shared `LocationController`; rearranging/replacing widgets must preserve their callbacks and state (`choose_location_screen.dart:40-48,72-171,189-212`).
