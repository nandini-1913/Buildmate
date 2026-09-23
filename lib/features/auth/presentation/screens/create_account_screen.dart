import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/login_flow_widgets.dart';

/// Step 3 — collect full name before profession selection.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.args});

  final SignupFlowArgs? args;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _referralController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _continue() {
    final mobile = widget.args?.mobileNumber;
    if (mobile == null || mobile.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final referralCode = _referralController.text.trim();

    Navigator.of(context).pushNamed(
      AppRoutes.chooseLocation,
      arguments: SignupFlowArgs(
        mobileNumber: mobile,
        fullName: _nameController.text.trim(),
        referralCode: referralCode.isEmpty ? null : referralCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: LoginFlowColors.backdropGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const padding = EdgeInsets.fromLTRB(
                AppSpacing.space6,
                AppSpacing.space6,
                AppSpacing.space6,
                AppSpacing.space4,
              );
              final minHeight = constraints.maxHeight - padding.vertical;
              return SingleChildScrollView(
                padding: padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: minHeight > 0 ? minHeight : 0,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LoginFlowBackButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        const Center(
                          child: LoginFlowIconBadge(
                            icon: Icons.person_outline_rounded,
                            size: 84,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space5),
                        Text(
                          'Create Your Account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        Text(
                          'Just a couple of details to get you started',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        LoginFlowOutlinedField(
                          label: 'Full Name',
                          controller: _nameController,
                          hintText: 'Enter your full name',
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: AppSpacing.space5),
                        LoginFlowOutlinedField(
                          label: 'Referral Code (Optional)',
                          controller: _referralController,
                          hintText: 'Enter referral code, if you have one',
                          textCapitalization: TextCapitalization.characters,
                          prefixIcon: Icons.card_giftcard_rounded,
                        ),
                        const Spacer(),
                        LoginFlowContinueButton(
                          label: 'Continue',
                          onPressed: _continue,
                        ),
                        const SizedBox(height: AppSpacing.space5),
                        const LoginFlowTermsFooter(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
