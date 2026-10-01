import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/profile_controller.dart';
import '../../../../core/state/reward_controller.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../domain/models/profile_models.dart';
import '../widgets/profile_document_preview.dart';
import '../widgets/profile_edit_sheets.dart';
import '../widgets/profile_widgets.dart';

/// Profile tab content inside [MainShell] (no nested Scaffold).
///
/// Shows personal info plus PAN / GST / Bank KYC sections. Tapping a section
/// opens its edit sheet; approved sections are locked.
class ProfileTabBody extends StatefulWidget {
  const ProfileTabBody({super.key, this.showBackButton = false});

  /// True when pushed as the standalone [AppRoutes.profile] route.
  final bool showBackButton;

  @override
  State<ProfileTabBody> createState() => _ProfileTabBodyState();
}

class _ProfileTabBodyState extends State<ProfileTabBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<SessionController>().user;
    await Future.wait([
      context.read<RewardController>().refreshForUser(user.id),
      context.read<ProfileController>().loadForUser(user),
    ]);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showLocked(String section) {
    _showSnack('$section are approved and can no longer be changed.');
  }

  Future<void> _editPersonal(PersonalInfo info) async {
    final saved = await showPersonalInfoEditSheet(context, info);
    if (saved == null || !mounted) return;
    await context.read<ProfileController>().savePersonal(saved);
    if (!mounted) return;
    // Keep the session (header avatar, initials) in sync with the new name.
    final session = context.read<SessionController>();
    final u = session.user;
    session.setUser(
      AppUserProfile(
        id: u.id,
        name: saved.fullName,
        email: saved.email,
        phone: u.phone,
        businessName: u.businessName,
        isGuest: u.isGuest,
      ),
    );
    _showSnack('Personal information updated');
  }

  Future<void> _editPan(PanDetails pan) async {
    if (pan.status.isLocked) return _showLocked('PAN details');
    final saved = await showPanEditSheet(context, pan);
    if (saved == null || !mounted) return;
    await context.read<ProfileController>().savePan(
          panNumber: saved.panNumber,
          nameOnDocument: saved.nameOnDocument,
          document: saved.document,
        );
    _showSnack('PAN details submitted for approval');
  }

  Future<void> _editGst(GstDetails gst) async {
    if (gst.status.isLocked) return _showLocked('GST details');
    final saved = await showGstEditSheet(context, gst);
    if (saved == null || !mounted) return;
    await context.read<ProfileController>().saveGst(
          gstNumber: saved.gstNumber,
          nameOnDocument: saved.nameOnDocument,
          document: saved.document,
        );
    _showSnack('GST details submitted for approval');
  }

  Future<void> _editBank(BankDetails bank) async {
    if (bank.status.isLocked) return _showLocked('Bank details');
    final saved = await showBankEditSheet(context, bank);
    if (saved == null || !mounted) return;
    await context.read<ProfileController>().saveBank(
          accountNumber: saved.accountNumber,
          ifscCode: saved.ifscCode,
          nameOnAccount: saved.nameOnAccount,
          document: saved.document,
        );
    _showSnack('Bank details submitted for approval');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    final balance = context.watch<RewardController>().balance;
    final details = context.watch<ProfileController>().details;
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.background,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                initials: user.initials,
                showBackButton: widget.showBackButton,
                onAvatarTap: () =>
                    _showSnack('Profile photo upload is coming soon'),
              ),
            ),
            if (details == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space8,
                ),
                sliver: SliverList.list(
                  children: [
                    if (details.hasPendingApproval) ...[
                      const ProfileApprovalBanner(),
                      const SizedBox(height: AppSpacing.space3),
                    ],
                    ProfileSectionCard(
                      icon: Icons.person_rounded,
                      title: 'Personal Information',
                      onTap: () => _editPersonal(details.personal),
                      children: [
                        ProfileInfoRow(
                          label: 'Full Name',
                          value: details.personal.fullName,
                        ),
                        ProfileInfoRow(
                          label: 'Mobile Number',
                          value: details.personal.mobileNumber,
                          trailing: const NotEditableChip(),
                        ),
                        ProfileInfoRow(
                          label: 'Email Address',
                          value: details.personal.email,
                        ),
                        ProfileInfoRow(
                          label: 'Address',
                          value: details.personal.address,
                        ),
                      ],
                    ),
                    ProfileSectionCard(
                      icon: Icons.description_rounded,
                      title: 'PAN Details',
                      status: details.pan.status,
                      onTap: () => _editPan(details.pan),
                      children: [
                        ProfileInfoRow(
                          label: 'PAN Number',
                          value: details.pan.panNumber,
                        ),
                        ProfileInfoRow(
                          label: 'Name on Document',
                          value: details.pan.nameOnDocument,
                        ),
                        ProfileDocumentRow(
                          document: details.pan.document,
                          onView: () => showProfileDocument(
                            context,
                            details.pan.document,
                          ),
                        ),
                      ],
                    ),
                    ProfileSectionCard(
                      icon: Icons.description_rounded,
                      title: 'GST Details',
                      status: details.gst.status,
                      onTap: () => _editGst(details.gst),
                      children: [
                        ProfileInfoRow(
                          label: 'GST Number',
                          value: details.gst.gstNumber,
                        ),
                        ProfileInfoRow(
                          label: 'Name on Document',
                          value: details.gst.nameOnDocument,
                        ),
                        ProfileDocumentRow(
                          document: details.gst.document,
                          onView: () => showProfileDocument(
                            context,
                            details.gst.document,
                          ),
                        ),
                      ],
                    ),
                    ProfileSectionCard(
                      icon: Icons.account_balance_rounded,
                      title: 'Bank Details',
                      status: details.bank.status,
                      onTap: () => _editBank(details.bank),
                      children: [
                        ProfileInfoRow(
                          label: 'Account Number',
                          value: details.bank.accountNumber,
                        ),
                        ProfileInfoRow(
                          label: 'IFSC Code',
                          value: details.bank.ifscCode,
                        ),
                        ProfileInfoRow(
                          label: 'Name on Account',
                          value: details.bank.nameOnAccount,
                        ),
                        ProfileDocumentRow(
                          document: details.bank.document,
                          onView: () => showProfileDocument(
                            context,
                            details.bank.document,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space1,
                        bottom: AppSpacing.space2,
                      ),
                      child: Text('Account', style: theme.textTheme.titleSmall),
                    ),
                    _ProfileTile(
                      icon: Icons.stars_rounded,
                      title: 'My Rewards',
                      subtitle: '$balance points',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.myRewards);
                      },
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<SessionController>().logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
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
