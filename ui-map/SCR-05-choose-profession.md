# SCR-05 — Choose profession

- Route: `/choose-profession` (`AppRoutes.chooseProfession`)
- Source: [choose_profession_screen.dart](../lib/features/auth/presentation/screens/choose_profession_screen.dart) — 268 lines; [auth_models.dart](../lib/features/auth/domain/models/auth_models.dart); [session_controller.dart](../lib/core/state/session_controller.dart)
- Purpose: Select one of five profession options, persist a local session profile, and enter the main shell.

## Data

- Screen open: no API request or loading operation is initiated by this screen. It receives `SignupFlowArgs` from the route (`choose_profession_screen.dart:12-19`; router at `lib/core/routes/app_router.dart:57-64`).
- Selecting a profession changes `_selectedIndex` only (`choose_profession_screen.dart:149-151`).
- `Continue`: maps selected option to `UserRole`, builds `AuthUser` from route mobile/email/name/referral code, calls `SessionController.setFromAuth()` (which persists the profile using `SessionStorage.save()`), then replaces the navigation stack with `/home-placeholder` (`choose_profession_screen.dart:71-95`; `lib/core/state/session_controller.dart:35-49`).
- No app API method/path is called.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| PRF-BTN-01 | Back icon button | No visible text (arrow-back icon) | `Navigator.maybePop()` (`choose_profession_screen.dart:112-116`; `login_flow_widgets.dart:603-621`) | Always | N | Y |
| PRF-TXT-01 | Heading | `Choose your profession` | Static heading (`choose_profession_screen.dart:120-125`) | Always | N | Y |
| PRF-TXT-02 | Instruction | `Pick what best describes you so we can personalize your experience.` | Static supporting text (`choose_profession_screen.dart:128-134`) | Always | N | Y |
| PRF-OPT-01 | Selectable card | `Contractor` — `Building & construction`; image `assets/images/professions/contractor.png` | Card tap sets selected option index; maps to `UserRole.contractor` (`choose_profession_screen.dart:36-42,149-151,203-217`) | Always; selected when its index matches `_selectedIndex` | Y — card/index maps to role | Y |
| PRF-OPT-02 | Selectable card | `Plumber` — `Pipes, bathrooms & Fittings`; image `assets/images/professions/plumber.png` | Card tap sets selected option index; maps to `UserRole.dealer` (`choose_profession_screen.dart:43-48,149-151,203-217`) | Always; selected when its index matches `_selectedIndex` | Y — card/index maps to role | Y |
| PRF-OPT-03 | Selectable card | `Electrician` — `Wiring, switches & lighting`; image `assets/images/professions/electrician.png` | Card tap sets selected option index; maps to `UserRole.builder` (`choose_profession_screen.dart:49-54,149-151,203-217`) | Always; selected when its index matches `_selectedIndex` | Y — card/index maps to role | Y |
| PRF-OPT-04 | Selectable card | `Flooring` — `Tiles & Adhesives`; image `assets/images/professions/flooring.png` | Card tap sets selected option index; maps to `UserRole.dealer` (`choose_profession_screen.dart:55-60,149-151,203-217`) | Always; selected when its index matches `_selectedIndex` | Y — card/index maps to role | Y |
| PRF-OPT-05 | Selectable card | `Home Owner` — `Buying for my own house`; image `assets/images/professions/home_owner.png` | Card tap sets selected option index; maps to `UserRole.individualCustomer` (`choose_profession_screen.dart:61-66,149-151,203-217`) | Always; selected when its index matches `_selectedIndex` | Y — card/index maps to role | Y |
| PRF-STATE-01 | Selection indicator | No visible text (circle; selected state adds check icon) | Shows selected/unselected state for each card (`choose_profession_screen.dart:203-227,242-267`) | One selected card after a card tap; initially none selected | Y — must correspond to the card currently selected | Y |
| PRF-BTN-02 | Primary button | `Continue` | `_continue` → persist selected user profile locally, then clear stack and navigate to `/home-placeholder` (`choose_profession_screen.dart:71-95,229-233`) | Always shown; disabled until a card is selected (`choose_profession_screen.dart:229-233`) | Y — submits the selected card's mapped role | Y |

## States and messages

- Initial: `_selectedIndex == null`; no card selected and Continue disabled (`choose_profession_screen.dart:68,229-233`).
- Selected: tapping a card sets its index; selected card styling/check indicator updates and Continue is enabled (`choose_profession_screen.dart:149-151,203-233,242-267`).
- Continue when no selection: `_continue` returns immediately; normally the button is disabled (`choose_profession_screen.dart:71-73`).
- Continue after selection: saves the profile and navigates; no success message is shown (`choose_profession_screen.dart:74-95`).
- Error, validation, confirmation, or loading messages: none defined. The async save has no in-screen loading/error state.

## Displayed values

- Fixed profession card order is Contractor, Plumber, Electrician, Flooring, Home Owner (`choose_profession_screen.dart:36-66`).
- Role mapping is `Contractor` → contractor, `Plumber` → dealer, `Electrician` → builder, `Flooring` → dealer, `Home Owner` → individualCustomer (`choose_profession_screen.dart:36-66`).
- Submitted ID is `'user-mobile-' + args.mobileNumber`; email, full name, mobile number, selected role, and referral code are copied from `SignupFlowArgs` (`choose_profession_screen.dart:75-85`).
- These profile values are not rendered on this screen.

## Style with meaning

- Selected/unselected cards differ by background, border, and circular selection indicator/check (`choose_profession_screen.dart:149-227,242-267`).
- Continue enabled/disabled state indicates whether a profession is selected (`choose_profession_screen.dart:229-233`; `login_flow_widgets.dart:26-89`).
- Image load failure substitutes a neutral image icon (`choose_profession_screen.dart:177-190`).
- Palette may change, but selected/unselected and enabled/disabled states must remain distinguishable.

## Keyboard and focus

- No text input or keyboard handler exists.
- No explicit autofocus, Escape handler, or custom focus traversal order is defined.
- Back button and selectable cards use Flutter Material/InkWell interactions; no custom hover behavior is defined.

## Responsive

- Screen is in `SafeArea` with fixed insets; header and Continue are outside an `Expanded` separated card `ListView`, which scrolls when necessary (`choose_profession_screen.dart:99-148,136-147,229-233`).
- No explicit breakpoint or alternate layout is defined.

## Risk notes

- Preserve each card's associated `UserRole`; several labels intentionally map to shared/different roles (Plumber/Flooring → dealer; Electrician → builder) (`choose_profession_screen.dart:36-66`).
- The selected index indexes `_options`; if changing how cards are arranged, keep each visible option callback bound to its original `_ProfessionOption` and role (`choose_profession_screen.dart:68,149-151,203-217`).
- Continue creates the session profile locally and replaces the full navigation stack; it does not register an account through an API (`choose_profession_screen.dart:74-95`).
