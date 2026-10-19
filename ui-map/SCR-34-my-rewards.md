# SCR-34 — My rewards

- **Route:** `/my-rewards`.
- **Files:** `lib/features/rewards/presentation/screens/my_rewards_screen.dart` (544 lines); `lib/features/rewards/domain/models/reward_models.dart` (49); `lib/core/state/reward_controller.dart` (71); `lib/features/rewards/domain/reward_service.dart` (76); `lib/features/rewards/data/reward_repository.dart` (14); `lib/features/rewards/data/in_memory_reward_repository.dart` (158); `lib/core/routes/app_router.dart` (300); `lib/core/routes/app_routes.dart` (201); reward repository wiring `lib/main.dart` (82).
- **Purpose:** Show the current user's points balance, earned/redeemed totals, and chronological reward ledger history.
- **Line-count convention:** physical source lines counted from the files listed above.

## Data

- On first frame, reads the current `SessionController.user.id` and calls `RewardController.refreshForUser(userId)` (`my_rewards_screen.dart:20-27`). No API request is made; `main.dart:67-71` injects `InMemoryRewardRepository.withDemoSeed()` (`in_memory_reward_repository.dart:5-14`).
- Refresh obtains the balance and ledger for that requester from `RewardService` and the configured `RewardRepository`, then notifies listeners (`reward_controller.dart:41-46`; `reward_service.dart:21-24`). The screen watches the controller (`my_rewards_screen.dart:62-63`).
- The in-memory demo repository seeds six mock ledger entries for each user on first query and returns that user's entries sorted newest-first (`in_memory_reward_repository.dart:18-101,118-125`).
- Screen actions send no data and do not mutate rewards. Toolbar refresh and pull-to-refresh both repeat the current-user refresh (`my_rewards_screen.dart:20-27,76-85`).
- Profile and Home reward links navigate to `AppRoutes.myRewards`; route constant is `/my-rewards` (`profile_tab_body.dart:292-299`; `home_app_bar.dart:92-99`; `app_routes.dart:44`; `app_router.dart:244-245`).

## Elements

| ID | Type | Exact visible text | What it does (handler → effect; evidence) | Shown or enabled when | Order-sensitive? | May be moved? |
|---|---|---|---|---|---|---|
| RWD-APP-01 | App bar title | `Rewards` | Static `AppBar` title (`my_rewards_screen.dart:68-75`). | Always. | N | Y |
| RWD-BTN-01 | Icon button | Refresh icon; tooltip `Refresh` | Tap → `_refresh`, which reloads balance and ledger for current session user (`my_rewards_screen.dart:25-27,76-81`). | Always. | N | Y |
| RWD-GEST-01 | Pull-to-refresh | No text | Pull down on the list → `RefreshIndicator.onRefresh` invokes same `_refresh` (`my_rewards_screen.dart:83-85`). | Always; list content is scrollable. | N | Y |
| RWD-CARD-01 | Points card label | `Reward Points` | Static label inside balance card (`my_rewards_screen.dart:254-273`). | Always. | N | Y |
| RWD-CARD-02 | Points balance label | `Available balance` | Static label for current balance (`my_rewards_screen.dart:276-282`). | Always. | N | Y |
| RWD-VAL-01 | Points balance | Dynamic formatted integer + `pts` | Uses `RewardController.balance`, formatted with comma grouping (`my_rewards_screen.dart:89-97,288-306`; formatter `:30-35`). | Always, including initial controller value 0. | N | Y |
| RWD-VAL-02 | Summary statistic | `Total earned`; formatted value + `pts` | Sums `points` for entries whose `isEarned` is true, then formats with comma grouping (`my_rewards_screen.dart:89-92,318-333`; `RewardLedgerEntry.isEarned` at `reward_models.dart:28`). | Always. | N | Y |
| RWD-VAL-03 | Summary statistic | `Redeemed`; formatted value + `pts` | Sums `points` for entries whose `isEarned` is false, then formats with comma grouping (`my_rewards_screen.dart:93-95,334-347`; `reward_models.dart:28`). | Always. | N | Y |
| RWD-ICO-01 | Section icon | History icon; no text | Decorative `Icons.history_rounded` (`my_rewards_screen.dart:101-106`). | Always. | N | Y |
| RWD-TXT-01 | Section heading | `Reward History` | Static ledger-history heading (`my_rewards_screen.dart:101-107`). | Always. | N | Y |
| RWD-EMP-01 | Empty-state icon | Stars icon; no text | Decorative icon inside empty-history card (`my_rewards_screen.dart:113-132`). | `rewards.entries.isEmpty`. | N | Y |
| RWD-EMP-02 | Empty-state heading | `No reward points earned yet.` | Static message when ledger has no entries (`my_rewards_screen.dart:133-139`). | `rewards.entries.isEmpty`. | N | Y |
| RWD-EMP-03 | Empty-state explanation | `Complete a purchase to start earning rewards.` | Static message when ledger has no entries (`my_rewards_screen.dart:140-146`). | `rewards.entries.isEmpty`. | N | Y |
| RWD-ROW-01 | History item | `Quotation #<display ID or quotation ID>` | Uses `quotationDisplayId`, falling back to `quotationId` if display ID is empty (`my_rewards_screen.dart:494-501`). | One per ledger entry, newest-first. | N | Y |
| RWD-ROW-02 | History amount | `+<points>` for earned; `-<points>` for redeemed | Uses `entry.isEarned` to choose sign and success/error accent (`my_rewards_screen.dart:449-453,502-510`). | One per ledger entry. | N | Y |
| RWD-ROW-03 | History description | `entry.description`, or `Sale confirmed` when empty | Conditional fallback text (`my_rewards_screen.dart:515-520`). | One per ledger entry. | N | Y |
| RWD-ROW-04 | Quotation amount detail | `<formatted rupee amount> quotation` | Displays `quotationGrandTotal` only when greater than 0 (`my_rewards_screen.dart:523-529`). | One per entry whose grand total > 0. | N | Y |
| RWD-ROW-05 | History date | Dynamic `d MMM yyyy` | Formats `entry.createdAt` using fixed English month names (`my_rewards_screen.dart:46-63,530-535`). | One per ledger entry. | N | Y |

History cards and displayed fields have no tap handler (`my_rewards_screen.dart:443-544`).

## States and messages

- **Initial state:** `RewardController` starts with balance 0 and empty entries; screen has no loading indicator, so the empty-history card may render before the first refresh completes (`reward_controller.dart:26-27`; `my_rewards_screen.dart:20-27,62-63,113-154`).
- **Empty ledger:** `No reward points earned yet.` and `Complete a purchase to start earning rewards.` (`my_rewards_screen.dart:113-146`).
- **Non-empty ledger:** each entry is rendered as a history tile (`my_rewards_screen.dart:147-157,443-544`).
- No dedicated loading, error, success, validation, or confirmation message/state is implemented. Refresh errors have no screen-specific catch or presentation path (`my_rewards_screen.dart:25-27,76-85`).
- With app's demo-seeded repository, six entries are initially seeded for an unseen user; seeded earned values total 1,120 points, redeemed values total 480 points, and available balance is 640 (`in_memory_reward_repository.dart:18-84,129-141`). Ledger order is descending `createdAt` (`:118-125`).

## Displayed values

- **Available balance:** `earned points - redeemed points` for the user (`in_memory_reward_repository.dart:129-141`).
- **Total earned:** sum of points across currently loaded `isEarned` entries (`my_rewards_screen.dart:89-92`).
- **Redeemed:** sum of points across currently loaded entries where `isEarned` is false (`my_rewards_screen.dart:93-95`).
- Points use Western thousands separators inserted by a digit-lookahead regex (`my_rewards_screen.dart:30-35`).
- Per-entry points are signed by ledger type; displayed absolute point value uses the same grouping formatter (`my_rewards_screen.dart:502-510`).
- Quotation amount formats the `double` with `toStringAsFixed(0)`, applies Western thousands separators, and prefixes `₹` (`my_rewards_screen.dart:37-44`); the detail is omitted when amount ≤0 (`:523-529`).
- Quotation label uses `quotationDisplayId` unless empty, otherwise `quotationId` (`my_rewards_screen.dart:494-501`).
- Empty description falls back to exact text `Sale confirmed` (`my_rewards_screen.dart:515-520`).
- Dates display the day without leading zero, an English three-letter month, and year (`my_rewards_screen.dart:46-63`).
- Demo-seeded values: earned ledger entries 150, 300, 250, and 420 points; redeemed entries 250 and 230 points. Seeded ledger entries are copied to each user on first query (`in_memory_reward_repository.dart:18-101`).

## Style with meaning

- Earned ledger rows use upward arrow and success colors; redeemed rows use downward arrow and error colors. Keep both the sign and another distinguishable visual indication, not palette alone (`my_rewards_screen.dart:449-453,472-486,502-510`).
- Total-earned and redeemed summary stats use distinct trend-up/redeem icons and green/gold accents (`my_rewards_screen.dart:318-347`); balance card is a blue gradient with gold reward-point emphasis (`my_rewards_screen.dart:181-307`).
- Empty history has a star icon and explanatory text; no status palette is used to encode error/success (`my_rewards_screen.dart:113-146`).

## Keyboard and focus

- No text inputs, autofocus, custom keyboard handling, or custom focus traversal are present.
- Refresh button and pull-to-refresh use framework interaction behavior; history tiles are not interactive.
- No custom Enter/Escape behavior is implemented.

## Responsive

- The entire screen uses a vertically scrolling `ListView` with fixed spacing tokens and a responsive-width card layout; no width breakpoint is present (`my_rewards_screen.dart:83-86`).
- The balance card contains a `Row` with horizontal earned/redeemed stats and an `IntrinsicHeight` divider; retain readable values at narrow widths (`my_rewards_screen.dart:310-352`).

## Risk notes

- Keep balance, earned total, and redeemed total sourced from the ledger/controller; do not replace with independent display-only values (`my_rewards_screen.dart:89-97`; `reward_controller.dart:41-46`).
- Keep history ordering newest-first; repository sorts on `createdAt` (`in_memory_reward_repository.dart:118-125`).
- Preserve conditional description fallback, quotation-ID fallback, and positive-grand-total visibility rules (`my_rewards_screen.dart:494-529`).
- Earned/redeemed distinction is both semantic and visual: sign, arrow direction, and success/error treatment depend on `entry.isEarned` (`my_rewards_screen.dart:449-453,472-486,502-510`).
