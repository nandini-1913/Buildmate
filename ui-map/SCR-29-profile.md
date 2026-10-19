# SCR-29 — Profile

- **Route:** `/profile`; the same body is also the Profile tab in the main shell.
- **Files:** `lib/features/profile/presentation/screens/profile_tab_body.dart` (541 lines); `lib/features/profile/presentation/widgets/profile_widgets.dart` (480); `lib/features/profile/presentation/widgets/profile_edit_sheets.dart` (404); `lib/features/profile/presentation/widgets/profile_document_preview.dart` (100); `lib/features/profile/presentation/widgets/upload/document_picker.dart` (52); `lib/features/profile/domain/models/profile_models.dart` (193); `lib/features/profile/data/in_memory_profile_repository.dart` (56); `lib/core/state/profile_controller.dart` (111); `lib/core/state/reward_controller.dart` (71).
- **Purpose:** View and edit customer profile and KYC details, inspect supporting documents, open rewards, manage referral-code clipboard actions, or sign out.
- **Line-count convention:** physical source lines, counted from the files listed above. The route and shell use are evidenced at `lib/core/routes/app_routes.dart:39`, `lib/core/routes/app_router.dart:207-213`, and `lib/features/shell/presentation/main_shell.dart:169`.

## Data

- On first frame, reads the current `SessionController.user`, then concurrently calls `RewardController.refreshForUser(user.id)` and `ProfileController.loadForUser(user)` (`profile_tab_body.dart:35-50`). There is no profile-screen API request. Profile details come from `InMemoryProfileRepository.fetch`, keyed by user ID (`profile_controller.dart:20-29`; `in_memory_profile_repository.dart:6-17`).
- The profile repository seeds demo values for an unseen user: current user's name, phone and email; fixed demo address; PAN `ABCDE1234F` with approved state; GST `09ABCDE1234F1Z5` with pending state; bank account `XXXXXXXX1234` with approved state; and supporting document names/dates (`in_memory_profile_repository.dart:20-55`). These values may change after local edits and are not loaded from a server.
- Rewards refresh obtains the current user's balance and ledger through the configured reward repository; app wiring injects `InMemoryRewardRepository.withDemoSeed()` (`reward_controller.dart:11-29`; `main.dart:67-71`; `in_memory_reward_repository.dart:118-141`). No API call is made.
- Personal save updates the local profile, then calls `SessionController.setUser` with the edited name/email and existing ID, phone, business name, and guest flag (`profile_tab_body.dart:60-79`).
- PAN/GST/bank saves update the in-memory profile. PAN and GST values are trimmed and uppercased; bank account is masked before storage, IFSC uppercased, and the saved KYC status becomes pending (`profile_controller.dart:39-96`).
- Opening My Rewards navigates to `AppRoutes.myRewards` (`profile_tab_body.dart:292-299`). No data payload is sent by this action.
- Copy referral writes only the referral code to the system clipboard. Share writes `Join Buildmate with my referral code: <code> and earn rewards!` to the clipboard; neither opens a native share sheet (`profile_tab_body.dart:399-423`).
- Sign out clears profile, cart, wishlist and recently viewed controllers; logs out the session; then replaces the root navigation stack with `AppRoutes.login` (`profile_tab_body.dart:118-130`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect; evidence) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| PRF-HDR-01 | Header | `My Profile` | Static title in `ProfileHeader` (`profile_widgets.dart:76-78`). | Always. | N | Y |
| PRF-HDR-02 | Subtitle | `Manage your personal and business details` | Static header subtitle (`profile_widgets.dart:82-86`). | Always. | N | Y |
| PRF-BTN-01 | Icon button | `Back` (tooltip; back-arrow icon) | `ProfileHeader` → `Navigator.maybePop()` (`profile_widgets.dart:47-54`). | Only standalone `/profile` route sets `showBackButton: true`; hidden in shell tab (`profile_tab_body.dart:26-29`; `app_router.dart:207-213`). | N | Y |
| PRF-BTN-02 | Avatar icon button | Camera icon; no text | Tap → snackbar `Profile photo upload is coming soon`; no upload occurs (`profile_tab_body.dart:158-161`). | Always. | N | Y |
| PRF-TXT-01 | Avatar value | Dynamic initials; fallback `?` | `AppUserProfile.initials`: trimmed whitespace-separated name; empty gives `?`; one word uses first two characters (or its sole character), multiple words use first characters of first and last words; uppercase (`catalog_models.dart:25-37`). | Always. | N | Y |
| PRF-STATE-01 | Loading indicator | No text | Circular progress indicator while `ProfileController.details == null`; there is no dedicated error view (`profile_tab_body.dart:170-175`). | Before profile load resolves, or after profile controller is cleared until reloaded. | N | Y |
| PRF-BNR-01 | Conditional informational banner | `Some details are pending for approval. Once approved by the backend team, they cannot be changed.` | Display-only `ProfileApprovalBanner` (`profile_tab_body.dart:178-181`; `profile_widgets.dart:161-187`). | At least one PAN/GST/bank status is pending (`profile_models.dart:122-124`); demo seed has pending GST. | N | Y |
| PRF-CARD-01 | Tappable section card | `Personal Information` | Tap → `showPersonalInfoEditSheet`; valid save persists locally and synchronizes session name/email (`profile_tab_body.dart:183-205`; edit definition `profile_edit_sheets.dart:16-40`). | Profile details loaded. | N | Y |
| PRF-VAL-01 | Display row | `Full Name` + user value; empty value displays `—` | Reads `details.personal.fullName`; empty-value fallback is in `ProfileInfoRow` (`profile_tab_body.dart:187-190`; `profile_widgets.dart:276-324`). | Loaded profile. | N | Y |
| PRF-VAL-02 | Display row and status chip | `Mobile Number` + phone value + `Not Editable` | Reads `details.personal.mobileNumber`; informational lock chip; mobile value cannot be edited in the personal form (`profile_tab_body.dart:191-196`; `profile_widgets.dart:450-480`; `profile_edit_sheets.dart:26-27`). | Loaded profile. | N | Y |
| PRF-VAL-03 | Display row | `Email Address` + email value; empty value displays `—` | Reads `details.personal.email`; editable in personal form (`profile_tab_body.dart:197-200`; `profile_edit_sheets.dart:28-30`). | Loaded profile. | N | Y |
| PRF-VAL-04 | Display row | `Address` + address value; empty value displays `—` | Reads `details.personal.address`; editable in personal form (`profile_tab_body.dart:201-204`; `profile_edit_sheets.dart:31-33`). | Loaded profile. | N | Y |
| PRF-CARD-02 | Tappable KYC card | `PAN Details` + status badge | Tap → if approved, snackbar `PAN details are approved and can no longer be changed.`; otherwise opens PAN edit sheet (`profile_tab_body.dart:57-58,207-228`). | Profile details loaded. Card/status state determines action. | N | Y |
| PRF-VAL-05 | Display row | `PAN Number` + PAN value | Reads `details.pan.panNumber` (`profile_tab_body.dart:212-216`). | Loaded profile. | N | Y |
| PRF-VAL-06 | Display row | `Name on Document` + value | Reads PAN document name (`profile_tab_body.dart:217-220`). | Loaded profile. | N | Y |
| PRF-DOC-01 | Document row | `Supporting Document`; filename; `Uploaded on <d MMM yyyy>`; `View document` tooltip | View → `showProfileDocument` for PAN document (`profile_tab_body.dart:221-227`; `profile_widgets.dart:327-405`). | Loaded profile. | N | Y |
| PRF-CARD-03 | Tappable KYC card | `GST Details` + status badge | Tap → if approved, snackbar `GST details are approved and can no longer be changed.`; otherwise opens GST edit sheet (`profile_tab_body.dart:230-251`; locked-message helper `:57-58`). | Profile details loaded. | N | Y |
| PRF-VAL-07 | Display row | `GST Number` + GST value | Reads `details.gst.gstNumber` (`profile_tab_body.dart:235-239`). | Loaded profile. | N | Y |
| PRF-VAL-08 | Display row | `Name on Document` + value | Reads GST document name (`profile_tab_body.dart:240-243`). | Loaded profile. | N | Y |
| PRF-DOC-02 | Document row | `Supporting Document`; filename; `Uploaded on <d MMM yyyy>`; `View document` tooltip | View → `showProfileDocument` for GST document (`profile_tab_body.dart:244-250`; `profile_widgets.dart:327-405`). | Loaded profile. | N | Y |
| PRF-CARD-04 | Tappable KYC card | `Bank Details` + status badge | Tap → if approved, snackbar `Bank details are approved and can no longer be changed.`; otherwise opens bank edit sheet (`profile_tab_body.dart:253-279`; locked-message helper `:57-58`). | Profile details loaded. | N | Y |
| PRF-VAL-09 | Display row | `Account Number` + stored masked value | Reads masked `details.bank.accountNumber` (`profile_tab_body.dart:258-262`; mask function `profile_models.dart:141-145`). | Loaded profile. | N | Y |
| PRF-VAL-10 | Display row | `IFSC Code` + value | Reads `details.bank.ifscCode` (`profile_tab_body.dart:263-266`). | Loaded profile. | N | Y |
| PRF-VAL-11 | Display row | `Name on Account` + value | Reads `details.bank.nameOnAccount` (`profile_tab_body.dart:267-270`). | Loaded profile. | N | Y |
| PRF-DOC-03 | Document row | `Supporting Document`; filename; `Uploaded on <d MMM yyyy>`; `View document` tooltip | View → `showProfileDocument` for bank document (`profile_tab_body.dart:271-278`; `profile_widgets.dart:327-405`). | Loaded profile. | N | Y |
| PRF-TXT-02 | Section heading | `Account` | Static heading (`profile_tab_body.dart:282-286`). | Loaded profile. | N | Y |
| PRF-CARD-05 | Tappable tile | `My Rewards`; dynamic `<balance> points` | Tap → `Navigator.pushNamed(AppRoutes.myRewards)` (`profile_tab_body.dart:289-300`). | Loaded profile. | N | Y |
| PRF-CARD-06 | Referral card | `Earn & Refer`; `Share code & earn rewards` | Card content; no parent tap handler (`profile_tab_body.dart:302-306`; `_EarnReferCard` `:427-482`). | Loaded profile. | N | Y |
| PRF-BTN-03 | Icon button | Share icon; no text | Tap → copies `Join Buildmate with my referral code: <code> and earn rewards!`; snackbar `Share message copied — paste it anywhere` (`profile_tab_body.dart:410-423,439-454`). | Referral card shown. | N | Y |
| PRF-VAL-12 | Referral value | Dynamic referral code | If `user.id` nonempty use it, otherwise name; remove non-ASCII alphanumeric characters and uppercase; first 8 chars if length ≥8; `NOVA7F3K` if empty; otherwise `NOVA` + sanitized value padded with `X` to 4 chars and truncated to 4 (`profile_tab_body.dart:133-141`). | Referral card shown. | N | Y |
| PRF-BTN-04 | Icon/text action | Copy icon + `Copy` | Tap → copies only referral code; snackbar `Referral code copied` (`profile_tab_body.dart:399-408,502-530`). | Referral card shown. | N | Y |
| PRF-BTN-05 | Button | `Sign out` | Tap → clears profile/cart/wishlist/recently viewed, logs out, then root `pushNamedAndRemoveUntil(AppRoutes.login, (_) => false)` (`profile_tab_body.dart:118-130,311-317`). | Profile loaded. | N | Y |
| PRF-SHEET-01 | Modal bottom sheet | Dynamic title: `Edit Personal Information`, `Edit PAN Details`, `Edit GST Details`, or `Edit Bank Details` | Opened by respective section card when editable. Scroll-controlled and safe-area-aware (`profile_edit_sheets.dart:16-139`). | Personal always; KYC only when status is not approved. | N | Y |
| PRF-BTN-06 | Icon button | `Close` tooltip (close icon) | Pop/dismiss edit sheet without saving (`profile_edit_sheets.dart:283-293`). | Edit sheet open. | N | Y |
| PRF-BNR-02 | Approval notice | `Changes will be sent to the backend team for approval. Approved details cannot be changed later.` | Display-only notice in KYC sheets (`profile_edit_sheets.dart:295-309`). | PAN/GST/bank edit sheets; not personal sheet. | N | Y |
| PRF-IN-01 | Text input | `Full Name *` | Required after trim; words capitalization; initial full name; included as value index 0 on save (`profile_edit_sheets.dart:23-25,368-388`; validator `profile_models.dart:155-157`). | Personal edit sheet. | Y — saved values are passed in field-list order. | ASK |
| PRF-IN-02 | Disabled text input | `Mobile Number` with helper `Mobile number cannot be changed` | Read-only and disabled; no save value is used (`profile_edit_sheets.dart:26-28,368-388`). | Personal edit sheet. | Y — field-list index 1 is deliberately omitted by its save callback. | ASK |
| PRF-IN-03 | Text input | `Email Address *` | Required valid email; email keyboard; trimmed on save (`profile_edit_sheets.dart:28-30`; validator `profile_models.dart:159-163`). | Personal edit sheet. | Y — saved value index 2. | ASK |
| PRF-IN-04 | Multiline text input | `Address *` | Required after trim; 3 lines; multiline keyboard; saved from index 3 (`profile_edit_sheets.dart:31-33,368-388`; validator `profile_models.dart:155-157`). | Personal edit sheet. | Y — saved value index 3. | ASK |
| PRF-IN-05 | Text input | `PAN Number *` | Required PAN regex; characters auto-uppercase; max 10; trimmed/uppercased in controller (`profile_edit_sheets.dart:52-55`; validator `profile_models.dart:165-171`; save `profile_controller.dart:39-55`). | PAN edit sheet. | Y — `onSave` consumes same-order list indexes. | ASK |
| PRF-IN-06 | Text input | `Name on Document *` | Required after trim (`profile_edit_sheets.dart:56-59`; required validator `profile_models.dart:155-157`). | PAN edit sheet. | Y — second PAN value. | ASK |
| PRF-IN-07 | Text input | `GST Number *` | Required GST regex; characters auto-uppercase; max 15; trimmed/uppercased in controller (`profile_edit_sheets.dart:78-81`; validator `profile_models.dart:173-178`; save `profile_controller.dart:60-76`). | GST edit sheet. | Y — `onSave` consumes same-order list indexes. | ASK |
| PRF-IN-08 | Text input | `Name on Document *` | Required after trim (`profile_edit_sheets.dart:82-85`; required validator `profile_models.dart:155-157`). | GST edit sheet. | Y — second GST value. | ASK |
| PRF-IN-09 | Text input | `Account Number *`; existing masked number is hint | Starts blank; required 9–18 digits; number keyboard; digits-only formatter; max 18; controller masks before storage (`profile_edit_sheets.dart:105-110,368-388`; validator `profile_models.dart:187-191`; save `profile_controller.dart:81-96`). | Bank edit sheet. | Y — `onSave` consumes same-order list indexes. | ASK |
| PRF-IN-10 | Text input | `IFSC Code *` | Required IFSC regex; uppercase formatter; max 11; trimmed/uppercased in controller (`profile_edit_sheets.dart:111-114`; validator `profile_models.dart:180-185`; save `profile_controller.dart:81-96`). | Bank edit sheet. | Y — second bank value. | ASK |
| PRF-IN-11 | Text input | `Name on Bank Account *` | Required after trim (`profile_edit_sheets.dart:115-118`; required validator `profile_models.dart:155-157`). | Bank edit sheet. | Y — third bank value. | ASK |
| PRF-DOC-04 | Document tile/action | `Supporting Document`; filename; `Uploaded on <date>`; `View document`; `Replace` | Existing document is shown when present. View previews/opens it; Replace → native or web file picker (`profile_edit_sheets.dart:318-353`; picker `document_picker.dart:35-51`). | Edit sheet has a document. Seeded profile documents exist in demo data. | N | Y |
| PRF-BTN-07 | Button | `Submit for Approval` | Validate form; if valid pops the sheet with new KYC details. Parent saves locally, changes status to pending, and shows section-specific submitted snackbar (`profile_edit_sheets.dart:355-360`; `profile_tab_body.dart:81-116`). | KYC edit sheet. | N | Y |
| PRF-BTN-08 | Button | `Save Changes` | Validate personal form; if valid pops sheet with edited personal info (`profile_edit_sheets.dart:355-360`). | Personal edit sheet. | N | Y |
| PRF-DLG-01 | Document preview dialog | Dynamic filename title; `Close` tooltip; image content | If picked bytes exist, web attempts new-tab open; native writes a temp file and opens system handler; if neither can open and file is non-PDF, shows zoomable image dialog. Close pops dialog (`profile_document_preview.dart:15-99`). | `View document` invoked. Seeded docs have no bytes, so instead show the preview-unavailable message. | N | Y |

## States and messages

| State/trigger | Exact message or visible state | Location/evidence |
|---|---|---|
| `details == null` during load | Centered circular progress indicator; no text. No profile-specific error state is implemented. | `profile_tab_body.dart:170-175`; load at `:35-50`. |
| Any PAN/GST/bank status pending | `Some details are pending for approval. Once approved by the backend team, they cannot be changed.` | `profile_widgets.dart:161-187`; condition `profile_tab_body.dart:178`. |
| Attempt to open approved PAN/GST/bank | `<section> are approved and can no longer be changed.` where section is `PAN details`, `GST details`, or `Bank details`. | `profile_tab_body.dart:55-58,81-116`. |
| Personal save | `Personal information updated` | `profile_tab_body.dart:78-79`. |
| PAN save | `PAN details submitted for approval` | `profile_tab_body.dart:81-90`. |
| GST save | `GST details submitted for approval` | `profile_tab_body.dart:92-102`. |
| Bank save | `Bank details submitted for approval` | `profile_tab_body.dart:104-115`. |
| Avatar tap | `Profile photo upload is coming soon` | `profile_tab_body.dart:158-161`. |
| Copy referral code | `Referral code copied` | `profile_tab_body.dart:399-408`. |
| Copy share message | `Share message copied — paste it anywhere` | `profile_tab_body.dart:410-423`. |
| Status | `Approved` or `Pending for Approval` | `profile_models.dart:8-14`; badge `profile_widgets.dart:410-443`. |
| Empty displayed profile field | `—` | `profile_widgets.dart:306-324`. |
| Seeded document tapped (no bytes) | `Preview is only available for documents uploaded in this session` | `profile_document_preview.dart:20-25`. |
| Native file open fails | `Could not open document: ${result.message}` | `profile_document_preview.dart:32-39`. |
| PDF fallback preview not available | `PDF preview is not available on this device yet` | `profile_document_preview.dart:46-49`. |
| Image preview dialog | Filename, image and `Close` tooltip; no other dialog copy. | `profile_document_preview.dart:53-91`. |
| Invalid type selected | `Only PDF, JPG or PNG files are allowed.` | `document_picker.dart:43-44`; picker errors are shown as snackbars via `profile_edit_sheets.dart:217-235`. |
| Empty file selected | `The selected file is empty.` | `document_picker.dart:45-47`; displayed through edit-sheet snackbar handler `profile_edit_sheets.dart:217-235`. |
| File exceeds 5 MiB | `File is too large. Maximum size is 5 MB.` | `document_picker.dart:48-50`; displayed through edit-sheet snackbar handler `profile_edit_sheets.dart:217-235`. |
| Other file-picker exception | `Could not open the file picker.` | `profile_edit_sheets.dart:227-230`; exception is also sent to `debugPrint`. |
| Personal email missing/invalid | `Email address is required`; `Enter a valid email address` | `profile_models.dart:155-163`. |
| PAN missing/invalid | `PAN number is required`; `Enter a valid PAN (e.g. ABCDE1234F)` | `profile_models.dart:165-171`. |
| GST missing/invalid | `GST number is required`; `Enter a valid 15-character GSTIN` | `profile_models.dart:173-178`. |
| IFSC missing/invalid | `IFSC code is required`; `Enter a valid IFSC (e.g. HDFC0001234)` | `profile_models.dart:180-185`. |
| Account missing/invalid | `Account number is required`; `Enter 9–18 digits` | `profile_models.dart:187-191`. |
| Required name/address missing | `Full name is required`, `Address is required`, or `Name is required`, depending on field | `profile_edit_sheets.dart:23-33,56-59,82-85,115-118`; validator `profile_models.dart:155-157`. |
| Profile KYC seeded state | PAN Approved, GST Pending for Approval, Bank Approved; banner is therefore initially shown for a fresh profile. | `in_memory_profile_repository.dart:27-54`. |

## Displayed values

- Profile initials: name-derived uppercase initials; see PRF-TXT-01 and `lib/features/catalog/domain/models/catalog_models.dart:25-37`.
- Empty info-row values become `—` (`profile_widgets.dart:306-324`).
- Account number is stored masked: remove whitespace; if length ≤4 return as-is, else replace all but last four characters with `X` (`profile_models.dart:141-145`). Seeded bank value already has `XXXXXXXX1234` (`in_memory_profile_repository.dart:43-49`).
- Document upload date: `d MMM yyyy` with fixed English month abbreviations Jan–Dec and no zero-padding of day (`profile_widgets.dart:8-15,385-391`).
- Rewards subtitle is integer balance followed by literal ` points`; balance is earned ledger points minus redeemed ledger points for that requester (`profile_tab_body.dart:294-295`; `in_memory_reward_repository.dart:129-141`).
- Referral code formula is detailed in PRF-VAL-12 (`profile_tab_body.dart:133-141`).
- KYC status label is enum mapping `approved` → `Approved`, `pending` → `Pending for Approval` (`profile_models.dart:8-14`).
- The repository seeds PAN/GST/business-document details with fixed `DateTime(2026, 3, 10)` (`in_memory_profile_repository.dart:21-23`); newly replaced documents use `DateTime.now()` (`profile_edit_sheets.dart:237-248`).

## Style with meaning

- Approved and pending statuses are distinguishable by label and icon as well as palette: approved uses check-circle/success colors, pending uses schedule/error colors (`profile_widgets.dart:410-443`). A redesign may change palette but must retain clear distinguishability.
- The mobile-number lock is conveyed by lock icon and exact `Not Editable` label, not color alone (`profile_widgets.dart:450-480`).
- Approval-pending banner has info icon and message (`profile_widgets.dart:161-187`); KYC edit notice uses a warning-container treatment (`profile_edit_sheets.dart:295-309`).
- Document icon differs for PDF vs image; PDF uses error color and image uses primary color (`profile_widgets.dart:358-381`). Preserve the file-type distinction.
- Invalid form states use framework validator presentation and exact validator text listed above (`profile_edit_sheets.dart:368-388`; `profile_models.dart:148-191`).

## Keyboard and focus

- No explicit autofocus, custom focus traversal, or keyboard-submit callback is configured. Text fields occur in the declared field-list order; submit is through the visible form button (`profile_edit_sheets.dart:21-139,211-215,312-360`).
- Form field ordering is behavior-sensitive: `onSave` receives controllers in field-list order. Personal save intentionally uses positions 0, 2 and 3 because position 1 (mobile) is read-only; KYC builders index sequentially (`profile_edit_sheets.dart:21-139,211-215`).
- Email uses email keyboard. PAN/GST/IFSC use character capitalization and uppercase input formatter. Account uses number keyboard and digits-only formatter. Address uses multiline input. Field max lengths are 10 (PAN), 15 (GST), 18 (account), and 11 (IFSC) (`profile_edit_sheets.dart:21-139,368-397`).
- Mobile input is disabled/read-only. Sheet content scrolls and includes current keyboard inset (`profile_edit_sheets.dart:254-273,368-388`).
- Back and close controls use Navigator pop; native Escape behavior is not explicitly customized. Focus order beyond widget/source order is unknown.

## Responsive

- Main content is a `CustomScrollView` with slivers (`profile_tab_body.dart:164-181`).
- Edit form is a `SingleChildScrollView`, bottom sheet is scroll-controlled and safe-area-aware, and bottom padding follows keyboard inset (`profile_edit_sheets.dart:128-139,254-273`).
- Document handling is platform-dependent: web attempts opening bytes in a browser tab; native platforms write to the temporary directory and invoke the system file handler (`profile_document_preview.dart:15-51`). No screen-width breakpoints were found in the mapped profile files.

## Risk notes

- Do not reorder fields within each `_FormSheet`: submit builds a positional values list, and each `onSave` maps fixed indexes to profile properties (`profile_edit_sheets.dart:21-139,211-215`).
- Do not move or detach actions from the associated card/document/referral context without preserving the captured section/document values and callback. Section taps close over the currently rendered `details` (`profile_tab_body.dart:183-278`).
- Approved KYC sections are locked in the tap handler and independently guarded by `ProfileController._assertEditable`; both layers preserve behavior (`profile_tab_body.dart:81-116`; `profile_controller.dart:108-110`).
- Sign out must use the root navigator because the shell nests navigation; clearing only the session or navigating through the nested navigator changes behavior (`profile_tab_body.dart:118-130`).
- Share is clipboard-copy behavior, not a platform share action (`profile_tab_body.dart:410-423`).
- Seed documents contain no bytes, so their View action does not display the file; replacing a document stores bytes only in this session's in-memory profile state (`in_memory_profile_repository.dart:27-54`; `profile_document_preview.dart:20-25`; `profile_edit_sheets.dart:237-248`).
