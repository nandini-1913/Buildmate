import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/reward_controller.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/rewards_perk_repository.dart';
import '../../domain/models/reward_models.dart';
import '../../domain/models/reward_perk_models.dart';

class MyRewardsScreen extends StatefulWidget {
  const MyRewardsScreen({super.key});

  @override
  State<MyRewardsScreen> createState() => _MyRewardsScreenState();
}

class _MyRewardsScreenState extends State<MyRewardsScreen> {
  List<RewardTier> _tiers = const [];
  List<RewardPerk> _perks = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _loadPerks();
  }

  Future<void> _loadPerks() async {
    final (tiers, perks) = await RewardsPerkRepository.load();
    if (!mounted) return;
    setState(() {
      _tiers = tiers;
      _perks = perks;
    });
  }

  Future<void> _refresh() async {
    final userId = context.read<SessionController>().user.id;
    await context.read<RewardController>().refreshForUser(userId);
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _formatInr(double value) {
    final n = value.toStringAsFixed(0);
    final withCommas = n.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$withCommas';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Rewards'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            _RewardTierCard(
              balance: rewards.balance,
              tiers: _tiers,
              formatPoints: _formatPoints,
            ),
            const SizedBox(height: AppSpacing.space6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Redeem your points',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showHistorySheet(context, rewards),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('History'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            if (_perks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ..._perks.map(
                (perk) => _RedeemPerkTile(
                  perk: perk,
                  balance: rewards.balance,
                ),
              ),
            const SizedBox(height: AppSpacing.space6),
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.space2),
                Text('Reward History', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            if (rewards.entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.space5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Text(
                      'No reward points earned yet.',
                      style: theme.textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      'Complete a purchase to start earning rewards.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...rewards.entries.map((entry) => _RewardHistoryTile(
                    entry: entry,
                    formatPoints: _formatPoints,
                    formatInr: _formatInr,
                    formatDate: _formatDate,
                  )),
          ],
        ),
      ),
    );
  }

  void _showHistorySheet(BuildContext context, RewardController rewards) {
    // Purely a scroll shortcut to the history section below — no flow change.
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      alignment: 1,
    );
  }
}

class _RewardTierCard extends StatelessWidget {
  const _RewardTierCard({
    required this.balance,
    required this.tiers,
    required this.formatPoints,
  });

  final int balance;
  final List<RewardTier> tiers;
  final String Function(int) formatPoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Resolve current tier + the next one up from the mock tier ladder.
    RewardTier current = tiers.isNotEmpty
        ? tiers.first
        : const RewardTier(name: 'Member', minPoints: 0);
    RewardTier? next;
    for (final tier in tiers) {
      if (balance >= tier.minPoints) {
        current = tier;
      } else {
        next = tier;
        break;
      }
    }

    double progress = 1;
    int pointsToGo = 0;
    if (next != null) {
      final span = next.minPoints - current.minPoints;
      final earned = balance - current.minPoints;
      progress = span == 0 ? 1 : (earned / span).clamp(0, 1).toDouble();
      pointsToGo = next.minPoints - balance;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD97706),
            Color(0xFFB45309),
            Color(0xFF1A56DB),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: AppRadius.xlAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space1,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: AppRadius.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  '${current.name.toUpperCase()} MEMBER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPoints(balance),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'pts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            next != null
                ? '${formatPoints(pointsToGo)} pts to go until ${next.name}'
                : 'Reward points earned from your purchases',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          if (tiers.length > 1) ...[
            const SizedBox(height: AppSpacing.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  current.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  next != null
                      ? '${next.name} · ${formatPoints(next.minPoints)}'
                      : 'Max tier reached',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RedeemPerkTile extends StatelessWidget {
  const _RedeemPerkTile({required this.perk, required this.balance});

  final RewardPerk perk;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = balance >= perk.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: unlocked
              ? perk.color.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked
                ? perk.color.withValues(alpha: 0.12)
                : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: unlocked
                  ? perk.color.withValues(alpha: 0.14)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              perk.icon,
              size: 20,
              color: unlocked ? perk.color : AppColors.outline,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perk.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  perk.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.diamond_rounded,
                      size: 12,
                      color: unlocked ? perk.color : AppColors.disabled,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${perk.cost} pts',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: unlocked ? perk.color : AppColors.disabled,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          FilledButton(
            onPressed: unlocked
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${perk.title} redeemed!')),
                    );
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: perk.color,
              disabledBackgroundColor: AppColors.disabledContainer,
              disabledForegroundColor: AppColors.disabled,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.pillAll,
              ),
              minimumSize: const Size(0, AppSpacing.space10),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
            ),
            child: Text(unlocked ? 'Redeem' : 'Locked'),
          ),
        ],
      ),
    );
  }
}

class _RewardHistoryTile extends StatelessWidget {
  const _RewardHistoryTile({
    required this.entry,
    required this.formatPoints,
    required this.formatInr,
    required this.formatDate,
  });

  final RewardLedgerEntry entry;
  final String Function(int) formatPoints;
  final String Function(double) formatInr;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = entry.isEarned;
    final accent = positive ? AppColors.success : AppColors.error;
    final accentContainer =
        positive ? AppColors.successContainer : AppColors.errorContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: accentContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              positive
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Quotation #${entry.quotationDisplayId.isEmpty ? entry.quotationId : entry.quotationDisplayId}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      positive
                          ? '+${formatPoints(entry.points)}'
                          : '-${formatPoints(entry.points)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  entry.description.isEmpty
                      ? 'Sale confirmed'
                      : entry.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                if (entry.quotationGrandTotal > 0)
                  Text(
                    '${formatInr(entry.quotationGrandTotal)} quotation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  formatDate(entry.createdAt),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
