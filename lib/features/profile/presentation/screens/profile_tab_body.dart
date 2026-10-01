import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/reward_controller.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../catalog/domain/models/catalog_models.dart';

/// Profile tab content inside [MainShell] (no nested Scaffold).
class ProfileTabBody extends StatefulWidget {
  const ProfileTabBody({super.key});

  @override
  State<ProfileTabBody> createState() => _ProfileTabBodyState();
}

class _ProfileTabBodyState extends State<ProfileTabBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<SessionController>().user.id;
      context.read<RewardController>().refreshForUser(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    final balance = context.watch<RewardController>().balance;
    final theme = Theme.of(context);

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColors.surface,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: AppSpacing.space14,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Profile', style: theme.textTheme.titleLarge),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          user.initials,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: theme.textTheme.titleMedium),
                            if (user.email != null)
                              Text(
                                user.email!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.outline,
                                ),
                              ),
                            Text(
                              'ID: ${user.id}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                _ProfileTile(
                  icon: Icons.stars_rounded,
                  title: 'My Rewards',
                  subtitle: '$balance points',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.myRewards);
                  },
                ),
                _ProfileTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin · Quotations',
                  subtitle: 'Mark quotations as sold (demo)',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.adminQuotations);
                  },
                ),
                _ProfileTile(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Switch demo user',
                  subtitle: 'Test rewards isolation',
                  onTap: () => _switchDemoUser(context),
                ),
                const SizedBox(height: AppSpacing.space4),
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<SessionController>().logout();
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: true)
                        .pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchDemoUser(BuildContext context) async {
    final session = context.read<SessionController>();
    final rewards = context.read<RewardController>();

    if (session.user.id == 'user-demo-1') {
      session.setUser(
        const AppUserProfile(
          id: 'user-amit',
          name: 'Amit Kumar',
          email: 'amit.kumar@example.com',
          phone: '+91 99887 76655',
        ),
      );
    } else {
      session.resetToDemo();
    }
    await rewards.refreshForUser(session.user.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${session.user.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
