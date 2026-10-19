# SCR-03 — Create account

- Route: `/create-account` (`AppRoutes.createAccount`)
- Source: [create_account_screen.dart](../lib/features/auth/presentation/screens/create_account_screen.dart) — 141 lines; [login_flow_widgets.dart](../lib/features/auth/presentation/widgets/login_flow_widgets.dart)
- Purpose: Collect full name, email, and optional referral code for the OTP registration flow, then pass them to location selection.

## Data

- No API request is made by this screen. It only reads its `SignupFlowArgs` and forwards values (`create_account_screen.dart:31-49`).
- `Continue`: if `args.mobileNumber` is null or empty, pop the current route. Otherwise, navigate to `/choose-location` with `SignupFlowArgs`: original mobile; trimmed full name; trimmed email; trimmed referral code or `null` if empty (`create_account_screen.dart:31-48`).
- Router allows `args` to be absent (`lib/core/routes/app_router.dart:43-45`); in that case pressing Continue takes the pop branch. Signup arguments are declared in `lib/core/routes/app_routes.dart:69-91`.

## Elements

| ID | Type | Exact visible text | What it does (handler → effect, source) | Shown/enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| CAC-BTN-01 | Back icon button | No visible text (arrow-back icon) | `Navigator.maybePop()` (`create_account_screen.dart:77-79`; `login_flow_widgets.dart:603-621`) | Always | N | Y |
| CAC-VIS-01 | Icon badge | No visible text (person-outline icon) | Decorative `LoginFlowIconBadge` (`create_account_screen.dart:81-86`) | Always | N | Y |
| CAC-TXT-01 | Heading | `Create Your Account` | Static heading (`create_account_screen.dart:88-94`) | Always | N | Y |
| CAC-TXT-02 | Supporting text | `Just a couple of details to get you started` | Static subtitle (`create_account_screen.dart:96-102`) | Always | N | Y |
| CAC-IN-01 | Text input | Label `Full Name`; placeholder `Enter your full name` | Writes `_nameController`; `TextCapitalization.words`; no validator is supplied (`create_account_screen.dart:19,104-110`; `login_flow_widgets.dart:340-430`) | Always | Y — value is forwarded when Continue is pressed | Y |
| CAC-IN-02 | Text input | Label `Email Address`; placeholder `Enter your email address` | Writes `_emailController`; email keyboard; no validator is supplied (`create_account_screen.dart:20,112-118`; `login_flow_widgets.dart:340-430`) | Always | Y — value is forwarded when Continue is pressed | Y |
| CAC-IN-03 | Text input | Label `Referral Code (Optional)`; placeholder `Enter referral code, if you have one` | Writes `_referralController`; character capitalization; trimmed value forwarded or `null` (`create_account_screen.dart:21,120-126,38-46`; `login_flow_widgets.dart:340-430`) | Always | Y — value is forwarded when Continue is pressed | Y |
| CAC-BTN-02 | Primary button | `Continue` | `_continue` → pop if mobile argument absent/empty; otherwise navigate to `/choose-location` with the three field values and mobile (`create_account_screen.dart:31-49,128-131`) | Always enabled; no loading or validation gate | Y — submits entered values | Y |
| CAC-TXT-03 | Footer text | `By continuing, you agree to our ` | Static prefix (`login_flow_widgets.dart:93-107`) | Always | N | Y |
| CAC-LINK-01 | Inline link | `Terms of Services & Privacy Policy` | Tap recognizer has an empty callback; no action or navigation (`login_flow_widgets.dart:108-116`) | Always | N | Y |

## States and messages

- Initial state: three empty text controllers; no loading or error state (`create_account_screen.dart:18-21`).
- The full-name/email/referral `TextFormField`s are not supplied validators and are not inside a `Form` in this screen; no validation message is displayed (`create_account_screen.dart:74-134`; field implementation `login_flow_widgets.dart:340-430`).
- Continue with absent/empty mobile argument pops without a message (`create_account_screen.dart:31-36`).
- Continue with a non-empty mobile argument navigates without a success message (`create_account_screen.dart:38-48`).
- Other loading, empty, error, confirmation, or success messages: none defined in this screen.

## Displayed values

- Full name and email forwarded after `.trim()` (`create_account_screen.dart:44-45`).
- Referral code forwarded after `.trim()`, but becomes `null` when the trimmed string is empty (`create_account_screen.dart:38,46`).
- Mobile is passed through from the route arguments unchanged (`create_account_screen.dart:32,43`).

## Style with meaning

- Text fields visually distinguish focused border (`LoginFlowOutlinedField`, `login_flow_widgets.dart:340-430`). No validation/error state is configured for these fields on this screen.
- Continue is the active gradient button; this screen does not pass a disabled or loading state (`create_account_screen.dart:128-131`; `login_flow_widgets.dart:26-89`).
- No business status/selected-state colour is defined here.

## Keyboard and focus

- Full Name uses word capitalization; Email Address uses `TextInputType.emailAddress`; Referral Code uses character capitalization (`create_account_screen.dart:104-125`).
- Shared outlined fields use `TextInputAction.done` by default (`login_flow_widgets.dart:340-360`). No explicit autofocus, submit-on-Enter callback, or custom focus traversal order is set.
- Dragging the scroll view dismisses the keyboard (`create_account_screen.dart:66-68`).
- No explicit Escape behavior. Back icon is an `InkWell`; controls otherwise use Flutter defaults for pressed/focus feedback.

## Responsive

- `SafeArea` + `SingleChildScrollView` with on-drag keyboard dismissal (`create_account_screen.dart:65-73`).
- Stretched column content; no breakpoint or size-dependent branch is defined (`create_account_screen.dart:74-76`).

## Risk notes

- Preserve the argument guard: without a non-empty mobile number, Continue pops instead of opening location selection (`create_account_screen.dart:31-36`).
- Preserve controller-to-argument mapping, trimming, and optional-referral null conversion (`create_account_screen.dart:19-21,38-47`).
- The terms/privacy link currently does nothing; adding navigation changes behavior.
- No field validation currently blocks Continue; adding it changes behavior.
